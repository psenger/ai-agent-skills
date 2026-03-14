---
name: git-commit-pr-message
description: >
  Generate git commit messages, PR titles/descriptions, and changelog entries.
  Analyzes staged changes, enforces Conventional Commits, scans for sensitive
  content, links tickets (GitHub Issues / Jira), and updates CHANGELOG.md.
  Triggers on: "commit", "create a PR", "push", "changelog", "release", or
  when the user is ready to commit or open a pull request.
disable-model-invocation: true
allowed-tools: Bash(git *) Bash(gh *) Read Grep Glob
argument-hint: "[commit | pr | changelog | release]"
compatibility: Requires git. Optional gh CLI for PR creation and issue lookups.
---

# Git Commit & PR Message Skill

Generates professional git commit messages, pull request titles and descriptions,
and changelog entries. Enforces Conventional Commits, scans for sensitive content,
and links tickets from GitHub Issues or Jira.

---

## When This Skill Activates

Trigger when the user:
- Asks to commit, push, or create a PR
- Asks to generate a commit message or PR description
- Asks to update the changelog
- Says they are "done" or "ready to commit/push/PR"
- Invokes `/git-commit-pr-message`

---

## Step 0 — Tooling Detection

Before doing anything, detect available tooling:

1. **Check for `gh` CLI:**
   ```bash
   command -v gh && gh auth status
   ```
   If `gh` is available and authenticated, use it for PR creation and issue lookups.
   If not, fall back to manual instructions.

2. **Check for GitHub MCP server:**
   Look for an MCP server named `github` or `gh` in the current session's available
   tools. If an MCP GitHub server is available, prefer it for issue lookups and PR
   creation over the `gh` CLI.

3. **Set capabilities flag:**
   - `CAN_GH_CLI` — true if `gh` is installed and authenticated
   - `CAN_GH_MCP` — true if a GitHub MCP server is available
   - If neither is available, warn the user that PR creation will require manual steps

---

## Step 1 — Gather Context

Run these commands **in parallel** to understand the current state:

```bash
# 1. Staged and unstaged changes
git diff --cached --stat
git diff --cached
git diff --stat
git status -u

# 2. Recent commit history (for style matching and branch context)
git log --oneline -20

# 3. Current branch and tracking
git branch --show-current
git rev-parse --abbrev-ref @{upstream} 2>/dev/null

# 4. If on a feature branch, get full diff against base
BASE_BRANCH=$(git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null)
git log --oneline $BASE_BRANCH..HEAD 2>/dev/null
git diff $BASE_BRANCH..HEAD --stat 2>/dev/null
```

If there are **no staged changes and no unstaged changes**, stop and tell the user
there is nothing to commit.

---

## Step 2 — Sensitive Content Scan

**This step is MANDATORY. Never skip it.**

Before generating any commit message, scan all staged changes for sensitive content.
Run these scans against the staged diff (`git diff --cached`):

### Patterns to Flag

| Category | Regex / Pattern |
|---|---|
| API keys | `sk-[a-zA-Z0-9]`, `pk-[a-zA-Z0-9]`, `AKIA[A-Z0-9]` |
| Tokens | `ghp_`, `gho_`, `github_pat_`, `xoxb-`, `xoxp-`, `Bearer [a-zA-Z0-9]` |
| Passwords | `password\s*=\s*['"](?!$)`, `passwd`, `pwd=`, `secret\s*=\s*['"](?!$)` |
| Connection strings | `://[^:]+:[^@]+@` (user:pass in URL) |
| Private keys | `BEGIN.*PRIVATE KEY`, `BEGIN OPENSSH PRIVATE` |
| Env values | Actual values assigned to sensitive env vars (not placeholders) |
| Company/vendor names | Check against project-specific deny list if one exists |
| Internal URLs | `*.internal.*`, `*.corp.*` (non-localhost) |
| Hardcoded IPs | Non-RFC1918 IPv4 addresses |
| Email addresses | Personal or corporate email patterns in code (not config templates) |

### On Detection

If ANY sensitive content is found:

1. **STOP** — do not create the commit
2. List each finding with file path, line number, and the matched pattern
3. Ask the user to confirm removal or intentional inclusion
4. Only proceed after explicit user confirmation

---

## Step 3 — Ask for Ticket Reference

Ask the user:

> Is there a ticket or issue number for this change?
> - GitHub Issue: `#42`
> - Jira: `PROJ-1234`
> - None

**Rules for ticket linking:**

- **GitHub Issues — closing keywords:**
  GitHub recognizes these keywords (case-insensitive, optional colon after):
  `close`, `closes`, `closed`, `fix`, `fixes`, `fixed`, `resolve`, `resolves`, `resolved`

  Use a closing keyword when the work **fully resolves** the issue:
  - `Closes #42` or `Resolves #42` for features
  - `Fixes #42` for bug fixes
  All closing keywords behave identically — GitHub auto-closes the issue on merge
  to the default branch. The distinction (Closes vs Fixes) is a team convention only.

  When the work does **not** fully resolve the issue, use a bare reference without
  a closing keyword. GitHub still creates a link from the `#42` mention:
  - `Ref #42` — related context (note: `Ref` is not a GitHub keyword, but `#42` links)
  - `Part of #42` — incremental work toward an issue

  Cross-repo references: `Fixes owner/repo#42`

- **Jira tickets** — Jira detects ticket keys by pattern-matching `PROJ-1234`
  (uppercase project key, hyphen, number) anywhere in commit messages, branch names,
  or PR titles. No special keyword is needed — the key itself triggers the link.
  Include the key directly in the footer: `PROJ-1234`

- **Multiple references** — Combine on one line: `Closes #42, CHAT-1234`

- If the user says "none", omit the footer entirely. Do not invent ticket numbers.

---

## Step 4 — Generate Commit Message

Analyze the staged diff and generate a commit message following the
**Conventional Commits** specification.

### Format

```
<type>(<scope>): <short summary>

<body — optional but recommended for non-trivial changes>

<footer — ticket references>
```

### Type Selection

Determine the type from the nature of the changes:

| Type | When to Use |
|---|---|
| `feat` | New feature or capability |
| `fix` | Bug fix |
| `docs` | Documentation only (README, CONTRIBUTING, comments) |
| `test` | Adding or updating tests |
| `refactor` | Code restructuring with no functional change |
| `perf` | Performance improvement |
| `chore` | Build, tooling, dependencies, CI/CD |
| `style` | Formatting, whitespace, semicolons (no logic change) |
| `ci` | CI/CD pipeline changes |
| `build` | Build system or external dependency changes |

### Scope Selection

Derive scope from the primary area of change:

- Use directory or module names: `bridge`, `sse`, `agent`, `redis`, `ports`, `mcp`
- For cross-cutting changes use multiple scopes: `bridge,agent`
- For project-wide changes omit scope: `chore: upgrade dependencies`

### Rules

1. **Subject line** — imperative mood, lowercase, no period, under 72 characters
2. **Body** — explain *what* and *why*, not *how*. Wrap at 72 characters.
   Skip the body only for truly trivial changes (typos, formatting).
3. **Footer** — ticket references from Step 3. One per line.
4. **NEVER include a Co-Authored-By line** — the user takes sole credit
5. **Match the project's existing commit style** — review the `git log` output
   from Step 1 and adapt tone/detail level accordingly

### Presenting the Message

Present the generated commit message to the user in a code block.
Ask for confirmation before committing:

> Here's the commit message I've drafted:
>
> ```
> <message>
> ```
>
> Want me to commit with this message, or would you like to adjust it?

Do NOT commit without user confirmation.

---

## Step 5 — Create the Commit

Once confirmed:

1. Stage any files the user has indicated (if not already staged)
2. Create the commit using a HEREDOC to preserve formatting:
   ```bash
   git commit -m "$(cat <<'EOF'
   <commit message here>
   EOF
   )"
   ```
3. Run `git status` after to verify success
4. Show the user the commit hash and summary

---

## Step 6 — Update Changelog

After a successful commit, check if a `CHANGELOG.md` exists at the project root.

This skill follows [Keep a Changelog v1.1.0](https://keepachangelog.com/en/1.1.0/).

### If CHANGELOG.md Exists

1. Read the file
2. Add a new entry under the `## [Unreleased]` section
3. Place the entry in the correct subsection based on commit type.
   Sections MUST appear in this order (per keepachangelog convention):

   | Commit Type | Changelog Section |
   |---|---|
   | `feat` | **Added** — new features |
   | `fix` | **Fixed** — bug fixes |
   | `refactor`, `perf` | **Changed** — changes in existing functionality |
   | `BREAKING CHANGE` | **Changed** (flag prominently) |
   | Deprecation notices | **Deprecated** — soon-to-be removed features |
   | Removed functionality | **Removed** — now removed features |
   | Vulnerability fixes | **Security** — vulnerability fixes |
   | `docs` | *(skip unless user-facing documentation)* |
   | `test` | *(skip)* |
   | `chore` | *(skip unless dependency update or breaking)* |
   | `style`, `ci`, `build` | *(skip)* |

4. Format the entry as a single line:
   ```
   - Short description of change ([#42](https://github.com/user/repo/issues/42))
   ```
   or for Jira:
   ```
   - Short description of change ([PROJ-1234](https://jira.example.com/browse/PROJ-1234))
   ```

5. If the subsection doesn't exist yet under `[Unreleased]`, create it

6. Stage and amend the previous commit to include the changelog update:
   ```bash
   git add CHANGELOG.md
   git commit --amend --no-edit
   ```

### If CHANGELOG.md Does Not Exist

Ask the user:

> There's no CHANGELOG.md yet. Would you like me to create one?

If yes, create it following the [Keep a Changelog v1.1.0](https://keepachangelog.com/en/1.1.0/)
format. Read `${CLAUDE_SKILL_DIR}/references/examples.md` for the exact template. Add the current
commit as the first entry under `## [Unreleased]`.

---

## Step 7 — Push (If Requested)

Only push if the user explicitly asks. If they do:

1. Check if the branch tracks a remote:
   ```bash
   git rev-parse --abbrev-ref @{upstream} 2>/dev/null
   ```
2. If no upstream, push with `-u`:
   ```bash
   git push -u origin $(git branch --show-current)
   ```
3. If upstream exists:
   ```bash
   git push
   ```
4. **Never force push** unless the user explicitly requests it. If a force push
   is needed, warn about the consequences and ask for confirmation.

---

## Step 8 — Pull Request (If Requested)

Only create a PR if the user explicitly asks. When they do:

### Gather PR Context

1. Get all commits on the branch since it diverged from the base:
   ```bash
   BASE=$(git merge-base HEAD main 2>/dev/null || git merge-base HEAD master)
   git log --oneline $BASE..HEAD
   git diff $BASE..HEAD --stat
   ```
2. Ask for the ticket/issue number if not already provided in Step 3
3. Determine the base branch (usually `main`)

### Generate PR Title

- Same format as commit subject: `<type>(<scope>): <short summary>`
- Under 70 characters
- If the branch has a single commit, use its subject line
- If multiple commits, synthesize a title that covers the overall change

### Generate PR Description

Use this template:

```markdown
## Summary

<1-3 bullet points describing what changed and why>

## Ticket

<GitHub Issue or Jira link, or "N/A">

## Changes

<Bulleted list of specific changes, grouped by area>

## Test Plan

- [ ] <Testing steps or checklist>

## Changelog

<Copy of the changelog entry added in Step 6, or "N/A">
```

### Create the PR

Present the title and description to the user for confirmation. Then:

**If `gh` CLI is available (`CAN_GH_CLI`):**
```bash
gh pr create --title "<title>" --body "$(cat <<'EOF'
<description>
EOF
)"
```

**If GitHub MCP is available (`CAN_GH_MCP`):**
Use the MCP tool to create the PR with the same title and body.

**If neither is available:**
Output the title and description for the user to copy-paste manually.

After creation, display the PR URL to the user.

---

## Step 9 — Release Changelog (If Requested)

Only perform this step if the user explicitly asks to "cut a release", "tag a release",
"prepare a release", or "release version X.Y.Z".

### Workflow

1. **Determine the version number.** Ask the user if not provided:
   > What version number should this release be? (e.g. 1.2.0)

2. **Read CHANGELOG.md** and verify `## [Unreleased]` has entries. If empty, warn
   the user and ask if they want to proceed with an empty release.

3. **Rename the Unreleased section** to the versioned release:
   ```
   ## [X.Y.Z] - YYYY-MM-DD
   ```
   Use today's date in ISO 8601 format.

4. **Add a fresh `## [Unreleased]` section** above the new release with empty
   subsection placeholders:
   ```markdown
   ## [Unreleased]
   ```

5. **Update comparison links** at the bottom of the file. These are essential per
   keepachangelog 1.1.0. Detect the repo URL from `git remote get-url origin`.

   For the first release:
   ```markdown
   [unreleased]: https://github.com/user/repo/compare/vX.Y.Z...HEAD
   [X.Y.Z]: https://github.com/user/repo/releases/tag/vX.Y.Z
   ```

   For subsequent releases:
   ```markdown
   [unreleased]: https://github.com/user/repo/compare/vX.Y.Z...HEAD
   [X.Y.Z]: https://github.com/user/repo/compare/vPREVIOUS...vX.Y.Z
   ```

   If comparison links already exist, update the `[unreleased]` link and add
   the new version link below it.

6. **Commit the changelog update:**
   ```bash
   git add CHANGELOG.md
   git commit -m "$(cat <<'EOF'
   chore(release): prepare changelog for vX.Y.Z
   EOF
   )"
   ```

7. **Optionally tag the release** (ask user):
   > Would you like me to create a git tag `vX.Y.Z`?

   If yes:
   ```bash
   git tag -a vX.Y.Z -m "Release vX.Y.Z"
   ```

8. Show the user a summary of the release changelog and next steps (push, create
   GitHub release, etc).

---

## Behavioral Rules

These rules apply across ALL steps:

1. **Never commit without user confirmation** — always present the message first
2. **Never skip the sensitive content scan** — this is a hard gate
3. **Never include Co-Authored-By lines** — the user takes sole credit
4. **Never push without being asked** — committing and pushing are separate actions
5. **Never create a PR without being asked** — explicit request only
6. **Never invent ticket numbers** — only use what the user provides
7. **Never force push without warning** — explain consequences, get confirmation
8. **Match the project's commit style** — adapt to what's already in `git log`
9. **Keep subject lines under 72 characters** — hard limit
10. **Use imperative mood** — "add", "fix", "update", not "added", "fixed", "updated"

---

## Reference Files

Load `${CLAUDE_SKILL_DIR}/references/examples.md` for:
- Commit message examples (all types, with GitHub and Jira tickets)
- PR title and description examples (feature, fix, refactor)
- Changelog format, release workflow, and section mapping
- Ticket reference format patterns (GitHub and Jira)
- Sensitive content scan patterns
