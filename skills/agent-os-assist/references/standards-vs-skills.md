# Standards vs Skills

Standards and Skills solve different problems. Use the right tool, and compose them when both apply.

## Comparison

| | Standards | Skills |
|---|---|---|
| **Type** | Declarative: what conventions | Procedural: how to do tasks |
| **Location** | `agent-os/standards/` | `.claude/skills/` |
| **Invocation** | Explicit via `/inject-standards` (or auto-suggest from `index.yml`) | Auto-detected by Claude from skill descriptions |
| **Loaded** | Only when injected | Description always in context; body when triggered |
| **Best for** | "We use X envelope for API responses" | "When making a PDF report, do steps 1–5" |

## Use `/inject-standards` when

- You want explicit control over which conventions apply
- The work spans multiple domains (API + DB + naming)
- You're authoring a Skill and want to bake in conventions

## Use Skills when

- There's a repeatable procedure to automate
- You want auto-detection ("when the user mentions X, do Y")
- The task is self-contained with clear inputs and outputs

## Best pattern: compose them

A Skill provides the procedure; standards provide the conventions. The Skill `@`-references the standards files so they stay current:

```markdown
Before implementing, read:
- @agent-os/standards/api/response-format.md
- @agent-os/standards/api/error-handling.md
```

This combination gives:
- **Procedural automation** from the Skill (the *how*)
- **Declarative conventions** from the Standards (the *what*)
- **Single source of truth.** When standards change, the Skill picks up the new content automatically.

If a Skill is bundled or distributed externally and can't rely on a project's standards being present, embed the content instead of referencing it. `/inject-standards` will offer this choice when invoked inside Skill creation.
