# release

Project-local skill for the **ai-agent-skills** repository. Ships completed work in two phases depending on context: **WRAP UP** (on a feature branch) and **CUT RELEASE** (on `main` after a merge).

## Invocation

This skill is a **slash-command skill** — invoke it explicitly:

```
/release
```

The skill detects your current branch and runs the correct phase automatically.

## Two Phases

### WRAP UP — run on your feature branch

Triggered when you are on any non-main branch (`feature/`, `fix/`, `chore/`, etc.) with a clean working tree. Steps:

1. Checks GitHub auth (MCP server or `gh` CLI) and confirms identity
2. Verifies working tree is clean
3. Detects what changed: new skill, modified skill, bug fix, or docs change
4. Updates `CHANGELOG.md` under `## [Unreleased]` with the correct subsection
5. Updates `README.md` skills table (new skills only)
6. Updates `.claude-plugin/marketplace.json` (new skills only)
7. Commits those admin changes with `chore(<scope>): update changelog, readme, and marketplace`
8. Pushes the branch to origin
9. Opens a draft PR with the correct title format and Skill Checklist
10. Prints the PR URL

### CUT RELEASE — run on `main` after merging

Triggered when you are on `main` with a clean, up-to-date working tree. Steps:

1. Checks GitHub auth and confirms identity
2. Pre-flight: confirms on main, clean, and synced with origin
3. Determines next semver version from commits since last tag
4. Presents the proposed version and the commits that drove it — **waits for confirmation**
5. Updates `CHANGELOG.md`: renames `[Unreleased]` to `[X.Y.Z] - YYYY-MM-DD`, inserts fresh `[Unreleased]`, updates comparison links
6. Commits: `chore(release): cut vX.Y.Z release`
7. Creates annotated tag: `vX.Y.Z`
8. Pushes commit and tag
9. Creates a **draft** GitHub release — does NOT publish
10. Tells you to review and click Publish

## Full Workflow

```
/start #14          ← create branch
  ... do work ...
git commit -m "feat(handoff): add resume workflow"
/release            ← WRAP UP: CHANGELOG + README + PR
  ... merge PR on GitHub ...
git checkout main && git pull
/release            ← CUT RELEASE: tag + draft release
  ... publish on GitHub ...
```

## Prerequisites

- GitHub MCP server **or** `gh` CLI authenticated (`gh auth login`)
- Clean working tree (all changes committed)
- For CUT RELEASE: must be on `main`, synced with `origin/main`

## Trigger Accuracy

**Baseline score: 10/20 (50%)**

This skill is intentionally designed for **explicit slash-command invocation**. The low recall score is expected and acceptable:

- The `run_loop.py` trigger eval tests skills in isolation, without project context. Claude does not associate phrases like "ship this", "cut a release", or "wrap this up" with this specific two-phase workflow skill when tested outside the ai-agent-skills project.
- Even trigger phrases quoted verbatim in the description ("ship this", "release it") scored 0/1 recall in isolation — confirming this is a context problem, not a description quality problem.
- **In practice**, this skill fires correctly when invoked as `/release` from within the ai-agent-skills project.
- The 100% precision score confirms the skill never fires when it shouldn't.

Auto-triggering on "ship this" would require a self-contained description with no project scoping — which would risk false-positive activation in other repositories when someone casually says "ship this change".

## Eval Results

Eval files are in `.workspace/evals/`:

- `evals.json` — 2 functional test cases: WRAP UP on feature branch, CUT RELEASE on main
- `trigger-evals.json` — 20 trigger accuracy queries (baseline: 50%)
- `results/` — timestamped run outputs from `run_loop.py`

To re-run trigger accuracy:
```bash
cd ~/.claude/skills/create-a-skill
python3 -m scripts.run_loop \
  --eval-set /path/to/ai-agent-skills/.claude/skills/release/.workspace/evals/trigger-evals.json \
  --skill-path /path/to/ai-agent-skills/.claude/skills/release \
  --model claude-sonnet-4-6 \
  --max-iterations 5 \
  --verbose
```