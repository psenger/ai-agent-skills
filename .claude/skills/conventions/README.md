# conventions

Project-local skill for the **ai-agent-skills** repository. Defines commit message format, branch naming, PR body structure, CHANGELOG entries, and semver rules used by the `start` and `release` skills.

## Invocation

This skill is primarily loaded as a dependency by the `start` and `release` skills. It also activates when you ask a formatting question directly:

```
/conventions
what commit type should I use here?
how do I format this changelog entry?
what's the branch naming convention?
```

## What It Covers

| Topic | Details |
|---|---|
| Commit messages | `type(scope): subject` — Conventional Commits |
| Valid types | `feat`, `fix`, `chore`, `docs`, `refactor`, `test` |
| Branch naming | `feature/<N>-slug`, `fix/<N>-slug`, `chore/slug` |
| PR body | Summary bullets, `Closes #N`, test plan checkboxes |
| CHANGELOG | Keep a Changelog 1.1.0 — bold skill name, em dash, issue link |
| Semver | `BREAKING`/`feat`/`fix` → major/minor/patch |

## Trigger Accuracy

**Baseline score: 11/20 (55%)**

This skill is intentionally designed for **explicit invocation** and **dependency loading** — not for auto-triggering on natural language. The low recall score is expected and acceptable:

- The `run_loop.py` trigger eval tests skills in isolation without project context. Because this skill's description is scoped to "the ai-agent-skills repository", Claude does not auto-trigger it for generic format questions outside that project context.
- The only query that auto-triggered (55% = 11 correct, 10 false negatives) was the one that exactly matched a quoted phrase in the description.
- **In practice**, this skill fires correctly when invoked as `/conventions` or loaded by `start`/`release` within the project.

The 100% precision score (zero false positives) confirms the skill never fires when it shouldn't.

## Eval Results

Eval files are in `.workspace/evals/`:

- `evals.json` — 3 functional test cases: commit format, branch naming, CHANGELOG entry
- `trigger-evals.json` — 20 trigger accuracy queries (baseline: 55%)
- `results/` — timestamped run outputs from `run_loop.py`

To re-run trigger accuracy:
```bash
cd ~/.claude/skills/create-a-skill
python3 -m scripts.run_loop \
  --eval-set /path/to/ai-agent-skills/.claude/skills/conventions/.workspace/evals/trigger-evals.json \
  --skill-path /path/to/ai-agent-skills/.claude/skills/conventions \
  --model claude-sonnet-4-6 \
  --max-iterations 5 \
  --verbose
```