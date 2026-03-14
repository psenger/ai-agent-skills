# Agent-OS v3 Guide

Installation, workflow, and integration reference for
[Agent-OS v3](https://github.com/buildermethods/agent-os) by Builder Methods.

---

## Table of Contents

1. [What Is Agent-OS?](#1-what-is-agent-os)
2. [Spec-Driven Development (SDD)](#2-spec-driven-development-sdd)
3. [Installation](#3-installation)
4. [Slash Commands](#4-slash-commands)
5. [Standards Design](#5-standards-design)
6. [CLAUDE.md Patterns](#6-claudemd-patterns)
7. [Profiles](#7-profiles)
8. [Skills vs Standards](#8-skills-vs-standards)

---

## 1. What Is Agent-OS?

Agent-OS is an open-source (MIT) system by [Builder Methods](https://buildermethods.com)
for injecting codebase standards and writing better specs for spec-driven development. It
works alongside Claude Code, Cursor, Windsurf, Codex, and other AI coding tools. It is
language-agnostic and framework-agnostic.

**What it does:**
- Extracts coding patterns from your codebase into documented standards
- Injects relevant standards into agent context automatically
- Guides product planning through structured conversation
- Enhances Plan Mode with standards-aware spec shaping

**What it does NOT do (v3):**
- Write specs for you (deferred to frontier AI models)
- Break down tasks or orchestrate implementation
- Manage subagents (users create their own)

---

## 2. Spec-Driven Development (SDD)

The methodology behind Agent-OS. Core principles:

- **Flipped time allocation:** ~95% planning, ~5% building (inverse of traditional dev)
- **Think -> Plan -> Build -> Verify** workflow
- Specs (not code) are the source of truth
- Shape detailed specifications *before* the AI writes any code
- Eliminates "prompt and pray" / "vibe coding"

### The SDD Loop

```
1. Discover  — extract patterns from codebase into standards
2. Inject    — deploy relevant standards into agent context
3. Build     — implement with AI tools using those standards
4. Refine    — update standards as patterns evolve
```

### Workflow Scenarios

| Scenario | Steps |
|----------|-------|
| New project | `/plan-product` -> scaffold structure -> write initial code -> `/discover-standards` |
| Existing codebase | `/discover-standards` -> `/inject-standards` before implementation |
| Feature planning | Enter Plan Mode -> `/shape-spec` -> approve and execute |
| Quick implementation | `/inject-standards` -> proceed with work |

---

## 3. Installation

Agent-OS has a **two-part installation**: a global base and per-project installs.

### Base Installation (one-time)

```bash
cd ~
git clone https://github.com/buildermethods/agent-os.git && rm -rf ~/agent-os/.git
```

This creates:
```
~/agent-os/
├── profiles/                    # Standards profiles
│   └── default/                 # Base profile
│       └── standards/
├── scripts/
│   ├── project-install.sh       # Install Agent-OS into a project
│   └── sync-to-profile.sh      # Sync project standards back to profile
├── commands/                    # Slash commands for Claude Code
│   └── agent-os/
│       ├── plan-product.md
│       ├── discover-standards.md
│       ├── inject-standards.md
│       └── shape-spec.md
└── config.yml                   # Profile configuration
```

### Project Installation

```bash
cd /path/to/your/project
~/agent-os/scripts/project-install.sh
```

Options:
- With a specific profile: `~/agent-os/scripts/project-install.sh --profile rails`
- Update commands only: `~/agent-os/scripts/project-install.sh --commands-only`

This creates in your project:
```
<project>/
├── agent-os/
│   └── standards/
│       └── index.yml            # Standards auto-detection index
└── .claude/
    └── commands/
        └── agent-os/            # Slash commands installed here
            ├── plan-product.md
            ├── discover-standards.md
            ├── inject-standards.md
            └── shape-spec.md
```

---

## 4. Slash Commands

Agent-OS v3 provides four slash commands:

| Command | Purpose | Output Location |
|---------|---------|----------------|
| `/plan-product` | Establishes product context through guided Q&A | `agent-os/product/*.md` |
| `/discover-standards` | Scans codebase and extracts patterns into standards | `agent-os/standards/**/*.md` |
| `/inject-standards` | Deploys relevant standards into current context | Active context (no files written) |
| `/shape-spec` | Enhanced Plan Mode with standards-aware questions | `agent-os/specs/YYYY-MM-DD-HHMM-<name>/` |

### Command Details

**`/plan-product`** creates three files through guided conversation:
- `agent-os/product/mission.md` — Product vision, target users, core problems
- `agent-os/product/roadmap.md` — Phased development plan with prioritized features
- `agent-os/product/tech-stack.md` — Technical stack choices

**`/discover-standards`** scans your codebase for patterns and writes them as prescriptive
standards files in `agent-os/standards/`. Run this after writing initial code to capture
your emerging patterns.

**`/inject-standards`** reads `agent-os/standards/index.yml` and loads relevant standards
into context based on keyword matching. Run before starting implementation work.

**`/shape-spec`** enhances Plan Mode by asking targeted questions that consider your
standards and product mission. Saves shaped specs to `agent-os/specs/YYYY-MM-DD-HHMM-<name>/`
with `plan.md`, `shape.md`, `standards.md`, and `references.md`.

---

## 5. Standards Design

Standards are the primary mechanism for keeping AI agents aligned across sessions. Write
standards as **prescriptive instructions**, not documentation.

### Standard File Structure

```markdown
# <Standard Name>

## When to Apply
<Describe the context: "When building API endpoints", "When writing React components">

## Pattern
<Concrete example — actual code or structure — not abstract description>

## Required
- <Specific rule 1>
- <Specific rule 2>

## Avoid
- <Anti-pattern 1>
- <Anti-pattern 2>

## Examples
<Working code examples>
```

### Recommended Minimum Standards Set

| Standard | Location | Contents |
|----------|----------|----------|
| Tech stack | `global/tech-stack.md` | Languages, versions, package manager, frameworks, testing tools |
| API patterns | `backend/api-patterns.md` | REST/GraphQL/gRPC choice, error format, auth pattern, validation |
| Data access | `backend/data-access.md` | ORM/query builder, migrations, connection pooling, transactions |
| Components | `frontend/component-patterns.md` | File structure, naming, state co-location rules |
| Unit testing | `testing/unit-testing.md` | What to test, mock approach, file naming, coverage requirements |

### Standards Index (`index.yml`)

The index file tells `/inject-standards` which standards apply to which contexts:

```yaml
version: "1.0"
standards:
  - path: global/tech-stack.md
    keywords: [tech, stack, language, framework]
    always_inject: true
  - path: backend/api-patterns.md
    keywords: [api, route, controller, endpoint, REST, GraphQL]
  - path: frontend/component-patterns.md
    keywords: [component, UI, page, view, hook]
```

### Multi-Language Standards (Mono-Repo)

For mono-repos with multiple languages, organize standards by language:

```
agent-os/standards/
├── index.yml
├── global/
│   ├── tech-stack.md              # Overview of ALL languages
│   ├── git-conventions.md         # Commit format, branch naming
│   └── cross-service-contracts.md # How services communicate
├── typescript/
│   ├── patterns.md
│   └── testing.md
├── python/
│   ├── patterns.md
│   └── testing.md
├── backend/                       # Language-agnostic backend patterns
│   └── api-design.md
├── frontend/
│   └── component-patterns.md
└── testing/
    └── strategy.md
```

---

## 6. CLAUDE.md Patterns

### Mono-Repo CLAUDE.md Strategy

For mono-repos, the root `CLAUDE.md` is the entry point. Each service can have its own
`CLAUDE.md` that adds service-specific context.

**Root CLAUDE.md:**
```markdown
# <Project> Mono-Repo — Claude Code Instructions

## Architecture Overview
This is a mono-repo containing:
- `apps/web` — Next.js frontend
- `apps/api` — Node.js/Express REST API
- `services/auth` — Authentication microservice
- `packages/ui` — Shared UI component library

## Agent-OS
Standards: `agent-os/standards/`
Run `/inject-standards` before working in any service.
Run `/shape-spec` in Plan Mode for new features.

## Service-Specific Instructions
Each service has its own CLAUDE.md:
- `apps/web/CLAUDE.md`
- `apps/api/CLAUDE.md`

## Common Commands
- Install all: `pnpm install`
- Test all: `pnpm test`
- Build affected: `pnpm nx affected --target=build`
```

**Per-service CLAUDE.md (`apps/api/CLAUDE.md`):**
```markdown
# API Service — Claude Code Instructions

See root CLAUDE.md for mono-repo context.

## This Service
- Runtime: Node.js 22 + TypeScript
- Framework: Fastify
- ORM: Drizzle ORM
- Database: PostgreSQL 16

## Key Patterns
- All routes validate input with Zod schemas
- Services call db/ functions, never raw SQL in routes
- Errors: throw AppError with code and message
- Tests: Vitest for unit, Supertest for integration
```

---

## 7. Profiles

Profiles are named collections of standards stored in `~/agent-os/profiles/`. They allow
different standard sets for different project types.

- **Hierarchical inheritance** via `config.yml` (child profiles override parent standards)
- **Sync back** from project to profile: `~/agent-os/scripts/sync-to-profile.sh`
- Organize by technology stack, client, or context (work/personal/consulting)

```yaml
# ~/agent-os/config.yml
profiles:
  rails:
    parent: default
  nextjs:
    parent: default
  consulting-client-a:
    parent: default
```

---

## 8. Skills vs Standards

| | Standards | Skills |
|--|-----------|--------|
| **What** | Persistent coding conventions | Reusable multi-step workflows |
| **When loaded** | Injected by `/inject-standards` | Triggered by slash command or context |
| **Format** | Markdown in `agent-os/standards/` | Markdown in `.claude/skills/` |
| **Token cost** | Low (injected selectively) | Medium (loaded on demand) |
| **Examples** | "Always use Zod for validation" | `/scaffold-api-endpoint` |

**Use standards for:** code style, patterns, architectural constraints, naming conventions,
technology choices.

**Use skills for:** multi-step workflows, repeatable scaffolding, cross-cutting operations
that span many files.

---

## References

- [Agent-OS GitHub](https://github.com/buildermethods/agent-os)
- [Builder Methods](https://buildermethods.com)
- [Agent-OS Installation Guide](https://buildermethods.com/agent-os/installation)
- [Agent-OS Workflow](https://buildermethods.com/agent-os/workflow)
- [Agent-OS Profiles](https://buildermethods.com/agent-os/profiles)
- [Spec-Driven Development](https://buildermethods.com/library/spec-driven-development-claude-code)
