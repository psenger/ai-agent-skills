# Example: Mono-Repo — Full-Stack TypeScript

This example shows the completed scaffold for a mono-repo full-stack TypeScript project
with a Next.js frontend, Fastify API, and Pulumi for IaC.

## Inputs

| Input | Value |
|-------|-------|
| Repo pattern | Mono-Repo |
| Platform type | Full-Stack |
| Language | TypeScript |
| IaC tool | Pulumi |
| Target platform | AWS |
| Agent tooling | Claude Code |

## Resulting Directory Structure

```
my-platform/
├── CLAUDE.md                        # Root mono-repo instructions
│
├── .claude/
│   ├── settings.json
│   ├── agents/
│   │   └── backend-dev.md           # Specialist backend agent
│   ├── skills/
│   ├── commands/
│   └── hooks/
│       └── scripts/
│
├── agent-os/
│   ├── product/
│   │   ├── mission.md
│   │   ├── roadmap.md
│   │   └── tech-stack.md
│   ├── specs/
│   └── standards/
│       ├── index.yml
│       ├── global/
│       │   └── tech-stack.md
│       ├── backend/
│       ├── frontend/
│       └── testing/
│
├── apps/
│   ├── web/                         # Next.js frontend
│   │   ├── CLAUDE.md                # Service-specific instructions
│   │   ├── src/
│   │   │   ├── components/
│   │   │   ├── pages/
│   │   │   ├── hooks/
│   │   │   ├── stores/
│   │   │   ├── services/
│   │   │   ├── utils/
│   │   │   └── types/
│   │   ├── public/
│   │   ├── tests/
│   │   ├── package.json
│   │   ├── tsconfig.json
│   │   └── next.config.js
│   │
│   └── api/                         # Fastify backend API
│       ├── CLAUDE.md
│       ├── src/
│       │   ├── index.ts
│       │   ├── app.ts
│       │   ├── routes/
│       │   ├── services/
│       │   ├── repositories/
│       │   ├── models/
│       │   ├── middleware/
│       │   ├── config/
│       │   └── utils/
│       ├── tests/
│       │   ├── unit/
│       │   └── integration/
│       ├── package.json
│       └── tsconfig.json
│
├── packages/
│   ├── ui/                          # Shared UI component library
│   │   ├── src/
│   │   ├── package.json
│   │   └── tsconfig.json
│   ├── config/                      # Shared configuration
│   │   ├── eslint/
│   │   ├── tsconfig/
│   │   └── package.json
│   ├── utils/                       # Shared utilities
│   │   ├── src/
│   │   └── package.json
│   └── types/                       # Shared type definitions
│       ├── src/
│       └── package.json
│
├── docs/
│   ├── architecture/
│   │   └── ADR-001-mono-repo-strategy.md
│   ├── api/
│   └── runbooks/
│
├── iac/
│   ├── README.md
│   ├── Pulumi.yaml
│   ├── src/
│   │   ├── components/
│   │   │   ├── network.ts
│   │   │   ├── compute.ts
│   │   │   └── database.ts
│   │   ├── environments/
│   │   │   ├── dev.ts
│   │   │   ├── staging.ts
│   │   │   └── prod.ts
│   │   └── index.ts
│   ├── Pulumi.dev.yaml
│   ├── Pulumi.staging.yaml
│   ├── Pulumi.prod.yaml
│   └── package.json
│
├── deploy/
│   ├── scripts/
│   │   ├── deploy.sh
│   │   ├── rollback.sh
│   │   ├── healthcheck.sh
│   │   └── db-migrate.sh
│   ├── ci/
│   │   ├── web.yml
│   │   └── api.yml
│   └── docker/
│       ├── Dockerfile.web
│       ├── Dockerfile.api
│       └── docker-compose.yml
│
├── .github/
│   └── workflows/
│       ├── ci.yml
│       ├── deploy-dev.yml
│       ├── deploy-staging.yml
│       └── deploy-prod.yml
│
├── README.md
├── package.json                     # Workspace root
├── pnpm-workspace.yaml
├── turbo.json
├── .gitignore
└── .env.example
```

## Generated Root CLAUDE.md

```markdown
# my-platform — Claude Code Instructions

## Project Overview
A full-stack TypeScript platform with Next.js frontend and Fastify API,
deployed on AWS using Pulumi.

## Repo Pattern
Mono-Repo (pnpm workspaces + Turborepo)

## Architecture
- `apps/web` — Next.js 14 frontend (App Router)
- `apps/api` — Fastify REST API with PostgreSQL
- `packages/ui` — Shared React component library
- `packages/types` — Shared TypeScript types

See docs/architecture/ for ADRs.

## Agent-OS Integration
This project uses Agent-OS v3 (Builder Methods). Key commands:
- `/plan-product` — Establish product context
- `/discover-standards` — Extract patterns into standards
- `/inject-standards` — Deploy relevant standards into context
- `/shape-spec` — Create a feature spec in Plan Mode

Standards: `agent-os/standards/`
Specs: `agent-os/specs/`

## Service-Specific Instructions
Each app has its own CLAUDE.md:
- `apps/web/CLAUDE.md`
- `apps/api/CLAUDE.md`

## Key Conventions
- pnpm for package management
- Turborepo for build orchestration
- Shared types in `packages/types/`
- Shared UI components in `packages/ui/`

## IaC & Deployment
- IaC tool: Pulumi (TypeScript)
- IaC location: `iac/`
- Deploy scripts: `deploy/scripts/`
- CI/CD: `.github/workflows/`

## Common Commands
- Install all: `pnpm install`
- Dev (all): `pnpm dev`
- Test all: `pnpm test`
- Build all: `pnpm build`
- Lint all: `pnpm lint`
- Build affected: `pnpm turbo run build --filter=...[HEAD~1]`

## Environment Variables
Copy `.env.example` to `.env` and fill in values. Never commit `.env`.
```

## Generated apps/api/CLAUDE.md

```markdown
# API Service — Claude Code Instructions

See root CLAUDE.md for mono-repo context.

## This Service
- Runtime: Node.js 22 + TypeScript
- Framework: Fastify
- ORM: Drizzle ORM
- Database: PostgreSQL 16

## Source Layout
- `src/routes/` — Route definitions with Zod validation
- `src/services/` — Business logic (no DB access here)
- `src/repositories/` — Data access layer (Drizzle)
- `src/models/` — Domain models and DTOs

## Key Patterns
- All routes validate input with Zod schemas
- Services call repository functions, never raw SQL in routes
- Errors: throw AppError with code and message
- Tests: Vitest for unit, Supertest for integration

## Commands
- Dev: `pnpm --filter api dev`
- Test: `pnpm --filter api test`
- Lint: `pnpm --filter api lint`
```
