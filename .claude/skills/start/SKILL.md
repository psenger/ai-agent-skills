---
name: start
publish: false
description: >
  Begins a new piece of work in the ai-agent-skills repository. Two modes: EXISTING
  ISSUE (user provides a GitHub issue number or URL — fetches it, cuts the correct
  branch) and NEW ISSUE (user describes what needs doing — classifies as feature or
  bug, drafts a structured requirement using the repo's issue template, confirms with
  the user, creates the GitHub issue, then cuts the branch). Always checks GitHub auth
  first and confirms user identity. Use when the user says "start work on #14",
  "begin issue", "start a new feature", "I need to build X", "create an issue for Y",
  or passes a GitHub issue URL. Load the `conventions` skill for branch naming rules.
allowed-tools: Bash(git *), Bash(gh *), mcp__github__get_me, mcp__github__issue_read, mcp__github__issue_write, mcp__github__create_branch, mcp__github__list_branches
---

# Start

Begins a new piece of work. Two modes — the skill determines which applies:

- **User provides an issue number, URL, or reference** → EXISTING ISSUE mode
- **User provides a description of what needs doing** → NEW ISSUE mode

For branch naming and commit format, follow the `conventions` skill.

---

## Step 0 — Auth & Identity

Check for a GitHub MCP server in available tools. If none, run:
```bash
gh auth status
```
If neither is available, stop: *"I need the GitHub MCP server or `gh` CLI authenticated to continue. Run `gh auth login` or connect the GitHub MCP server."*

Confirm identity — use `mcp__github__get_me` if the GitHub MCP server is available, otherwise:
```bash
gh api user --jq '"@\(.login) — \(.name)"'
```
Show the result and ask: *"I'll be acting as @username — is that right?"* Wait for confirmation before continuing.

---

## EXISTING ISSUE Mode

### Step 1 — Fetch the Issue

From the issue number or URL, fetch the issue:
```bash
gh issue view <number> --json number,title,body,labels,url
```
Display the issue number, title, and first few lines of the body. Ask: *"Is this the right issue to work on?"* Wait for confirmation.

### Step 2 — Start from Main

```bash
git checkout main
git pull origin main
git status --porcelain   # must be empty — abort if dirty
```

### Step 3 — Cut the Branch

Derive the slug from the issue title: lowercase, hyphenated, 2–4 meaningful words, no stop words.

Determine branch prefix from issue labels:
- `bug` label → `fix/`
- `enhancement` or `feature` label → `feature/`
- Anything else → `feature/` by default

```bash
git checkout -b <prefix><issue-number>-<slug>
```
Example: `feature/14-add-handoff-skill` or `fix/23-vault-scribe-toc`

Report: *"Branch `feature/14-add-handoff-skill` created from main. You're ready to work."*

---

## NEW ISSUE Mode

### Step 1 — Classify the Work

From the user's description, determine: is this a **feature** (new capability, new skill, enhancement) or a **bug** (something broken, incorrect behaviour, wrong output)?

If ambiguous, ask one question: *"Is this adding something new or fixing something broken?"*

### Step 2 — Draft the Issue

Read the appropriate template from `.github/ISSUE_TEMPLATE/`:
- Feature → `.github/ISSUE_TEMPLATE/feature_request.md`
- Bug → `.github/ISSUE_TEMPLATE/bug_report.md`

Fill in every section of the template from the user's description. Show the completed draft to the user. Ask: *"Does this capture what you need? Edit anything before I submit it."* Wait for approval.

### Step 3 — Create the Issue

```bash
gh issue create \
  --title "<title>" \
  --body "<filled template body>" \
  --label "<enhancement|bug>"
```

Use `enhancement` for features (matches `feature_request.md` template label), `bug` for bugs.

Capture the returned issue number and URL. Report: *"Issue #N created: <URL>"*

### Step 4 — Cut the Branch

Proceed identically to EXISTING ISSUE Steps 2–3, using the new issue number.