# Repo Patterns Reference

Language-specific `src/` layouts, platform-specific layouts, and mono-repo tooling guidance.

---

## Table of Contents

1. [Single Repo — Language Layouts](#1-single-repo---language-layouts)
2. [Platform-Specific Source Layouts](#2-platform-specific-source-layouts)
3. [Mono-Repo Tooling Selection](#3-mono-repo-tooling-selection)
4. [Repo Pattern Trees](#4-repo-pattern-trees)
5. [Multi-Language Mono-Repo Contracts](#5-multi-language-mono-repo-contracts)

---

## 1. Single Repo — Language Layouts

Apply these inside `src/`, `apps/*`, or `services/*` directories based on the chosen language.

### TypeScript / JavaScript (Node.js / Bun / Deno)

```
src/
├── index.ts               # Entry point
├── app.ts                 # App factory
├── config/                # Config loading (dotenv, zod validation)
├── routes/                # Route definitions (or controllers/)
├── services/              # Business logic
├── repositories/          # Data access
├── models/                # Domain models / DTOs
├── middleware/            # Express/Hono/Fastify middleware
├── utils/                 # Pure utility functions
└── types/                 # TypeScript type definitions
tests/
├── unit/
├── integration/
└── e2e/
# Root config files
package.json               # deps + scripts
tsconfig.json
.eslintrc.json OR eslint.config.js
.prettierrc
```

**Agent-OS standards keywords:**
- backend: `route`, `controller`, `express`, `fastify`, `hono`, `prisma`, `drizzle`
- frontend: `component`, `hook`, `page`, `react`, `vue`, `svelte`, `nextjs`
- testing: `jest`, `vitest`, `supertest`, `playwright`

---

### Python

```
src/<package_name>/        # Or just <package_name>/ at root
├── __init__.py
├── main.py                # Entry point
├── config.py              # Settings (pydantic-settings recommended)
├── api/                   # Route handlers (FastAPI routers or Flask blueprints)
│   ├── __init__.py
│   └── v1/
├── services/              # Business logic
├── repositories/          # Data access layer
├── models/                # SQLAlchemy / Pydantic models
├── schemas/               # Pydantic request/response schemas
├── utils/                 # Utility functions
└── core/                  # Core abstractions (exceptions, dependencies)
tests/
├── conftest.py
├── unit/
├── integration/
└── fixtures/
# Root config files
pyproject.toml             # uv / poetry / pip deps + tool config
.python-version            # pyenv version pin
Makefile                   # Common dev commands
```

**Agent-OS standards keywords:**
- backend: `fastapi`, `flask`, `django`, `sqlalchemy`, `pydantic`, `alembic`
- testing: `pytest`, `conftest`, `fixture`, `mock`, `factory`

---

### Go

```
cmd/                       # Binary entry points (one per deployable)
│   └── server/
│       └── main.go
internal/                  # Private application code (Go convention)
│   ├── api/               # HTTP handlers
│   ├── service/           # Business logic
│   ├── repository/        # Data access
│   ├── domain/            # Domain types and interfaces
│   └── config/            # Configuration
pkg/                       # Public, importable packages
│   └── <shared-pkg>/
tests/
│   ├── integration/
│   └── e2e/
go.mod
go.sum
Makefile
```

Go's `internal/` is enforced by the compiler — packages there cannot be imported by
external code. Use `pkg/` only for code intended to be imported by others.

**Agent-OS standards keywords:**
- backend: `gin`, `echo`, `fiber`, `gorm`, `pgx`, `sqlx`, `handler`
- testing: `testify`, `gomock`, `httptest`, `table-driven`

---

### Java / Kotlin (Spring Boot / Quarkus / Micronaut)

```
src/
├── main/
│   ├── java/<groupId>/<artifactId>/
│   │   ├── Application.java        # Entry point
│   │   ├── config/                 # Spring configs / beans
│   │   ├── controller/             # REST controllers
│   │   ├── service/                # Service layer
│   │   ├── repository/             # JPA repositories
│   │   ├── domain/ OR model/       # JPA entities / domain objects
│   │   ├── dto/                    # Request/Response DTOs
│   │   └── exception/              # Exception handlers
│   └── resources/
│       ├── application.yml
│       ├── application-dev.yml
│       └── application-prod.yml
└── test/
    └── java/<groupId>/<artifactId>/
        ├── unit/
        └── integration/
build.gradle.kts OR pom.xml
Makefile OR Taskfile
```

**Agent-OS standards keywords:**
- backend: `spring`, `controller`, `service`, `repository`, `JPA`, `bean`, `dto`
- testing: `junit`, `mockito`, `testcontainers`, `spring-test`

---

### Rust

```
src/
├── main.rs                # Entry point (binary) OR lib.rs (library)
├── lib.rs                 # Library root (if both binary and library)
├── config.rs              # Configuration
├── api/                   # HTTP handlers (Axum, Actix, etc.)
│   └── mod.rs
├── services/
│   └── mod.rs
├── repositories/
│   └── mod.rs
├── models/
│   └── mod.rs
└── error.rs               # Custom error types
tests/                     # Integration tests (unit tests go in-file)
Cargo.toml
Cargo.lock
```

**Agent-OS standards keywords:**
- backend: `axum`, `actix`, `warp`, `diesel`, `sqlx`, `tokio`, `handler`
- testing: `assert`, `mock`, `tokio::test`, `proptest`

---

### Ruby (Rails / Sinatra / Hanami)

```
# Rails convention (mostly generated)
app/
├── controllers/
├── models/
├── services/              # Service objects (not Rails default, add manually)
├── queries/               # Query objects
├── serializers/           # JSON serializers
└── views/ OR (API: serializers only)
config/
├── routes.rb
├── database.yml
└── environments/
db/
├── migrate/
└── schema.rb
spec/ OR test/
Gemfile
Gemfile.lock
```

**Agent-OS standards keywords:**
- backend: `controller`, `model`, `service`, `migration`, `serializer`, `ActiveRecord`
- testing: `rspec`, `factory_bot`, `capybara`, `minitest`

---

### C# / .NET

```
src/
├── <ProjectName>.API/             # Web API project
│   ├── Controllers/
│   ├── Middleware/
│   └── Program.cs
├── <ProjectName>.Application/     # Application layer (CQRS, commands, queries)
│   ├── Commands/
│   ├── Queries/
│   └── DTOs/
├── <ProjectName>.Domain/          # Domain entities, interfaces
│   ├── Entities/
│   ├── Interfaces/
│   └── ValueObjects/
└── <ProjectName>.Infrastructure/  # DB, external services, repos
    ├── Repositories/
    ├── Migrations/
    └── Services/
tests/
├── <ProjectName>.UnitTests/
└── <ProjectName>.IntegrationTests/
<ProjectName>.sln
```

Follows **Clean Architecture / Onion Architecture** — the most idiomatic .NET structure.

**Agent-OS standards keywords:**
- backend: `controller`, `command`, `query`, `entity`, `repository`, `CQRS`, `MediatR`
- testing: `xunit`, `nunit`, `moq`, `FluentAssertions`, `TestServer`

---

## 2. Platform-Specific Source Layouts

Apply these inside each `app/`, `service/`, or `src/` directory based on platform type.

### Frontend

```
web/
├── src/
│   ├── components/    # Reusable UI components
│   ├── pages/         # Page-level components (or app router pages)
│   ├── hooks/         # Custom hooks / composables
│   ├── stores/        # State management
│   ├── services/      # API client layer
│   ├── utils/         # Utilities
│   └── types/         # TypeScript types (if applicable)
├── public/            # Static assets
└── tests/
```

**Agent-OS standards keywords:**
- frontend: `component`, `hook`, `page`, `store`, `composable`, `layout`

### Backend / API

```
api/
├── src/
│   ├── routes/ OR controllers/   # HTTP route handlers
│   ├── services/                 # Business logic
│   ├── repositories/ OR dao/     # Data access layer
│   ├── models/ OR entities/      # Data models
│   ├── middleware/               # HTTP middleware
│   ├── config/                   # App configuration
│   └── utils/                    # Utilities
└── tests/
    ├── unit/
    └── integration/
```

### Middleware / Gateway / BFF

```
middleware/
├── src/
│   ├── handlers/       # Protocol-specific handlers
│   ├── transformers/   # Data transformation logic
│   ├── adapters/       # Adapters to upstream/downstream services
│   ├── cache/          # Caching strategies
│   ├── auth/           # Auth middleware
│   └── config/
└── tests/
```

### Agents / AI Services

```
agents/
├── src/
│   ├── agents/         # Individual agent definitions
│   ├── tools/          # Agent tools / MCP integrations
│   ├── prompts/        # Prompt templates (versioned)
│   ├── memory/         # Memory / context management
│   ├── orchestration/  # Multi-agent orchestration
│   └── eval/           # Agent evaluation harnesses
└── tests/
```

**Agent-OS standards keywords:**
- agents: `agent`, `tool`, `prompt`, `memory`, `orchestration`, `MCP`, `eval`

---

## 3. Mono-Repo Tooling Selection

| Tool | Best For | Languages | Notes |
|------|----------|-----------|-------|
| **Nx** | JS/TS mono-repos | TypeScript, JavaScript | Best DX for TS projects. Generators, caching, affected graph. |
| **Turborepo** | JS/TS mono-repos | TypeScript, JavaScript | Simpler than Nx. Good for smaller teams. |
| **Pants** | Multi-language | Python, Go, Java, Scala | Language-agnostic. Strong Python support. |
| **Bazel** | Multi-language at scale | Any (Java, C++, Go, Python, TS) | Most powerful. Steep learning curve. Google-origin. |
| **Gradle** | JVM ecosystem | Java, Kotlin, Groovy, Scala | Industry standard for JVM multi-project builds. |
| **pnpm workspaces** | JS/TS (simple) | TypeScript, JavaScript | Simplest option. No task runner overhead. |
| **uv workspaces** | Python | Python | Fast. Pythonic mono-repo. |
| **Cargo workspaces** | Rust | Rust | Built into Cargo. Native mono-repo for Rust. |

### When to use each

- **Solo / small team, all TypeScript/JS** — `pnpm workspaces` + `Turborepo`
- **Medium team, TypeScript/JS** — `Nx` (generators speed up scaffolding)
- **Mixed Python + TypeScript** — `Pants`
- **Large org, truly multi-language** — `Bazel` or `Pants`
- **All JVM** — `Gradle` multi-project
- **All Python** — `uv workspaces`
- **All Rust** — `Cargo workspaces`

### Mono-repo root config files (language-agnostic)

```
<root>/
├── package.json OR pyproject.toml OR Cargo.toml   # Workspace root config
├── nx.json OR turbo.json OR BUILD                 # Build tool config
├── .editorconfig                                   # Cross-editor formatting
├── .gitignore                                      # Aggregated ignores
├── .env.example                                    # Aggregated env vars
├── Makefile OR Taskfile.yml                        # Common dev commands
└── CODEOWNERS                                      # Ownership mapping
```

---

## 4. Repo Pattern Trees

### Pattern A: Single Repo

For single apps or single-service projects.

```
<project-root>/
├── agent-os/          # Agent-OS installation
├── src/               # Application source code
│   ├── <language-specific structure from Section 1>
├── tests/
│   ├── unit/
│   ├── integration/
│   └── e2e/
├── docs/
├── iac/
├── deploy/
├── CLAUDE.md
└── README.md
```

### Pattern B: Mono-Repo

For full-stack projects, microservices, or teams sharing a language ecosystem.

```
<project-root>/
├── agent-os/          # Mono-repo level Agent-OS (shared standards)
├── apps/              # Deployable applications
│   ├── web/           # Frontend app
│   ├── api/           # Backend API
│   ├── worker/        # Background workers
│   └── mobile/        # Mobile app (if applicable)
├── packages/          # Shared internal packages/libraries
│   ├── ui/            # Shared UI components
│   ├── config/        # Shared configuration
│   ├── utils/         # Shared utilities
│   └── types/         # Shared type definitions
├── services/          # Domain-bounded microservices (if applicable)
├── docs/
├── iac/
│   ├── modules/
│   ├── environments/
│   └── apps/          # Per-app IaC configs
├── deploy/
│   ├── scripts/
│   └── ci/
│       ├── web.yml
│       └── api.yml
├── CLAUDE.md          # Mono-repo-level Claude instructions
└── README.md
```

Use **Nx**, **Turborepo**, **Pants**, **Bazel**, or **Gradle** depending on language.
See Section 3 for selection guidance.

### Pattern C: Multi-Language Mono-Repo

For projects mixing languages (e.g., Python ML + TypeScript frontend + Go services).

```
<project-root>/
├── agent-os/
│   └── standards/
│       ├── global/        # Cross-language standards
│       ├── python/        # Python-specific standards
│       ├── typescript/    # TypeScript-specific standards
│       ├── go/            # Go-specific standards
│       └── testing/
├── services/              # Organized by language/runtime
│   ├── python/
│   │   ├── ml-pipeline/
│   │   └── data-api/
│   ├── typescript/
│   │   ├── web-app/
│   │   └── bff/
│   └── go/
│       ├── gateway/
│       └── auth-service/
├── shared/                # Language-agnostic shared assets
│   ├── proto/             # Protobuf/OpenAPI schemas (cross-lang contracts)
│   ├── configs/
│   └── scripts/
├── docs/
├── iac/
├── deploy/
├── CLAUDE.md
└── README.md
```

Use **Bazel** or **Pants** for builds. Define service contracts in `shared/proto/`
using Protobuf or OpenAPI as the cross-language source of truth.

---

## 5. Multi-Language Mono-Repo Contracts

When services span multiple languages, establish a **contract layer** in `shared/proto/` or
`shared/api/` to define the interface between services.

### Option A: Protobuf (gRPC / REST with buf)

```
shared/
└── proto/
    ├── buf.yaml                    # Buf.build config
    ├── buf.gen.yaml                # Code generation config
    └── <domain>/
        └── v1/
            └── <service>.proto     # Service definitions
```

Generate clients in each language via `buf generate` for type-safe clients from a single
source of truth.

### Option B: OpenAPI (REST)

```
shared/
└── api/
    └── openapi/
        └── <service>-v1.yaml       # OpenAPI 3.x spec
```

Generate clients with `openapi-generator` or `hey-api` (TypeScript),
`datamodel-code-generator` (Python), `oapi-codegen` (Go).

### Option C: AsyncAPI (Event-Driven / Kafka / AMQP)

```
shared/
└── api/
    └── asyncapi/
        └── <service>-events-v1.yaml
```

### Recommended shared/ layout (multi-language)

```
shared/
├── proto/             # Protobuf schemas (gRPC services)
├── api/
│   ├── openapi/       # REST API specs
│   └── asyncapi/      # Event schemas
├── configs/
│   ├── .editorconfig
│   ├── .eslintrc.base.json   (if any TS)
│   └── commitlint.config.js
└── scripts/
    ├── generate-clients.sh    # Run codegen for all languages
    ├── lint-all.sh
    └── test-all.sh
```

**Agent-OS tip:** Add `agent-os/standards/global/cross-service-contracts.md` explaining
which contract format is used and how to generate client code.
