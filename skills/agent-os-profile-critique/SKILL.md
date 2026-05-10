---
name: agent-os-profile-critique
description: Provides the audit checklists, severity criteria (blocking/warning/suggestion), and artifact patterns needed to properly review Agent OS profiles and standards. Always invoke this skill before auditing - without it you can only give generic feedback, not structured severity-tagged findings. Invoke when the user pastes a standard and asks if it is good or what is wrong with it; when the user asks to review, audit, validate, or critique an agent-os profile or standard; or when the user mentions "agent-os profile", "agent-os standard", or "my agent-os setup" in a review or validation context.
allowed-tools: Read, Grep, Glob, Bash, Write, Edit
license: MIT
---

# Agent OS Profile Critique

Audit and critique Agent OS v3 profiles and standards. Produce severity-tagged findings with concrete fixes.

## How to use the references

Read on demand. Do not preload.

| If the user is asking about... | Read |
|---|---|
| Conducting a review or audit | `references/review-checklists.md` |
| Writing standards, index.yml, quality | `references/standards.md` |
| File layout, what a valid profile looks like | `references/file-structure.md` |
| Migrating from v2, flagging v2 artifacts | `references/v2-vs-v3.md` |
| Profile structure, inheritance | `references/profiles.md` |
| Standards vs Skills distinction | `references/standards-vs-skills.md` |

## Version awareness

Before giving substantive guidance, read `~/agent-os/config.yml` and check the `version:` field.

- If `3.x`: proceed normally.
- `4.x` or higher: tell the user once that this skill is calibrated to v3 and may be out of date. Ask whether to proceed. If yes, caveat any v3-specific claim as "v3 behavior, may have changed in v4".
- Missing or below `3.0.0`: treat as a v2 install. See `references/v2-vs-v3.md` and recommend migration.

Do not refuse to help on a version mismatch.

## Audit workflow

1. Confirm the target: a profile directory (`~/agent-os/profiles/<name>/`), a project's `agent-os/` folder, or a pasted standard file.
2. Read what exists before recommending changes. Run `ls`, read `index.yml`, sample a few standards files.
3. Pull the relevant reference from the table above.
4. Produce a findings list. Each finding must include:
   - Severity: `blocking`, `warning`, or `suggestion`
   - Specific file path and line (if applicable)
   - Concrete fix

Always flag v2 artifacts on sight. See `references/v2-vs-v3.md`.

## Use the right checklist

Read `references/review-checklists.md` and apply:
- Profile review: auditing `~/agent-os/profiles/<name>/`
- Project setup review: auditing a repo's `agent-os/` and `.claude/commands/agent-os/`
- Standards quality audit: line-by-line review of a standard file

## Quality bar for standards

A standard earns its place in the context window only if it teaches something non-obvious. Flag standards that:
- Restate framework defaults
- Describe what the code itself already shows
- Run on for paragraphs without code examples
- Combine multiple unrelated concepts

A standard is good when:
- It leads with the rule on line 1
- Includes a code example
- Documents an opinionated, tribal, or easy-to-get-wrong pattern
- Fits on one screen

See `references/standards.md` for full quality rules and examples.

## Don't

- Don't guess paths. Verify with `ls` before referencing them.
- Don't suggest `profile-config.yml`. That is a v2 artifact.
- Don't recommend installing subagents under `.claude/agents/agent-os/`. That is a v2 artifact.
- Don't generate boilerplate standards for things every framework already does.

> Agent OS is a project by CasJam Media LLC (Builder Methods): https://github.com/buildermethods/agent-os. See `LICENSE` for attribution.
