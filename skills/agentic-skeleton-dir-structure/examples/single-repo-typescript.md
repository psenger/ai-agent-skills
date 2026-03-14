# Example: Single Repo — TypeScript Backend API

This example shows the completed scaffold for a single-repo TypeScript backend API
using Terraform for IaC and GitHub Actions for CI/CD.

## Inputs

| Input | Value |
|-------|-------|
| Repo pattern | Single Repo |
| Platform type | Backend |
| Language | TypeScript (Node.js) |
| IaC tool | Terraform |
| Target platform | AWS |
| Agent tooling | Claude Code |

## Resulting Directory Structure

```
my-api/
├── CLAUDE.md
│
├── .claude/
│   ├── settings.json
│   ├── agents/
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
├── src/
│   ├── index.ts
│   ├── app.ts
│   ├── config/
│   ├── routes/
│   ├── services/
│   ├── repositories/
│   ├── models/
│   ├── middleware/
│   ├── utils/
│   └── types/
│
├── tests/
│   ├── unit/
│   ├── integration/
│   └── e2e/
│
├── docs/
│   ├── architecture/
│   │   └── ADR-001-initial-architecture.md
│   ├── api/
│   └── runbooks/
│
├── iac/
│   ├── README.md
│   ├── modules/
│   │   ├── network/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   ├── compute/
│   │   └── database/
│   ├── environments/
│   │   ├── dev/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   ├── outputs.tf
│   │   │   ├── terraform.tfvars
│   │   │   └── backend.tf
│   │   ├── staging/
│   │   └── prod/
│   └── shared/
│
├── deploy/
│   ├── scripts/
│   │   ├── deploy.sh
│   │   ├── rollback.sh
│   │   ├── healthcheck.sh
│   │   └── db-migrate.sh
│   ├── ci/
│   └── docker/
│       ├── Dockerfile
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
├── package.json
├── tsconfig.json
├── .eslintrc.json
├── .prettierrc
├── .gitignore
└── .env.example
```

## Generated CLAUDE.md

```markdown
# my-api — Claude Code Instructions

## Project Overview
A TypeScript REST API service deployed on AWS.

## Repo Pattern
Single Repo

## Architecture
Single-service Node.js API using Fastify with PostgreSQL.
See docs/architecture/ for ADRs.

## Agent-OS Integration
This project uses Agent-OS v3 (Builder Methods). Key commands:
- `/plan-product` — Establish product context
- `/discover-standards` — Extract patterns into standards
- `/inject-standards` — Deploy relevant standards into context
- `/shape-spec` — Create a feature spec in Plan Mode

Standards: `agent-os/standards/`
Specs: `agent-os/specs/`
Product context: `agent-os/product/`

## Project Structure
- `src/routes/` — Fastify route handlers with Zod validation
- `src/services/` — Business logic (no DB access)
- `src/repositories/` — Data access layer (Drizzle ORM)
- `src/models/` — Domain models and DTOs
- `tests/` — Unit, integration, and e2e tests

## Key Conventions
- Validate all inputs with Zod schemas
- Use Repository pattern for all DB access
- Throw AppError for structured error responses
- Use Vitest for unit tests, Supertest for integration

## IaC & Deployment
- IaC tool: Terraform
- IaC location: `iac/`
- Deploy scripts: `deploy/scripts/`
- CI/CD: `.github/workflows/`

## Environment Variables
Copy `.env.example` to `.env` and fill in values. Never commit `.env`.

## Getting Started
1. Install dependencies: `pnpm install`
2. Copy env: `cp .env.example .env`
3. Run locally: `pnpm dev`
4. Run tests: `pnpm test`
```

## Generated agent-os/standards/index.yml

```yaml
version: "1.0"
standards:
  - path: global/tech-stack.md
    keywords: [tech, stack, language, framework, tooling]
    always_inject: true
  - path: backend/api-patterns.md
    keywords: [api, route, controller, endpoint, REST, fastify]
  - path: backend/data-access.md
    keywords: [database, query, repository, ORM, drizzle, postgres]
  - path: testing/unit-testing.md
    keywords: [test, unit, mock, spec, vitest]
  - path: testing/integration-testing.md
    keywords: [integration, e2e, supertest]
```
