---
name: conventions
description: >
  Defines the commit message, branch naming, pull request, and release note
  conventions for the ai-agent-skills repository. Make sure to load this skill
  whenever writing a commit message, naming a branch, drafting a PR title or body,
  or writing CHANGELOG entries in this repo. Use when the user asks "how should
  I format this commit", "what's the branch naming convention", "how do I write
  the PR", "what commit type should I use", or before any git commit, PR creation,
  release note, or CHANGELOG task in this project.
allowed-tools: Read
---

# Conventions — ai-agent-skills

---

## Commit Messages

Format: `type(scope): subject`

- **Subject:** imperative mood, lowercase, no trailing period, ≤72 characters
- **Scope:** the skill name (`vault-scribe`, `handoff`) or a repo area (`release`, `ci`, `readme`)
- **Body:** optional — explain *why*, not *what*; wrap at 72 chars
- **Footer:** `Closes #N` or `Fixes #N` for GitHub issues; `BREAKING CHANGE: <desc>` for breaking changes

### Types

| Type       | When |
|------------|---------------------------------------------------------|
| `feat`     | New skill or new capability in an existing skill        |
| `fix`      | Bug fix in a skill's behaviour or instructions          |
| `chore`    | Release commits, tooling, config — no production change |
| `docs`     | README, CHANGELOG, CONTRIBUTING only                    |
| `refactor` | Skill restructure with no behaviour change              |
| `test`     | Eval additions or changes                               |

### Release commit — always exactly:
```
chore(release): cut vX.Y.Z release
```

### Examples
```
feat(handoff): add RESUME workflow and proactive suggestion trigger
```
```
fix(vault-scribe): prevent incompatible TOC directives

Closes #1
```

---

## Branch Names

Pattern: `type/issue-number-short-description`

```
feature/14-add-handoff-skill
fix/23-vault-scribe-toc
chore/release-v1-1-0
```

- `feature/` for new skills or new capabilities
- `fix/` for bug fixes
- `chore/` for release and tooling work
- Always include the issue number when one exists
- 2–4 words, hyphenated, no version dots (use dashes)

---

## Pull Requests

**Title:** same format as a commit — `type(scope): subject`

**Body:**
```markdown
## Summary
- <bullet 1>
- <bullet 2>

## Issue
Closes #N

## Test plan
- [ ] Skill activates on expected triggers
- [ ] Output matches documented format
- [ ] No regressions in adjacent skills
```

- 2–4 summary bullets
- Always link the issue
- Test plan as checkboxes

---

## CHANGELOG Entries (Keep a Changelog 1.1.0)

```markdown
### Added
- **skill-name** — What was added and why it matters. ([#N](url))

### Changed
- **skill-name** — What changed and the user-visible impact.

### Fixed
- **skill-name** — What was broken and what was fixed. ([#N](url))
```

- Bold skill name, em dash, plain English, issue link at end
- `### Added` for new skills, `### Changed` for updates, `### Fixed` for bugs
- One bullet per logical change

---

## Versioning

Semver from conventional commits since last tag:

| Commit                                     | Bump  |
|--------------------------------------------|-------|
| `BREAKING CHANGE` or `type!:`              | major |
| `feat`                                     | minor |
| `fix`, `chore`, `docs`, `refactor`, `test` | patch |

New skill = `feat` = **minor** bump.
Tag format: `vX.Y.Z` (annotated tag).
