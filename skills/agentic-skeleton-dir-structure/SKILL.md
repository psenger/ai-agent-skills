---
name: agentic-skeleton-dir-structure
description: Scaffolds production-ready directory structures for agentic AI projects using Agent-OS v3 (Builder Methods). Use when the user asks to set up, scaffold, initialize, or restructure a project for agentic development — including mono-repos, single repos, multi-language repos, full-stack, backend, frontend, or middleware projects. Triggers on "scaffold directory", "project structure", "agentic scaffold", "project layout", "initialize AI project", "directory structure", "agent-os setup", "mono-repo layout", "IaC structure".
user-invocable: true
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
argument-hint: "[repo-pattern: single|mono|multi-lang]"
author: Philip A Senger
references:
  - references/repo-patterns.md
  - references/iac-patterns.md
  - references/agent-os-guide.md
---

# Agentic Skeleton Directory Structure Skill v2.0

Scaffolds production-ready agentic AI project structures that integrate with
[Agent-OS v3](https://github.com/buildermethods/agent-os) by Builder Methods.

This skill follows the **Spec-Driven Development (SDD)** methodology: ~95% planning,
~5% building. You shape detailed specifications before the AI writes any code.

---

## When This Skill Activates

On activation, follow this sequence:

1. **Check for arguments.** If `$ARGUMENTS` is provided, parse it for the repo pattern
   (`single`, `mono`, or `multi-lang`) and skip that question in Step 0.
2. **Detect the current directory.** Run `ls` to check if the current directory already
   has files (existing project) or is empty/new. If existing:
   - Warn the user: "This directory already has files. I can scaffold around them or
     create a new subdirectory. Which do you prefer?"
   - If there is already a `CLAUDE.md`, ask if they want to overwrite or preserve it.
3. **Begin Step 0** — gather requirements through interactive questions.
4. **After all inputs are collected**, present a summary and ask for confirmation
   before creating anything.
5. **Scaffold** — create directories, generate files, show the final tree.
6. **Guide next steps** — Agent-OS installation and SDD workflow.

---

## Step 0 — Gather Requirements

Collect these six inputs. Ask **one question at a time**, wait for a response, then
proceed to the next. Skip any question already answered via arguments or context.

### Question 1 — Repo Pattern
> What repo pattern do you want?
> - **Single Repo** — one app or service
> - **Mono-Repo** — multiple apps/services, same language ecosystem
> - **Multi-Language Mono-Repo** — services in different languages (e.g. Python + TypeScript + Go)

### Question 2 — Platform Type
> What type of project is this?
> - **Frontend** — SPA, SSR, static site
> - **Backend** — API, service, worker
> - **Full-Stack** — frontend + backend together
> - **Middleware** — gateway, BFF, proxy
> - **Multi-Service** — multiple independent services
> - **Agents/AI** — agentic AI service with tools, prompts, memory

### Question 3 — Languages
> What language(s) will you use? (e.g. TypeScript, Python, Go, Java, Rust, Ruby, C#)

### Question 4 — IaC Tool
> What Infrastructure as Code tool do you want? (or "none" to skip)
> Options: Terraform, Pulumi, CDK, Bicep, CloudFormation, Helm, Ansible, or None

### Question 5 — Target Platform
> Where will this deploy?
> e.g. AWS, GCP, Azure, Kubernetes, Bare Metal, Vercel, Cloudflare

### Question 6 — Agent Tooling
> What AI coding tool are you using? (default: Claude Code)
> e.g. Claude Code, Cursor, Windsurf, Codex

### After All Questions

Present a summary table and ask for confirmation:

```
Here's what I'll scaffold:

| Input           | Value                  |
|-----------------|------------------------|
| Repo pattern    | <answer>               |
| Platform        | <answer>               |
| Language(s)     | <answer>               |
| IaC tool        | <answer>               |
| Target platform | <answer>               |
| Agent tooling   | <answer>               |
| Project name    | <answer or ask now>    |

Does this look right? I'll create the directory structure once you confirm.
```

Do NOT create any files or directories until the user confirms.

---

## Step 1 — Scaffold Core Structure

Every project gets this root structure regardless of repo pattern or platform:

```
<project-root>/
├── CLAUDE.md                        # Claude Code project instructions (CRITICAL)
│                                    # Loaded every session — keep it lean and universal
│
├── .claude/                         # Claude Code configuration
│   ├── settings.json                # Permissions, hooks, MCP server config
│   ├── settings.local.json          # Personal overrides (git-ignored)
│   ├── agents/                      # Subagent definitions (specialist agents)
│   │   └── <name>.md                # Each agent: instructions + allowed tools
│   ├── skills/                      # Project-local skills (auto-invoked)
│   │   └── <skill-name>/
│   │       └── SKILL.md
│   ├── commands/                    # Slash commands (/deploy, /test, etc.)
│   │   └── <name>.md
│   └── hooks/                       # Lifecycle hooks (PreToolUse, PostToolUse, etc.)
│       └── scripts/
│
├── agent-os/                        # Agent-OS project installation (Builder Methods)
│   ├── product/                     # Product context (/plan-product output)
│   ├── specs/                       # Feature specs (/shape-spec output)
│   └── standards/                   # Coding standards (/discover-standards output)
│       └── index.yml                # Standards auto-detection index
│
├── docs/                            # Human and agent-readable documentation
│   ├── architecture/                # Architecture Decision Records (ADRs)
│   ├── api/                         # API documentation
│   └── runbooks/                    # Operational runbooks
│
├── iac/                             # Infrastructure as Code (if applicable)
├── deploy/                          # Deployment scripts and CI/CD
├── .github/ OR .gitlab/             # VCS platform config
├── README.md
├── .gitignore
└── .env.example
```

**Key rules:**
- `CLAUDE.md` is the brain of the project — loaded every session, keep it lean
- `.claude/skills/` = lazy-loaded, auto-invoked reusable instructions (SKILL.md format)
- `.claude/agents/` = specialist subagents for parallel or domain-specific work
- `.claude/commands/` = slash commands for repeatable workflows
- `agent-os/standards/` = injected coding conventions so agents stay aligned across sessions
- Never put secrets in any of these files

Then apply the repo pattern, platform layout, and IaC structure from reference files:

- **Repo patterns and source layouts** — read `references/repo-patterns.md`
- **IaC and deployment patterns** — read `references/iac-patterns.md`
- **Agent-OS integration and commands** — read `references/agent-os-guide.md`

---

## Step 2 — Create the Scaffold

After confirming the pattern and platform with the user, create all directories and seed files.

```bash
# Variables from user input
PROJECT_ROOT="<project-name>"
REPO_PATTERN="<single|mono|multi>"
PLATFORM="<frontend|backend|fullstack|middleware|agents>"
IAC_TOOL="<terraform|pulumi|cdk|bicep|cloudformation|helm|ansible|none>"

# --- Claude Code configuration ---
mkdir -p "$PROJECT_ROOT/.claude/agents"
mkdir -p "$PROJECT_ROOT/.claude/skills"
mkdir -p "$PROJECT_ROOT/.claude/commands"
mkdir -p "$PROJECT_ROOT/.claude/hooks/scripts"

# --- Core Agent-OS directories ---
mkdir -p "$PROJECT_ROOT/agent-os/product"
mkdir -p "$PROJECT_ROOT/agent-os/specs"
mkdir -p "$PROJECT_ROOT/agent-os/standards/global"
mkdir -p "$PROJECT_ROOT/agent-os/standards/backend"
mkdir -p "$PROJECT_ROOT/agent-os/standards/frontend"
mkdir -p "$PROJECT_ROOT/agent-os/standards/testing"

# --- Documentation ---
mkdir -p "$PROJECT_ROOT/docs/architecture"
mkdir -p "$PROJECT_ROOT/docs/api"
mkdir -p "$PROJECT_ROOT/docs/runbooks"

# --- IaC (skip if IAC_TOOL is "none") ---
if [ "$IAC_TOOL" != "none" ]; then
  mkdir -p "$PROJECT_ROOT/iac/modules"
  mkdir -p "$PROJECT_ROOT/iac/environments/dev"
  mkdir -p "$PROJECT_ROOT/iac/environments/staging"
  mkdir -p "$PROJECT_ROOT/iac/environments/prod"
  mkdir -p "$PROJECT_ROOT/iac/shared"
fi

# --- Deployment ---
mkdir -p "$PROJECT_ROOT/deploy/scripts"
mkdir -p "$PROJECT_ROOT/deploy/ci"
mkdir -p "$PROJECT_ROOT/deploy/docker"

# --- Repo pattern branching ---
case "$REPO_PATTERN" in
  single)
    # Single repo: src/ + tests/
    mkdir -p "$PROJECT_ROOT/src"
    mkdir -p "$PROJECT_ROOT/tests/unit"
    mkdir -p "$PROJECT_ROOT/tests/integration"
    mkdir -p "$PROJECT_ROOT/tests/e2e"
    ;;
  mono)
    # Mono-repo: apps/ + packages/ + services/
    mkdir -p "$PROJECT_ROOT/apps/web"
    mkdir -p "$PROJECT_ROOT/apps/api"
    mkdir -p "$PROJECT_ROOT/packages/ui"
    mkdir -p "$PROJECT_ROOT/packages/config"
    mkdir -p "$PROJECT_ROOT/packages/utils"
    mkdir -p "$PROJECT_ROOT/services"
    ;;
  multi)
    # Multi-language mono-repo: services/<lang>/ + shared/
    mkdir -p "$PROJECT_ROOT/services"
    mkdir -p "$PROJECT_ROOT/shared/proto"
    mkdir -p "$PROJECT_ROOT/shared/configs"
    mkdir -p "$PROJECT_ROOT/shared/scripts"
    # Create per-language service dirs based on user's language choices
    ;;
esac

# --- Platform-specific source layout ---
# Consult references/repo-patterns.md for the language-specific src/ structure
# and create the appropriate subdirectories inside src/, apps/*, or services/*

# --- Seed files ---
touch "$PROJECT_ROOT/.env.example"
touch "$PROJECT_ROOT/.gitignore"
touch "$PROJECT_ROOT/README.md"
```

After creating directories, apply the language-specific source layout from
`references/repo-patterns.md` inside each `src/`, `apps/*`, or `services/*` directory.

---

## Step 3 — Generate CLAUDE.md

Create this at the project root. Claude Code reads it on every session.

```markdown
# <Project Name> — Claude Code Instructions

## Project Overview
<One paragraph describing what this project does and who it is for.>

## Repo Pattern
<!-- Single Repo | Mono-Repo | Multi-Language Mono-Repo -->

## Architecture
<Brief architecture overview. Reference docs/architecture/ for ADRs.>

## Agent-OS Integration
This project uses [Agent-OS v3](https://github.com/buildermethods/agent-os)
(Builder Methods). Key commands:
- `/plan-product` — Establish product context (mission, roadmap, tech stack)
- `/discover-standards` — Extract coding patterns into documented standards
- `/inject-standards` — Deploy relevant standards into current context
- `/shape-spec` — Create a feature spec in Plan Mode

Standards: `agent-os/standards/`
Specs: `agent-os/specs/`
Product context: `agent-os/product/`

## Project Structure
<Paste the relevant tree from the scaffold output.>

## Key Conventions
- <Convention 1>
- <Convention 2>
- <Convention 3>

## IaC & Deployment
- IaC tool: <Terraform / Pulumi / CDK / etc.>
- IaC location: `iac/`
- Deploy scripts: `deploy/scripts/`
- CI/CD: `deploy/ci/` or `.github/workflows/`

## Environment Variables
Copy `.env.example` to `.env` and fill in values. Never commit `.env`.

## Getting Started
1. Install dependencies: `<language-specific install command>`
2. Copy env: `cp .env.example .env`
3. Run locally: `<start command>`
4. Run tests: `<test command>`
```

---

## Step 4 — Seed Agent-OS Files

Create the standards index so Agent-OS can discover and inject standards:

**`agent-os/standards/index.yml`**:
```yaml
# Auto-detection rules for /inject-standards
version: "1.0"
standards:
  - path: global/tech-stack.md
    keywords: [tech, stack, language, framework, tooling]
    always_inject: true
  - path: backend/api-patterns.md
    keywords: [api, route, controller, endpoint, REST, GraphQL]
  - path: backend/data-access.md
    keywords: [database, query, repository, ORM, model]
  - path: frontend/component-patterns.md
    keywords: [component, UI, page, view, hook]
  - path: frontend/state-management.md
    keywords: [state, store, context, redux, zustand, signal]
  - path: testing/unit-testing.md
    keywords: [test, unit, mock, spec, jest, pytest, vitest]
  - path: testing/integration-testing.md
    keywords: [integration, e2e, cypress, playwright, supertest]
```

Create stub product files:

**`agent-os/product/tech-stack.md`**:
```markdown
# Tech Stack
<!-- Populated by /plan-product or manually -->
- Primary language(s): <from Step 0>
- Package manager: <npm, pnpm, uv, cargo, etc.>
- Framework(s): <from Step 0>
- Testing: <jest, vitest, pytest, etc.>
- IaC: <from Step 0>
```

**`agent-os/product/mission.md`**:
```markdown
# Product Mission
<!-- Run /plan-product to populate this through guided conversation -->
```

**`agent-os/product/roadmap.md`**:
```markdown
# Product Roadmap
<!-- Run /plan-product to populate this through guided conversation -->
```

---

## Step 5 — Present Next Steps

After scaffolding is complete, show the user the final directory tree and present
these next steps. Read `references/agent-os-guide.md` for full Agent-OS details.

Present this to the user:

```
## Your scaffold is ready! Here's what to do next:

### 1. Initialize git (if not already)
git init && git add -A && git commit -m "Initial scaffold"

### 2. Install Agent-OS (one-time global setup)
cd ~
git clone https://github.com/buildermethods/agent-os.git && rm -rf ~/agent-os/.git

### 3. Install Agent-OS into this project
cd /path/to/your/project
~/agent-os/scripts/project-install.sh

This will:
- Populate agent-os/standards/ with your profile's standards
- Install slash commands into .claude/commands/agent-os/

### 4. Establish product context
Run /plan-product in Claude Code — it will guide you through
defining your mission, roadmap, and tech stack.

### 5. Start the Spec-Driven Development loop
1. Write some initial code to establish patterns
2. Run /discover-standards to extract those patterns
3. Run /inject-standards before each implementation session
4. Run /shape-spec in Plan Mode for new features
5. Repeat as your codebase evolves
```

If the user's agent tooling is NOT Claude Code, adapt the instructions accordingly
(e.g., Cursor uses different skill/command locations).

---

## Step 6 — Quality Checklist

Before declaring the scaffold complete, verify:

- [ ] All directories from the chosen repo pattern exist
- [ ] Language-specific `src/` layout matches `references/repo-patterns.md`
- [ ] `CLAUDE.md` is present at project root with all sections populated
- [ ] `.claude/` directory exists with `agents/`, `skills/`, `commands/`, `hooks/` subdirs
- [ ] `agent-os/standards/index.yml` exists with correct paths
- [ ] `agent-os/product/tech-stack.md` reflects the user's choices
- [ ] `agent-os/product/mission.md` and `roadmap.md` stubs exist
- [ ] `.env.example` exists (never `.env`)
- [ ] `.gitignore` includes language-specific ignores and `.env`
- [ ] `README.md` exists with project name and getting-started steps
- [ ] IaC structure matches the chosen tool (per `references/iac-patterns.md`)
- [ ] No secrets, tokens, or credentials in any generated file
- [ ] Directory tree output shown to user for confirmation

---

## Reference Files

Load these as needed during scaffolding:

- **`references/repo-patterns.md`** — Language-specific `src/` layouts (TypeScript, Python,
  Go, Java, Rust, Ruby, C#), platform-specific layouts (Frontend, Backend, Middleware, Agents),
  and mono-repo tooling selection.

- **`references/iac-patterns.md`** — IaC directory structure by tool (Terraform, Pulumi,
  CDK, Bicep, CloudFormation, Helm, Ansible), CI/CD pipeline patterns, and environment
  promotion strategies.

- **`references/agent-os-guide.md`** — Agent-OS v3 installation, Spec-Driven Development
  methodology, slash command reference, standards design, and CLAUDE.md advanced patterns.
