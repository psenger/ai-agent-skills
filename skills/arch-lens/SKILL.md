---
name: arch-lens
description: >
  Explores a codebase for architectural friction through the lens of Ousterhout's
  deep-module principle (small interface, large implementation). Seven-step interactive
  workflow: an Explore sub-agent navigates the codebase organically — the friction it
  experiences IS the signal. Surfaces candidate clusters with coupling reasons, call
  patterns, shared types, dependency categories, and existing tests that a boundary
  test would replace. User picks what to explore, frames the problem, then 3–4 parallel
  sub-agents design competing deep-module interfaces. Chosen design becomes a structured
  RFC action file readable by GitHub MCP or ROVO (Jira) MCP. Use when the user says
  "arch review", "find shallow modules", "module depth", "deep module", "Ousterhout",
  "testability audit", "surface coupling", "design interfaces", "RFC issues",
  or "architectural friction".
allowed-tools: Read Grep Glob Write Bash(git *)
argument-hint: "[path/to/scope]"
compatibility: Requires git for churn analysis. No other external tools required.
---

# Arch Lens

Seven-step interactive architectural review. An Explore sub-agent navigates the
codebase the way a developer would — the confusion, file-bouncing, and untestable
seams it encounters are the findings. No checklists, no rigid heuristics.

> **Deep module:** small interface surface hiding a large, self-contained implementation.
> Lets callers test at the boundary. Lets AI agents reason without reading internals.

## Quick start

1. If a path argument is given, scope to that directory; otherwise whole repo
2. Load `${CLAUDE_SKILL_DIR}/references/WORKFLOW.md` — full step-by-step instructions
3. Load `${CLAUDE_SKILL_DIR}/references/DETECTION-PATTERNS.md`
4. Load `${CLAUDE_SKILL_DIR}/references/INTERFACE-DESIGN.md`
5. Load `${CLAUDE_SKILL_DIR}/references/RFC-FILE-FORMAT.md`
6. Execute the seven steps in WORKFLOW.md

## Workflows

| Step | What happens | Requires user input |
|------|-------------|---------------------|
| 1. Explore | Spawn Explore sub-agent; navigate organically; record friction | — |
| 2. Candidates | Synthesise friction into clusters; present max 8 with full context | — |
| 3. Pick | User selects a cluster and directs the angle | **wait** |
| 4. Frame | Problem statement, dependency category, blast radius, test boundary today | — |
| 5. Design | Spawn 3–4 parallel sub-agents with competing interface designs | — |
| 6. Choose | User picks interface or accepts recommendation | **wait** |
| 7. RFC file | Write `arch-rfcs-YYYY-MM-DD.md` to project root | — |

Full prompt text, cluster format, and step detail: see `WORKFLOW.md`.

## Behavioural rules

- Explore agent friction observations are primary evidence — never override with static analysis
- Never propose interface designs before Step 5
- Never advance past Steps 3 or 6 without a user response
- Every RFC must include exact `file:line` references and a before/after illustration
- Name every dependency category explicitly — it determines the testing strategy
- Rank clusters: testability impact first, then cognitive load, then interface stability

## Advanced features

- Full workflow detail and Explore agent prompt: `${CLAUDE_SKILL_DIR}/references/WORKFLOW.md`
- Friction vocabulary and dependency categories: `${CLAUDE_SKILL_DIR}/references/DETECTION-PATTERNS.md`
- Sub-agent brief template and design constraints: `${CLAUDE_SKILL_DIR}/references/INTERFACE-DESIGN.md`
- RFC action file format and complete example: `${CLAUDE_SKILL_DIR}/references/RFC-FILE-FORMAT.md`
