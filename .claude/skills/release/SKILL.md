---
name: release
metadata:
  internal: true
description: >
  Ships completed work in the ai-agent-skills repository. Two phases depending on
  context: WRAP UP (on a feature branch with committed work — updates CHANGELOG,
  README, marketplace.json, commits, pushes, creates a PR) and CUT RELEASE (on main
  after a merge — determines semver bump, updates CHANGELOG version section, tags,
  pushes, creates a GitHub draft release). Use when the user says "ship this",
  "I'm done", "create a PR", "cut a release", "tag a release", "wrap this up", or
  "release it". Always checks GitHub auth first. Load the `conventions` skill
  for commit and PR formatting rules.
allowed-tools: Read, Edit, Bash(git *), Bash(gh *), mcp__github__get_me, mcp__github__create_pull_request, mcp__github__pull_request_read, mcp__github__list_releases, mcp__github__get_latest_release
---

# Release

Ships completed work. The skill detects context and runs the right phase:

- **On a feature branch with committed work** → WRAP UP phase
- **On main after a merge** → CUT RELEASE phase

For all message formatting, follow the `conventions` skill.

---

## Step 0 — Auth & Identity (always)

Check for a GitHub MCP server in available tools. If none:
```bash
gh auth status
```
Stop if neither is available: *"I need the GitHub MCP server or `gh` CLI authenticated. Run `gh auth login`."*

Confirm identity — use `mcp__github__get_me` if the GitHub MCP server is available, otherwise:
```bash
gh api user --jq '"@\(.login) — \(.name)"'
```
Show the result and ask: *"I'll be acting as @username — is that right?"* Wait for confirmation.

---

## WRAP UP Phase

Triggered when on any non-main branch (`feature/`, `fix/`, `chore/`, `refactor/`, `test/`, etc.) with a clean working tree.

### Step 1 — Verify State

```bash
git branch --show-current     # must not be main
git status --porcelain        # must be empty — all work committed
```
If the tree is dirty, stop: *"You have uncommitted changes. Commit or stash them first."*

### Step 2 — Detect What Changed

```bash
git diff main...HEAD --name-only
```

Determine:
- Was a **new skill added**? Look for a new directory under `skills/` not present on main.
- Was an **existing skill modified**? Look for changes inside `skills/<name>/`.
- Is this a **bug fix, refactor, or docs change**? Look at changed files outside `skills/`.

Derive the issue number from the branch name (e.g. `feature/14-add-handoff-skill` → `#14`).
If none found, ask the user for the issue number.

### Step 3 — Update Admin Files

**CHANGELOG.md** — add a bullet to `## [Unreleased]` under the correct subsection:
- New skill → `### Added`
- Updated skill → `### Changed`
- Bug fix → `### Fixed`

Bullet format (see `conventions` skill):
```
- **skill-name** — <what changed and why>. ([#N](issue-url))
```

**README.md** — only if a new skill was added:
- Add a row to the skills table
- Add a `### skill-name` prose section following the existing pattern

**`.claude-plugin/marketplace.json`** — only if a new skill was added:
```json
{
  "name": "<skill-name>",
  "source": "./skills/<skill-name>",
  "description": "<description from SKILL.md frontmatter>",
  "version": "1.0.0"
}
```

### Step 4 — Commit Admin Updates

```bash
git add CHANGELOG.md README.md .claude-plugin/marketplace.json
git commit -m "chore(<skill-name>): update changelog, readme, and marketplace"
```
Only stage files that actually changed.

### Step 5 — Push and Create PR

```bash
git push -u origin <branch-name>
```

Create a PR using the repo's PR template (`.github/pull_request_template.md`):
```bash
gh pr create \
  --draft \
  --title "<type>(<scope>): <subject>" \
  --body "$(cat <<'EOF'
## What
<brief description of the change>

## Why
<why this change is needed>

## Type of Change
- [x] <tick the correct box from the template>

## Skill Checklist
- [x] `SKILL.md` has valid YAML frontmatter (`name`, `description`, `allowed-tools`)
- [x] `name` is lowercase-hyphenated and matches the directory name
- [x] `description` is written in third person with trigger words
- [x] Reference files are in `references/` (one level deep)
- [x] `SKILL.md` is under 500 lines
- [x] No secrets, credentials, or PII committed
- [x] `.claude-plugin/marketplace.json` updated (if new skill)
- [x] `README.md` skills table updated (if new skill)

## Testing
- [ ] Tested locally by invoking the skill with a realistic prompt
- [ ] Verified the skill activates correctly (not confused with another skill)

Closes #<issue-number>
EOF
)"
```

Print the PR URL. Tell the user: *"Draft PR created: <URL>. Review it, mark it ready for review, and merge to main. Then run `/release` again on main to cut the release."*

---

## CUT RELEASE Phase

Triggered when on `main` with a clean working tree.

### Step 1 — Pre-flight

```bash
git branch --show-current              # must be: main
git status --porcelain                 # must be empty
git fetch origin
git rev-list HEAD..origin/main --count # must be: 0
```
Abort clearly if any check fails.

### Step 2 — Determine Version

```bash
git describe --tags --abbrev=0          # last tag, e.g. v1.0.0
git log <last-tag>..HEAD --oneline      # commits since last tag
```

Apply semver rules (from `conventions` skill):
- `BREAKING CHANGE` footer or `type!:` → **major**
- `feat` → **minor**
- `fix`, `chore`, `docs`, `refactor`, `test` → **patch**

Present the proposed version and the commits that drove the decision.
**Wait for explicit confirmation before proceeding.**

### Step 3 — Update CHANGELOG.md

Three edits in order:
1. Insert `## [Unreleased]\n\n` above the current `## [Unreleased]` heading
2. Rename the existing `## [Unreleased]` to `## [X.Y.Z] - YYYY-MM-DD` (today's date)
3. Update comparison links at the bottom:
   - Add: `[X.Y.Z]: https://github.com/psenger/ai-agent-skills/compare/<last-tag>...vX.Y.Z`
   - Update: `[Unreleased]: https://github.com/psenger/ai-agent-skills/compare/vX.Y.Z...HEAD`

### Step 4 — Commit and Tag

```bash
git add CHANGELOG.md
git commit -m "chore(release): cut vX.Y.Z release"
git tag -a vX.Y.Z -m "Release vX.Y.Z"
```

### Step 5 — Push

```bash
git push origin main
git push origin vX.Y.Z
```

### Step 6 — Create Draft Release

Extract the release body from the `## [X.Y.Z]` CHANGELOG section (down to the next `## [`):

```bash
gh release create vX.Y.Z \
  --draft \
  --title "vX.Y.Z" \
  --notes "<extracted changelog section>"
```

### Step 7 — Done

Print:
```
Draft release created: <URL>

Review on GitHub and click Publish when ready.
Publishing triggers any CI release workflows.
```

Do **not** publish the release — the user does this manually.