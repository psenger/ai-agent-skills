# Contributing

This guide walks through every contribution scenario — from idea to published release — using the three project-local skills (`/start`, `/release`, `/conventions`) that automate the workflow.

---

## Prerequisites

Before contributing, ensure:

1. **Claude Code** is running inside this repository (`/Users/.../ai-agent-skills`)
2. **Project-local skills are loaded** — the `.claude/skills/` directory is picked up automatically when Claude Code is opened in this repo
3. **GitHub auth** — either the GitHub MCP server is connected, or `gh` CLI is authenticated:
   ```bash
   gh auth status      # verify gh CLI
   gh auth login       # authenticate if needed
   ```
4. **Python 3** — required for eval scripts:
   ```bash
   python3 --version
   ```

---

## Workflow at a Glance

Every contribution follows the same spine:

```
/start          → cut a branch (from an issue or a description)
   ↓
  do work
   ↓
run evals       → trigger accuracy + functional evals
   ↓
/release        → WRAP UP: update changelog, push, open draft PR
   ↓
merge on GitHub
   ↓
/release        → CUT RELEASE: tag, push, draft GitHub release
   ↓
publish on GitHub
```

The difference between scenarios is what "do work" means and which evals matter.

---

## Scenario 1 — Adding a New Skill

**Start here when:** you have an idea for a skill that doesn't exist yet.

### Step 1 — Create the issue and branch

```
/start I need a skill that reviews pull requests and summarises the diff
```

`/start` will:
- Classify the request as a **feature**
- Read `.github/ISSUE_TEMPLATE/feature_request.md` and fill it out from your description
- Show you the draft — edit anything, then confirm
- Create the GitHub issue with the `enhancement` label
- Pull latest `main` and cut `feature/<N>-<slug>` (e.g. `feature/18-pr-review-skill`)
- Report: *"Branch feature/18-pr-review-skill created from main. You're ready to work."*

### Step 2 — Build the skill

Create the skill directory:

```
skills/<skill-name>/
├── SKILL.md                        ← start here
├── references/                      ← add if SKILL.md exceeds ~100 lines
│   └── *.md
└── .workspace/
    └── evals/
        ├── evals.json              ← write before running evals
        ├── trigger-evals.json      ← write before running trigger tests
        └── files/                   ← fixture files referenced by evals.json
```

Use `/create-a-skill` to help draft and iterate:
```
/create-a-skill I want to create a skill for reviewing pull requests
```

If you already have a draft and just want to write evals:
```
/create-a-skill I need to create an eval for skills/pr-review
```

### Step 3 — Write evals

`evals.json` needs at least 2 functional test cases. Each must have a `prompt`, `expected_output`, and `expectations` array with objectively verifiable assertions. See `skills/handoff/.workspace/evals/evals.json` for a worked example.

`trigger-evals.json` needs exactly 20 queries — 10 that should trigger the skill, 10 that should not. Tricky near-misses make the best negatives. See `skills/handoff/.workspace/evals/trigger-evals.json` for a worked example.

### Step 4 — Run trigger accuracy

```bash
cd ~/.claude/skills/create-a-skill

python3 -m scripts.run_loop \
  --eval-set /path/to/ai-agent-skills/skills/<skill-name>/.workspace/evals/trigger-evals.json \
  --skill-path /path/to/ai-agent-skills/skills/<skill-name> \
  --model claude-sonnet-4-6 \
  --max-iterations 5 \
  --verbose
```

**Target: 95% (19/20 correct).** If the script finds a better description, copy `best_description` from the output into the `description` field in `SKILL.md` frontmatter.

Repeat until you hit 95%.

### Step 5 — Run functional evals

```
/create-a-skill I want to run the functional evals for skills/<skill-name>
```

Review the graded outputs. Iterate on `SKILL.md` until the skill produces correct outputs consistently.

### Step 6 — Ship the PR

On your feature branch with all changes committed:

```
/release
```

`/release` (WRAP UP phase) will:
- Detect you're on a feature branch
- Detect a new skill was added
- Add a `### Added` bullet to `CHANGELOG.md` under `## [Unreleased]`
- Add a row to the `README.md` skills table
- Add an entry to `.claude-plugin/marketplace.json`
- Commit those admin changes
- Push the branch
- Open a draft PR with the Skill Checklist pre-filled
- Print the PR URL

Review the PR on GitHub, mark it ready for review, and merge.

### Step 7 — Cut the release

After the PR is merged, switch to `main`:

```bash
git checkout main
git pull origin main
```

Then:
```
/release
```

`/release` (CUT RELEASE phase) will:
- Determine the next semver version from commits (`feat` → minor bump)
- Show you the proposed version and ask for confirmation
- Rename `[Unreleased]` in `CHANGELOG.md` to `[X.Y.Z] - YYYY-MM-DD`
- Insert a fresh `[Unreleased]` section
- Update the comparison links at the bottom of `CHANGELOG.md`
- Commit: `chore(release): cut vX.Y.Z release`
- Tag: `vX.Y.Z` (annotated)
- Push the commit and tag
- Create a **draft** GitHub release
- Tell you to go publish it manually

---

## Scenario 2 — Fixing a Bug in an Existing Skill

**Start here when:** a skill is producing wrong output, following bad steps, or behaving unexpectedly.

### Step 1 — Create the issue and branch

If a GitHub issue already exists:
```
/start #23
```

If you're filing the bug yourself:
```
/start The vault-scribe skill generates invalid YAML frontmatter when the title contains a colon
```

`/start` (NEW ISSUE mode) will classify this as a bug, fill `bug_report.md`, and cut a `fix/<N>-<slug>` branch.

### Step 2 — Identify the problem

Before editing, decide which layer is broken:

| Problem type | Where to fix |
|---|---|
| Wrong steps or missing steps | `SKILL.md` body |
| Wrong output format | `SKILL.md` body or reference file |
| Outdated or incorrect reference material | `references/*.md` |
| Skill not triggering reliably | `description` field in frontmatter |

### Step 3 — Fix and re-run evals

Make your fix, then run the functional evals to confirm the bug is resolved:

```
/create-a-skill I want to run the functional evals for skills/<skill-name>
```

If the bug was an activation problem, run trigger accuracy after updating the description:

```bash
cd ~/.claude/skills/create-a-skill

python3 -m scripts.run_loop \
  --eval-set /path/to/ai-agent-skills/skills/<skill-name>/.workspace/evals/trigger-evals.json \
  --skill-path /path/to/ai-agent-skills/skills/<skill-name> \
  --model claude-sonnet-4-6 \
  --max-iterations 5 \
  --verbose
```

### Step 4 — Ship the PR

```
/release
```

`/release` will detect changes inside an existing skill directory and add a `### Fixed` bullet to `CHANGELOG.md`. It will not touch `README.md` or `marketplace.json` (only new skills trigger those updates).

### Step 5 — Cut the release

After merging:

```bash
git checkout main && git pull origin main
/release
```

A bug fix commit (`fix` type) → **patch** semver bump.

---

## Scenario 3 — Improving an Existing Skill

**Start here when:** you want to add a capability, improve output quality, or restructure a skill — but nothing is technically broken.

### Step 1 — Create the issue and branch

```
/start #17
```

or

```
/start The design-critique skill should support async API design in addition to sync
```

### Step 2 — Make changes and test

Edit `SKILL.md` (and reference files if needed). Re-run functional evals after your changes:

```
/create-a-skill I want to run the functional evals for skills/<skill-name>
```

If you change the `description`, also run trigger accuracy and confirm you haven't regressed below 95%.

### Step 3 — Ship

```
/release
```

`/release` detects a modified skill (not a new one) and adds a `### Changed` bullet to `CHANGELOG.md`. An enhancement commit (`feat` type) → **minor** bump at release time.

---

## Scenario 4 — Improving Trigger Accuracy

**Start here when:** a skill exists and works correctly but is not activating reliably — either it fires on the wrong prompts, or it fails to fire on the right ones.

### Step 1 — Diagnose

Run a baseline against all 20 eval queries:

```bash
cd ~/.claude/skills/create-a-skill

python3 -m scripts.run_loop \
  --eval-set /path/to/ai-agent-skills/skills/<skill-name>/.workspace/evals/trigger-evals.json \
  --skill-path /path/to/ai-agent-skills/skills/<skill-name> \
  --model claude-sonnet-4-6 \
  --max-iterations 1 \
  --holdout 0 \
  --report none \
  --verbose
```

Examine which queries failed:
- **False negatives** (should trigger, didn't): description is too narrow or missing key phrases
- **False positives** (shouldn't trigger, did): description is too broad or overlaps with another skill

### Step 2 — Run the optimisation loop

```bash
python3 -m scripts.run_loop \
  --eval-set /path/to/ai-agent-skills/skills/<skill-name>/.workspace/evals/trigger-evals.json \
  --skill-path /path/to/ai-agent-skills/skills/<skill-name> \
  --model claude-sonnet-4-6 \
  --max-iterations 5 \
  --verbose
```

The script will iterate on the description, improve it, and report the best score. If `best_score` reaches 95%, copy `best_description` from the JSON output into the `description` field in `SKILL.md` frontmatter.

### Step 3 — Ship

Once at 95%:

```
/release
```

An activation-only fix uses `fix` type → patch bump.

---

## Scenario 5 — Reporting a Bug Without Fixing It

**Start here when:** you've found a problem but aren't going to fix it yourself.

Open an issue directly on GitHub, or:

```
/start The handoff skill's RESUME mode ignores the constraints field entirely
```

`/start` will draft and create the bug issue. Stop there — no branch needed if you're not fixing it.

---

## Skill Structure Reference

```
skills/<skill-name>/
├── SKILL.md                        Required
│   ├── --- (YAML frontmatter)
│   │   ├── name:                   Kebab-case, max 64 chars
│   │   ├── description:            Max 1024 chars — what it does + when to trigger
│   │   └── allowed-tools:          Tools this skill may call
│   └── (Markdown instructions)
├── references/                      Optional — one level deep only
│   └── *.md
└── .workspace/
    └── evals/
        ├── evals.json              Required — functional test cases
        ├── trigger-evals.json      Required — 20 trigger accuracy queries
        └── files/                   Optional — input fixtures
```

### Requirements checklist

- [ ] Directory name: lowercase-hyphenated, max 64 characters
- [ ] `SKILL.md` frontmatter has `name`, `description`, `allowed-tools`
- [ ] `name` matches the directory name exactly
- [ ] `description` written in third person with trigger words and "Make sure to use this skill whenever..."
- [ ] `SKILL.md` body under 500 lines (100 lines if simple — move detail to `references/`)
- [ ] Reference files one level deep — no chains
- [ ] No secrets, credentials, or PII anywhere
- [ ] `evals.json` has at least 2 test cases with `expectations` arrays
- [ ] `trigger-evals.json` has exactly 20 queries (10 should-trigger, 10 should-not-trigger)
- [ ] Trigger accuracy ≥ 95% (19/20 correct) before opening a PR
- [ ] `marketplace.json` updated (new skill only)
- [ ] `README.md` skills table updated (new skill only)

### Writing a good description

The `description` field is the only thing Claude reads when deciding whether to load a skill. It must be self-contained.

**Do:**
- Start with what the skill produces or does: "Generates...", "Reviews...", "Saves..."
- Include specific trigger phrases the user would actually say
- Use "Make sure to use this skill whenever..." to prevent under-triggering
- Name specific file types, keywords, or contexts that distinguish this skill

**Don't:**
- Start with "Use this to..." (weak framing)
- Be so broad that it conflicts with other skills
- Bury the trigger conditions at the end

---

## Running Evals

### Trigger accuracy — `trigger-evals.json`

Tests whether the skill description activates on the right prompts. Uses `run_loop.py` from the `create-a-skill` skill.

```bash
cd ~/.claude/skills/create-a-skill

python3 -m scripts.run_loop \
  --eval-set skills/<skill-name>/.workspace/evals/trigger-evals.json \
  --skill-path skills/<skill-name> \
  --model claude-sonnet-4-6 \
  --max-iterations 5 \
  --verbose
```

The script runs up to 5 iterations, improving the description each time the score is below the threshold. When it exits, check `best_description` in the JSON output — if it's better than the current description, apply it to `SKILL.md`.

**Target: 95% (19/20 correct).**

> **Note on project-local workflow skills:** The three skills in `.claude/skills/` (`start`, `release`, `conventions`) are designed for explicit slash-command invocation and score ~50% on trigger accuracy. This is expected and acceptable — see each skill's `README.md` for the explanation. The 95% target applies to skills in `skills/` only.

### Functional evals — `evals.json`

Tests whether the skill produces the right output. Uses `/create-a-skill` to spawn parallel subagents.

```
/create-a-skill I want to run the functional evals for skills/<skill-name>
```

Results land in `.workspace/iteration-N/`. Review the graded outputs — each `expectations` entry should show `passed: true`. Iterate on `SKILL.md` until outputs are consistently correct.

---

## Reporting Issues

Open a [GitHub issue](https://github.com/psenger/ai-agent-skills/issues) and include:

- The skill name and version or commit SHA
- The exact prompt you used
- What you expected to happen
- What actually happened
- The Claude model and tool (e.g. Claude Code CLI, claude.ai)

Or use `/start` to file it directly from Claude Code.

---

## License

By contributing, you agree that your contributions will be licensed under the project's [MIT License](LICENSE).
