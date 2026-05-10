# create-a-skill

Scripts for building, evaluating, and optimizing Claude Code skills.

## Scripts

| Script | Purpose |
|---|---|
| `run_eval.py` | Run a trigger evaluation against a skill description |
| `run_loop.py` | Run the eval + improve loop until all pass or max iterations |
| `improve_description.py` | Call Claude to improve a description based on eval results |
| `generate_report.py` | Generate an HTML report from eval results |
| `aggregate_benchmark.py` | Aggregate benchmark results across multiple runs |
| `quick_validate.py` | Quick validation of a skill structure |
| `package_skill.py` | Package a skill for distribution |
| `utils.py` | Shared utilities (SKILL.md parsing) |

---

## How an eval works

### What the subprocess does

Each query fires a `claude -p <query>` subprocess in a worker process. The subprocess:

- Runs with `cwd=project_root` (the nearest ancestor directory containing `.claude/`)
- Strips only `CLAUDECODE` from the environment; everything else, including auth, is inherited
- Passes `--include-partial-messages` to receive streaming events for early exit

### Model loaded

- In `run_loop.py`, `--model` is **required**, so always explicit
- In `run_eval.py` standalone, `--model` is **optional** (defaults to `None`, meaning the user's configured model)
- The same model is used for both eval subprocesses and `improve_description` calls
- There is no model pinning or isolation; the eval inherits whatever Claude Code defaults are active

### Skills, commands, and context

The subprocess is not isolated. It loads the full Claude Code environment at `project_root`:

- All installed skills in `.claude/skills/` are present
- All existing commands in `.claude/commands/` are present
- The test skill is injected as one additional command file: `.claude/commands/{skill_name}-skill-{uuid8}.md`
- `settings.local.json` is loaded, including all `permissions.allow` entries
- Both the global `~/.claude/CLAUDE.md` and any project-level `CLAUDE.md` are loaded

The test skill must compete against all real installed skills. This is intentional (it simulates real usage), but it means **results change as you add or remove skills**, and two skills with overlapping descriptions will interfere with each other.

### Profiles

No isolation. Whatever profiles are configured in the project's `.claude/` directory are active in each subprocess.

### Trigger detection

The eval watches the stream for a `content_block_start` event of type `tool_use`. If the tool name is `Skill` or `Read`, it accumulates the streaming JSON and checks whether the unique test skill name appears in it. If it does, the query is counted as triggered.

If the first tool call is anything other than `Skill` or `Read`, the subprocess is killed and the query is counted as not triggered.

---

## Known issues

### Premature `return False` on non-Skill tool calls (`run_eval.py`)

```python
if tool_name in ("Skill", "Read"):
    pending_tool_name = tool_name
    accumulated_json = ""
else:
    return False  # kills the process immediately
```

If Claude's first tool call is anything other than `Skill` or `Read` (e.g., it calls `Bash` or `WebSearch` before triggering the skill), this immediately returns `False` and kills the process. The intent — if Claude does not immediately invoke the skill, it did not trigger — is defensible for trigger-detection purposes. However, if Claude chains tools and does something minor before calling the skill, this will misclassify that as a miss.

### `|` block scalar joined with spaces instead of newlines (`utils.py`)

```python
description = " ".join(continuation_lines)
```

For a YAML `|` (literal block scalar), lines should be joined with `\n`, not space. For `>` (folded), space is correct. The code uses space regardless of which scalar indicator was used. In practice this only matters if a description has intentional multi-line content, but the logic is wrong.

### `improve_description` subprocess does not set `cwd`

The eval subprocess uses `cwd=project_root`, but the `_call_claude` call inside `improve_description.py` does not specify `cwd`. They run from different directories and therefore see different contexts. For improvement this is harmless (it is pure text generation with no tool use), but it is an inconsistency.

### No model pinning for eval subprocesses

The eval subprocess model and the improvement model share the same CLI argument, but the subprocess does not receive a `--model` flag unless the caller passes one. If `run_eval.py` is invoked without `--model`, each subprocess uses the user's configured default. Eval results from one machine or session may not reproduce on another if the default model differs.

### Parallel workers write to the same `.claude/commands/` directory

With 10 workers, 10 command files are created simultaneously. File names are unique (UUID suffix) so there are no collisions, and `exist_ok=True` on `mkdir` prevents races. Cleanup is in `finally` blocks so it is reliable. If a worker crashes hard enough to skip `finally`, leftover command files will remain.

---

## Design notes

The eval is a "does Claude pick this skill over all other currently-installed skills" test, not a clean-room isolation test. That is a deliberate design choice for real-world accuracy: the skill description must stand out among whatever is actually installed. The tradeoff is that results are coupled to the current state of your skill installation.
