# start

Project-local skill for the **ai-agent-skills** repository. Begins a new piece of work: fetches or creates a GitHub issue, then cuts a correctly named branch from `main`.

## Invocation

This skill is a **slash-command skill** — invoke it explicitly:

```
/start #14
/start I need to build a skill that summarises Slack threads
/start https://github.com/psenger/ai-agent-skills/issues/5
```

## Two Modes

### EXISTING ISSUE
Pass an issue number, URL, or reference. The skill:
1. Checks GitHub auth (MCP server or `gh` CLI)
2. Confirms your identity
3. Fetches the issue and shows the title — asks for confirmation
4. Pulls latest `main`
5. Cuts the correctly prefixed branch: `feature/<N>-<slug>` or `fix/<N>-<slug>`

### NEW ISSUE
Pass a description of what needs doing. The skill:
1. Checks GitHub auth and confirms identity
2. Classifies the work as a **feature** or **bug**
3. Reads the template from `.github/ISSUE_TEMPLATE/` and fills it out
4. Shows the draft — waits for your approval before submitting
5. Creates the GitHub issue with the correct label (`enhancement` or `bug`)
6. Cuts the branch

## Branch Naming

| Label | Prefix | Example |
|---|---|---|
| `enhancement` / `feature` | `feature/` | `feature/14-add-handoff-skill` |
| `bug` | `fix/` | `fix/23-vault-scribe-toc` |
| Other | `feature/` | (default) |

See the `conventions` skill for the full naming spec.

## Prerequisites

- GitHub MCP server **or** `gh` CLI authenticated (`gh auth login`)
- Clean working tree on `main`

## Trigger Accuracy

**Baseline score: 10/20 (50%)**

This skill is intentionally designed for **explicit slash-command invocation**. The low recall score is expected and acceptable:

- The `run_loop.py` trigger eval tests skills in isolation, without knowing you are inside the ai-agent-skills project. Without that project context, Claude does not associate generic phrases like "start work on #14" or "I need to build X" with this specific workflow skill.
- **In practice**, this skill fires correctly when invoked as `/start` from within the ai-agent-skills project.
- The 100% precision score confirms the skill never fires when it shouldn't.

Auto-triggering on phrases like "start work on #14" would require removing the project-scoping from the description — which would risk false-positive activation in other repositories.

## Eval Results

Eval files are in `.workspace/evals/`:

- `evals.json` — 3 functional test cases: existing issue flow, new feature issue, new bug issue
- `trigger-evals.json` — 20 trigger accuracy queries (baseline: 50%)
- `results/` — timestamped run outputs from `run_loop.py`

To re-run trigger accuracy:
```bash
cd ~/.claude/skills/create-a-skill
python3 -m scripts.run_loop \
  --eval-set /path/to/ai-agent-skills/.claude/skills/start/.workspace/evals/trigger-evals.json \
  --skill-path /path/to/ai-agent-skills/.claude/skills/start \
  --model claude-sonnet-4-6 \
  --max-iterations 5 \
  --verbose
```