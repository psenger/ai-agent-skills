# The 5 Slash Commands

All commands live in `.claude/commands/agent-os/` (project) and `~/agent-os/commands/agent-os/` (source).

## /discover-standards

Extracts tribal knowledge from a codebase into documented standards.

**Process:**
1. Determine focus area (auto-detect, or specify: `/discover-standards api`)
2. Analyze 5–10 representative files for unusual / opinionated / consistent / tribal patterns
3. Ask 1–2 targeted "why does this exist?" questions per pattern
4. Draft standards and ask the user to confirm, edit, or skip each
5. Update `index.yml`
6. Offer to continue in another area

Runs `/index-standards` automatically as its final step.

**When to run:** on existing codebases, after a major refactor, when onboarding, periodically to capture drift.

## /index-standards

Rebuilds and maintains `agent-os/standards/index.yml`.

- Scans for all standards files
- Adds missing entries (prompts for descriptions)
- Removes entries for deleted files
- Alphabetizes and cleans up

**When to run:** after manually creating or deleting standards files, or when `/inject-standards` auto-suggestions seem off.

## /inject-standards

Deploys relevant standards into the current context.

**Auto-suggest mode:**
```
/inject-standards
```
Reads `index.yml`, matches descriptions against the conversation, presents 2–5 relevant standards to confirm.

**Explicit mode:**
```
/inject-standards api
/inject-standards api/response-format
/inject-standards api/response-format api/auth
```

**Output format depends on the scenario:**
- **Conversation:** reads full standards content directly into context.
- **Creating a skill:** asks whether to embed content (self-contained) or `@`-file references (stays current).
- **Plan mode:** same choice as creating a skill, embed snapshot or reference files.

Also surfaces related Skills from `.claude/skills/`. Names them, does not invoke them.

## /plan-product

Creates foundational product documentation through interactive conversation. Generates in `agent-os/product/`:

- `mission.md`: vision, target users, core problems.
- `roadmap.md`: phased plan with prioritized features.
- `tech-stack.md`: technical stack choices.

**When to run:** new project setup, before using `/shape-spec`, onboarding team members.

`/shape-spec` reads `agent-os/product/` to align specs with product goals.

## /shape-spec

Run **inside plan mode**. Gathers context and creates a persistent spec folder.

**Process:**
1. `/plan` to enter plan mode
2. `/shape-spec`
3. Answer shaping questions (what we're building, visuals, reference code, product alignment, applicable standards)
4. Review the plan (Task 1 = save spec documentation)
5. Approve and execute

**Output folder:**
```
agent-os/specs/YYYY-MM-DD-HHMM-<slug>/
├── plan.md         # Full implementation plan
├── shape.md        # Scope, decisions, context
├── references.md   # Pointers to similar code
└── standards.md    # Full content of relevant standards
```

**Use `/shape-spec` when:** decisions need to persist, you have visuals, significant feature.
**Use plain plan mode when:** quick task, no persistence needed.
