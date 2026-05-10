---
name: agent-os-assist
description: Agent OS reference for installation, slash commands, profiles, and ticket-to-spec workflows. This skill holds reference documentation not in Claude's training; always invoke it before answering any Agent OS question. Invoke whenever the user message contains any of - "agent-os", "Agent OS", "agent os", "~/agent-os", "/agent-os/", "shape-spec", "inject-standards", "discover-standards", "index-standards", "plan-product". Also invoke when the user asks to - turn a Jira ticket, GitHub issue number, or GitHub issue URL into a spec or plan; set up corporate or enterprise coding standards; commit or version-control an agent-os folder; configure profile inheritance in config.yml; write their first standard after installing agent-os; or recover a broken spec without losing history.
allowed-tools: Read, Grep, Glob, Bash, Write, Edit
license: MIT
---

# Agent OS Assist

Help users install, configure, and use Agent OS v3, the Builder Methods system for managing coding standards in AI-assisted development.

## How to use the references

Read on demand. Do not preload.

| If the user is asking about... | Read |
|---|---|
| "How do I get started with..." workflows | `references/getting-started.md` |
| Installing or scaffolding | `references/installation.md` |
| Slash commands behavior or process | `references/commands.md` |
| Profiles, inheritance, `config.yml` | `references/profiles.md` |
| Writing standards, index.yml, quality | `references/standards.md` |
| File layout, what to commit | `references/file-structure.md` |
| Migrating from v2 | `references/v2-vs-v3.md` |
| Standards vs Skills distinction | `references/standards-vs-skills.md` |

## Version awareness

Before giving substantive guidance, read `~/agent-os/config.yml` and check the `version:` field.

- If `3.x`: proceed normally.
- `4.x` or higher: tell the user once that this skill is calibrated to v3 and may be out of date. Ask whether to proceed. If yes, caveat any v3-specific claim as "v3 behavior, may have changed in v4".
- Missing or below `3.0.0`: treat as a v2 install. See `references/v2-vs-v3.md` and recommend migration.

Do not refuse to help on a version mismatch.

## Core facts

- v3 released January 2026. Subagents and dedicated implementation commands were retired. Plan mode plus `/shape-spec` handles spec writing now.
- Two-part install: base at `~/agent-os/`, project at `<repo>/agent-os/` plus `<repo>/.claude/commands/agent-os/`.
- Profiles are folders. Any directory under `~/agent-os/profiles/` containing a `standards/` subfolder is a valid profile. No registration required.
- Inheritance lives in `~/agent-os/config.yml`, not in per-profile `profile-config.yml` files. That was v2. Child overrides parent when filenames collide.
- Five slash commands: `/discover-standards`, `/index-standards`, `/inject-standards`, `/plan-product`, `/shape-spec`.
- Standards are declarative (what conventions). Skills are procedural (how to do tasks). They compose: a Skill can `@`-reference standards.
- `index.yml` drives auto-suggest for `/inject-standards`. Vague descriptions break matching.

## Default workflow

1. Identify the goal: installing, getting started, running a command, turning a ticket into a spec, or recovering a broken spec.
2. Confirm the target: base install (`~/agent-os/`), a project (`<repo>/agent-os/`), or a profile (`~/agent-os/profiles/<name>/`).
3. Pull the relevant reference from the table above.
4. Be concrete. When explaining config, show the exact YAML. When explaining commands, show the exact slash command.

## Ticket-to-spec workflow

When the user provides a Jira or GitHub ticket (key, URL, or pasted content):
1. Read `references/commands.md` to confirm the correct command is `/shape-spec`.
2. Help the user extract the scope, constraints, and acceptance criteria from the ticket.
3. Guide them to run `/shape-spec` in plan mode with that context.
4. Do not fetch URLs directly. Ask the user to paste the ticket content if only a URL is provided.

## Spec recovery

When a spec produced by `/shape-spec` is wrong:
1. Diagnose which layer failed: shape (scope), plan (steps), standards (conventions), or drift (context lost).
2. Recommend editing the spec file directly or re-running `/shape-spec` with refined input.
3. Never recommend discarding the conversation history.

## Don't

- Don't invent commands or flags. The canonical list is in `references/commands.md`.
- Don't suggest `profile-config.yml`. That is a v2 artifact.
- Don't recommend installing subagents under `.claude/agents/agent-os/`. That is a v2 artifact.
- Don't guess paths. Verify with `ls` before referencing them.

> Agent OS is a project by CasJam Media LLC (Builder Methods): https://github.com/buildermethods/agent-os. See `LICENSE` for attribution.
