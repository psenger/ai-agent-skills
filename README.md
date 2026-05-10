<p align="center">
  <h1 align="center">ai-agent-skills</h1>
  <p align="center">
    A curated collection of production-ready AI agent skills<br/>
    for Claude Code, Codex, Cursor, and any tool that supports the<br/>
    <a href="https://agentskills.io/specification">Agent Skills Open Standard</a>.
  </p>
  <p align="center">
    <a href="https://github.com/psenger/ai-agent-skills/blob/main/LICENSE"><img src="https://img.shields.io/github/license/psenger/ai-agent-skills?style=flat-square" alt="License"></a>
    <a href="https://github.com/psenger/ai-agent-skills/issues"><img src="https://img.shields.io/github/issues/psenger/ai-agent-skills?style=flat-square" alt="Issues"></a>
    <a href="https://github.com/psenger/ai-agent-skills/stargazers"><img src="https://img.shields.io/github/stars/psenger/ai-agent-skills?style=flat-square" alt="Stars"></a>
  </p>
</p>

---

## What Is This?

**ai-agent-skills** is a library of reusable skills that teach AI coding agents _how_ to do specialised tasks — consistently, every time. Each skill is a self-contained folder with structured instructions, reference material, and examples that an agent loads on demand.

Think of it as a playbook: you define the process once, and the agent follows it whenever the task comes up.

---

## Skills

| Skill | Type | Description |
|---|---|---|
| **[vault-scribe](skills/vault-scribe/)** | `/vault-scribe` | Converts transcripts, meeting notes, brainstorming sessions, strategy docs, and rough notes into polished Obsidian vault Markdown — GitHub-compatible by default, with type-aware frontmatter schemas |
| **[agentic-skeleton-dir-structure](skills/agentic-skeleton-dir-structure/)** | `/agentic-skeleton-dir-structure` | Scaffolds production-ready directory structures for agentic AI projects using Agent-OS v3 (Builder Methods) — supports single repos, mono-repos, multi-language repos, any platform, any language |
| **[git-commit-pr-message](skills/git-commit-pr-message/)** | `/git-commit-pr-message` | Generates Conventional Commits messages, PR titles/descriptions, and Keep a Changelog v1.1.0 entries — with sensitive content scanning, GitHub/Jira ticket linking, and release workflow |
| **[design-critique](skills/design-critique/)** | `/design-critique` | Structured design critique and plan stress-testing — acts as a relentless interviewer using pre-mortem, red teaming, and ATAM techniques to challenge technical architectures, product plans, and feature designs exhaustively |
| **[arch-lens](skills/arch-lens/)** | `/arch-lens` | Seven-step interactive architectural review anchored in Ousterhout's deep-module principle — explores a codebase for shallow modules, hidden coupling, and testability seams, spawns parallel sub-agents to design competing interfaces, then writes a structured RFC action file readable by GitHub MCP or ROVO (Jira) MCP |
| **[review-api-design](skills/review-api-design/)** | `/review-api-design` | Reviews REST API designs during the planning phase against security, resilience, design, and operational best practices — produces structured findings with severity levels, source citations, and a readiness assessment |
| **[create-a-skill](skills/create-a-skill/)** | `/create-a-skill` | Create new agent skills from scratch, modify and improve existing skills, and measure skill performance — interviews the user, drafts SKILL.md with bundled resources, runs evals, benchmarks, iterates on feedback, optimises description triggering, and packages distributable `.skill` files |
| **[handoff](skills/handoff/)** | `/handoff` | Saves or loads a structured JSON snapshot of session state so work can resume cleanly in a new session or be delegated to a sub-agent — better than `/compact` because the schema forces every field to be explicit |
| **[agent-os-assist](skills/agent-os-assist/)** | `/agent-os-assist` | Agent OS v3 reference for installation, slash commands, profiles, and ticket-to-spec workflows — holds version-specific documentation not in Claude's training and routes pre-3.0 installs to the migration reference |
| **[agent-os-profile-critique](skills/agent-os-profile-critique/)** | `/agent-os-profile-critique` | Audits and critiques Agent OS v3 profiles and standards — produces severity-tagged findings (blocking, warning, suggestion) with concrete fix recommendations |

### vault-scribe

Your Obsidian vault assistant. Turns unstructured input into well-organised, searchable notes with proper YAML frontmatter, callout blocks, and consistent formatting.

**Supports five note types:**

| Note Type | Use Case |
|---|---|
| `article` | Knowledge base articles, guides, reference docs |
| `meeting` | Meeting notes, 1:1s, standups, retrospectives |
| `brainstorming` | Ideation sessions — solo with AI, one-on-one, or group |
| `strategy` | Versioned plans, OKRs, and living strategy documents |
| `deep-research` | In-depth investigations with multiple sources |

**Key features:**
- GitHub-Flavored Markdown first, Obsidian extensions when needed
- Type-aware YAML frontmatter with enforced schemas
- Automatic transcript appendix formatting
- GFM Alerts for cross-platform callout blocks
- Quality checklist validation before output
- Reference files for frontmatter schemas, callout types, embed syntax, and Markdown compatibility

```
vault-scribe/
├── SKILL.md                          Workflow + quality checklist
├── references/
│   ├── FRONT-MATTER.md               Frontmatter schemas for all note types
│   ├── CALLOUTS.md                   GFM Alerts + Obsidian callout reference
│   ├── EMBEDS.md                     Image + embed syntax (GFM + Obsidian)
│   └── MARKDOWN-SYNTAX.md           Links, tags, math, diagrams, footnotes
└── examples/
    ├── article-example.md            Article with callouts + code blocks
    ├── meeting-brainstorm-example.md  Brainstorming session
    └── transcript-example.md         Article with transcript appendix
```

### agentic-skeleton-dir-structure

Your project scaffolding assistant. Interactively builds production-ready directory structures for agentic AI projects, with [Agent-OS v3](https://github.com/buildermethods/agent-os) by Builder Methods and [Spec-Driven Development (SDD)](https://buildermethods.com/library/spec-driven-development-claude-code) baked in.

**How it works:**

1. **Detects context** — checks if the current directory already has files and warns you before overwriting anything
2. **Asks 6 questions** (one at a time) — repo pattern, platform type, languages, IaC tool, target platform, agent tooling
3. **Shows a summary table** and waits for your confirmation before creating anything
4. **Scaffolds everything** — directories, `CLAUDE.md`, `.claude/` config, `agent-os/` structure, IaC layout, seed files
5. **Guides next steps** — Agent-OS installation, `/plan-product`, and the SDD workflow loop

**Supports any combination of:**

| Dimension | Options |
|---|---|
| Repo pattern | Single Repo, Mono-Repo, Multi-Language Mono-Repo |
| Platform | Frontend, Backend, Full-Stack, Middleware, Agents/AI |
| Language | TypeScript, Python, Go, Java, Rust, Ruby, C#, and more |
| IaC | Terraform, Pulumi, CDK, Bicep, CloudFormation, Helm, Ansible |

**What gets created:**

- `CLAUDE.md` — project instructions loaded every Claude Code session
- `.claude/` — agents, skills, commands, hooks directories
- `agent-os/` — standards, specs, product context (mission, roadmap, tech stack)
- `src/` or `apps/` + `packages/` — language-specific source layout
- `iac/` — IaC structure matching your chosen tool
- `deploy/` — CI/CD pipelines, Docker, deploy scripts
- `docs/` — architecture decision records, API docs, runbooks

```
agentic-skeleton-dir-structure/
├── SKILL.md                          Interactive workflow + quality checklist
├── references/
│   ├── repo-patterns.md              Language + platform source layouts (7 languages)
│   ├── iac-patterns.md               IaC by tool (7 tools) + CI/CD + env promotion
│   └── agent-os-guide.md             Agent-OS install, SDD methodology, commands
└── examples/
    ├── single-repo-typescript.md     Completed single repo TypeScript API scaffold
    └── mono-repo-fullstack.md        Completed mono-repo full-stack scaffold
```

### git-commit-pr-message

Your commit and PR workflow assistant. Generates professional git commit messages, pull request titles and descriptions, changelog entries, and handles releases — all following industry-standard conventions.

**What it does:**

1. **Scans for sensitive content** (API keys, tokens, passwords, private keys) — mandatory gate before any commit
2. **Asks for ticket references** — supports GitHub Issues (all 9 closing keywords) and Jira (pattern-matched ticket keys)
3. **Generates commit messages** — Conventional Commits format with type, scope, subject, body, and footer
4. **Updates CHANGELOG.md** — Keep a Changelog v1.1.0 with all six section types (Added, Changed, Deprecated, Removed, Fixed, Security)
5. **Creates pull requests** — via `gh` CLI or GitHub MCP, with summary, ticket links, changes, and test plan
6. **Cuts releases** — renames Unreleased to versioned section, adds comparison links, optionally creates git tags

**Key features:**
- Conventional Commits with type, scope, and imperative mood enforcement
- All 9 GitHub closing keywords (`close/closes/closed`, `fix/fixes/fixed`, `resolve/resolves/resolved`)
- Jira ticket key detection by pattern (`PROJ-1234`) — no prefix needed
- Keep a Changelog v1.1.0 with comparison links at bottom of file
- Sensitive content scanning with line-level reporting
- User confirmation gates — never commits, pushes, or creates PRs without asking
- Skills v2.0 compliant with `disable-model-invocation`, `allowed-tools`, `argument-hint`

```
git-commit-pr-message/
├── SKILL.md                          Workflow (9 steps) + behavioural rules
└── references/
    └── examples.md                   Commit, PR, changelog, ticket, and scan examples
```

### design-critique

Your design review sparring partner. Stress-tests technical architectures, product plans, and feature designs using structured interviewing techniques drawn from pre-mortem analysis, red teaming, and ATAM (Architecture Tradeoff Analysis Method).

**What it does:**

1. **Orients silently** — explores the codebase or relevant files before asking anything
2. **Anchors the session** — establishes scope with a single opening question
3. **Drills relentlessly** — one question at a time, following the highest-risk thread first
4. **Surfaces hidden assumptions** — names what's unstated and forces trade-off articulation
5. **Closes with a summary** — what held up, what didn't, and what needs resolution before proceeding

**Question patterns it uses:**

| Pattern | Purpose |
|---|---|
| What happens when X fails? | Failure modes |
| What does the alternative look like? | Trade-off articulation |
| How would you know if this is wrong? | Falsifiability |
| What's the cost of reversing this? | Reversibility |
| Walk me through the worst case | Pre-mortem |
| What quality attribute does this sacrifice? | ATAM tradeoff probe |

**Skills 2.0:** `allowed-tools: Read Grep Glob` — `argument-hint: [topic, file, or artifact to critique]` — auto-invokes on trigger phrases; no external tools required

```
design-critique/
└── SKILL.md                          Interviewing principles, question patterns, session flow
```

### arch-lens

Your architectural review assistant. Analyses a codebase through the lens of Ousterhout's deep-module principle — a deep module has a small interface hiding a large implementation, making it testable at the boundary and navigable by AI without reading internals.

Detection is organic, not mechanical: an Explore sub-agent navigates the codebase the way a developer would. The confusion it encounters, the files it has to bounce between, the test boundaries it can't find — that friction IS the signal. No checklists.

**What it does:**

1. **Explores organically** — spawns an Explore sub-agent that navigates the codebase naturally, recording friction: concept scatter, shallow interfaces, unreachable test seams, hidden orchestration, and integration risk at module boundaries
2. **Presents candidate clusters** — groups friction observations into named clusters, each with: modules involved, coupling reason, co-owners, call patterns, shared types, dependency category, and existing tests that a boundary test would replace
3. **Asks what to explore** — single open question; user picks a cluster and directs the angle
4. **Frames the problem space** — principle violated, current interface, dependency category confirmed, blast radius, and what tests currently have to reach through to exercise the behaviour
5. **Spawns parallel sub-agents** — 3–4 agents in parallel, each given an independent technical brief and a distinct design constraint (minimise, maximise flexibility, optimise for common caller, ports & adapters)
6. **Presents designs and recommends** — interface signature, usage example, hidden complexity, dependency strategy, and trade-offs per design; compared in a table and prose; followed by a strong opinionated recommendation or named hybrid
7. **Writes an RFC action file** — `arch-rfcs-YYYY-MM-DD.md` at the project root; one RFC per finding with Problem, Proposed Interface, Dependency Strategy, Testing Strategy, and Implementation Recommendations — structured for direct consumption by GitHub MCP or ROVO (Jira) MCP

**Dependency categories** — every candidate cluster is classified into one of four categories that determine the testing strategy:

| Category | What it means | Testing approach |
|---|---|---|
| In-process | Pure computation, no I/O | Test directly — no adapters |
| Local-substitutable | Infrastructure with a high-fidelity stand-in | Test with PGLite, in-memory FS, etc. |
| Remote but owned | Your services across a network boundary | Ports & adapters — in-memory adapter for tests |
| True external | Third-party services you don't control | Mock at the boundary |

**Testing strategy** — replace, don't layer. Old unit tests on shallow modules become waste once boundary tests exist — delete them. New tests assert on observable outcomes through the public interface, not internal state.

**Sub-agent design constraints:**

| Agent | Constraint |
|---|---|
| Agent 1 | Minimise — 1–3 entry points max, every param essential |
| Agent 2 | Maximise flexibility — support extension without caller changes |
| Agent 3 | Optimise for the common caller — make the default case trivial |
| Agent 4 | Ports & adapters — pure domain interface, all infrastructure injected |

**Skills 2.0:** `allowed-tools: Read Grep Glob Write Bash(git *)` — `argument-hint: [path/to/scope]` — auto-invokes on trigger phrases; requires git for churn analysis

```
arch-lens/
├── SKILL.md                          Workflow summary table + behavioural rules (66 lines)
└── references/
    ├── WORKFLOW.md                   Full step-by-step detail and Explore agent prompt
    ├── DETECTION-PATTERNS.md         Friction vocabulary, dependency categories, testing strategy
    ├── INTERFACE-DESIGN.md           Sub-agent brief template, design constraints, comparison format
    └── RFC-FILE-FORMAT.md            Action file format, effort/priority/label mapping, full example
```

### review-api-design

Your API design review assistant. Vets REST API designs during the planning phase — before a single line of code is written. Produces structured review documents with severity-rated findings, source citations, and a readiness assessment.

**What it does:**

1. **Gathers context** — asks about domain, consumers, scale, auth requirements, deployment, and team experience (skips questions already answered by the input)
2. **Loads relevant references** — selectively reads from 10 domain-specific checklists based on what the design needs
3. **Conducts systematic review** — evaluates against security, resilience, design principles, payloads, extensibility, communication patterns, gateways, and operational best practices
4. **Produces a structured review** — summary table, detailed findings (What/Why/Recommendation with source citations), "What's Missing" gap analysis, and readiness assessment

**Review domains (10 reference files):**

| Domain | What It Covers |
|--------|---------------|
| Design Principles | Naming, versioning, CRUD, idempotency, health checks, tracing, parameters, ID exposure |
| Payloads & Errors | Response structure, pagination, RFC 9457 errors, identifiers, content negotiation |
| Security (Auth) | Zero trust, OAuth 2.0/2.1, RBAC/ABAC, MFA/passkeys, JWT, rate limiting, sessions, risk-based security |
| Security (Defense) | Enumeration, information disclosure, input validation, CORS, CSRF, security headers, OWASP API Top 10 |
| Extensibility | Fixed vs variable arity, metadata escape hatches, SOLID principles, response evolution, Hyrum's Law |
| Resilience | Retries, circuit breakers, timeouts, bulkheads, caching, observability, SLIs/SLOs |
| Communication Patterns | REST vs GraphQL vs WebSockets vs SSE — when to use each, hybrid architectures |
| API Gateways | Gateway patterns, product comparison, when to use/skip |
| Human Aspect | Adoption, documentation, NFRs, testing strategy |
| Pragmatism | Dependencies, framework lock-in, build vs buy |

**Invocation note:** This skill works best when invoked explicitly via `/review-api-design`. It may also activate during plan mode when API design decisions are being made, but explicit invocation is more reliable.

```
review-api-design/
├── SKILL.md                          Workflow + output format + example
├── evals/
│   └── evals.json                    3 test cases
└── references/
    ├── design-principles.md          Naming, versioning, CRUD, parameters
    ├── design-extensibility.md       Arity, metadata, SOLID, response evolution
    ├── payloads-errors.md            Response structure, pagination, errors, IDs
    ├── security-auth.md              Identity, auth, tokens, trust boundaries
    ├── security-defense.md           Enumeration, CSRF, CORS, info disclosure
    ├── resilience.md                 Retries, circuit breakers, observability
    ├── api-communication-patterns.md REST vs GraphQL vs WebSockets vs SSE
    ├── api-gateways.md               Gateway patterns and product comparison
    ├── human-aspect.md               Adoption, documentation, NFRs
    ├── pragmatism.md                 Dependencies, lock-in, build vs buy
    └── sources.md                    Consolidated references (cited in findings)
```

### create-a-skill

Your skill authoring assistant. Walks you through the full lifecycle of creating, testing, and shipping an agent skill — from initial interview through packaging a distributable `.skill` file.

**What it does:**

1. **Gathers requirements** — interviews you about the skill's purpose, triggers, output format, edge cases, and dependencies; researches the domain via web search and MCPs
2. **Drafts the skill** — writes SKILL.md with proper frontmatter, progressive disclosure, bundled scripts, and reference files
3. **Tests with evals** — spawns parallel runs (with-skill vs baseline), drafts assertions, grades outputs, and aggregates benchmarks
4. **Iterates on feedback** — launches an interactive viewer for qualitative review, reads your feedback, and rewrites the skill
5. **Optimises description** — generates trigger eval queries, runs an automated optimisation loop with train/test split to maximise triggering accuracy
6. **Packages** — validates and creates a `.skill` zip file ready for distribution

**Key features:**
- Detailed user interview before writing a single line
- Web research for unfamiliar domains
- Quantitative eval loop with grading, benchmarking, and analyst pass
- Interactive HTML viewer for qualitative review
- Blind A/B comparison between skill versions (advanced)
- Description optimisation with train/test split to prevent overfitting
- Skill 2.0 compliant output

**License note:** This skill is a derivative work incorporating material from Anthropic's [skill-creator](https://github.com/anthropics/skills) (Apache 2.0) and Matt Pocock's [write-a-skill](https://github.com/mattpocock/skills) (MIT). See `skills/create-a-skill/NOTICE` and `skills/create-a-skill/LICENSE.txt` for details.

```
create-a-skill/
├── SKILL.md                          Workflow (6 phases) + writing guide
├── agents/
│   ├── grader.md                     Assertion evaluation against outputs
│   ├── comparator.md                 Blind A/B comparison
│   └── analyzer.md                   Post-hoc analysis + benchmark patterns
├── assets/
│   └── eval_review.html              Trigger eval review UI template
├── eval-viewer/
│   ├── generate_review.py            Interactive result viewer server
│   └── viewer.html                   Viewer HTML template
├── references/
│   └── schemas.md                    JSON schemas for all data structures
├── scripts/
│   ├── quick_validate.py             SKILL.md validation
│   ├── package_skill.py              .skill file packaging
│   ├── run_eval.py                   Trigger testing
│   ├── run_loop.py                   Description optimisation loop
│   ├── improve_description.py        Description improvement
│   ├── aggregate_benchmark.py        Benchmark aggregation
│   ├── generate_report.py            HTML report generation
│   └── utils.py                      Shared utilities
├── LICENSE.txt                       Apache License 2.0
└── NOTICE                            Attribution notice
```

---

## Installation

### Via npx (works with Claude Code, Codex, Cursor)

Install all skills:

```bash
npx skills add psenger/ai-agent-skills
```

List all available skills:

```bash
npx skills list psenger/ai-agent-skills
```

Install a specific skill:

```bash
npx skills add psenger/ai-agent-skills --skill vault-scribe
```

Install locally for customisation:

```bash
npx skills add psenger/ai-agent-skills --skill vault-scribe --local
```

### Via Claude Code Marketplace

```bash
claude plugin marketplace add psenger/ai-agent-skills
claude plugin install vault-scribe@psenger-skills-marketplace
```

### Manual Installation

Clone the repo and copy the skill folder:

```bash
# Global (available in all projects)
cp -r skills/vault-scribe ~/.claude/skills/vault-scribe

# Local (project-specific)
cp -r skills/vault-scribe .claude/skills/vault-scribe
```

> **Global vs Local**
>
> **Global** (`~/.claude/skills/`) — skills that apply everywhere.
> **Local** (`.claude/skills/`) — project-specific customisations. Local skills override global skills of the same name.

---

## Usage

Once installed, skills activate automatically based on your request. You can also invoke them directly:

### vault-scribe

```
/vault-scribe article
/vault-scribe meeting
/vault-scribe brainstorming
/vault-scribe strategy
/vault-scribe deep-research
```

Or describe what you need — the skill triggers on context:

```
"Turn this transcript into an Obsidian note"
"Write up meeting notes from today's standup"
"Create a strategy doc for the Q3 roadmap"
```

### agentic-skeleton-dir-structure

```
/agentic-skeleton-dir-structure
/agentic-skeleton-dir-structure single
/agentic-skeleton-dir-structure mono
/agentic-skeleton-dir-structure multi-lang
```

Or describe what you need — the skill triggers on context:

```
"Set up a new project for an agentic AI service"
"Scaffold a mono-repo for my full-stack TypeScript app"
"Create a directory structure for this project"
"Initialize an Agent-OS project layout"
```

Pass a repo pattern as an argument to skip the first question. Without arguments, the skill walks you through all six questions interactively.

### git-commit-pr-message

```
/git-commit-pr-message commit
/git-commit-pr-message pr
/git-commit-pr-message changelog
/git-commit-pr-message release
```

Or describe what you need — the skill triggers on context:

```
"Commit these changes"
"Create a PR for this branch"
"Update the changelog"
"Cut a release for v1.2.0"
```

Note: This skill has `disable-model-invocation: true`, so it will only activate when you explicitly invoke it — it will never auto-trigger during normal conversation.

### design-critique

```
/design-critique
```

Or trigger it naturally:

```
"Grill me on this architecture"
"Stress-test this plan"
"Pre-mortem this feature design"
"Red team my approach"
"Critique this"
```

The skill self-directs toward relevant context — if it has file access, it reads the codebase silently before asking its first question.

### arch-lens

```
/arch-lens
/arch-lens src/payments
```

Or trigger it naturally:

```
"Arch review this codebase"
"Find shallow modules"
"Surface coupling and testability issues"
"Run an Ousterhout review on src/"
"Find architectural friction"
"Audit the module depth"
```

Pass an optional path to scope the analysis to a specific directory. Without arguments, the skill analyses the full repository. The skill walks you through all seven steps interactively — it will not proceed past candidate confirmation or interface selection without your input. The final output is an `arch-rfcs-YYYY-MM-DD.md` file at the project root ready to action with your GitHub or Jira MCP tooling.

### review-api-design

```
/review-api-design
/review-api-design POST /users, GET /users/{id}, DELETE /users/{id}
```

Or trigger it naturally:

```
"Review my API"
"API design review"
"Vet this REST contract"
"Check my endpoints"
"Is this endpoint structure any good?"
```

Pass an endpoint list or OpenAPI spec as an argument, or paste it in a follow-up message. For vague verbal descriptions ("I'm building an API for X"), the skill asks clarifying questions before producing a review. The output is a structured review document with severity-rated findings and a readiness assessment.

**Note:** This skill works most reliably when invoked explicitly with `/review-api-design`. It may auto-trigger during plan mode conversations about API design, but explicit invocation is recommended.

### create-a-skill

```
/create-a-skill
```

Or trigger it naturally:

```
"I want to make a skill for X"
"Turn this into a skill"
"Create a skill that does Y"
"Write a skill for managing Z"
"Help me build a new skill"
```

The skill interviews you about requirements before writing anything. It handles the full lifecycle — from initial draft through eval, iteration, description optimisation, and packaging.

### handoff

Captures the complete state of your current session to a structured JSON snapshot so you can resume cleanly in a new session, switch task phases, or delegate work to a sub-agent without losing context.

**Two modes:**

| Mode | When to use |
|---|---|
| CREATE | Session approaching 300–400k tokens, switching phases, delegating to a sub-agent, or starting fresh with correct state |
| RESUME | Loading a prior snapshot to continue where you left off |

**Why it beats `/compact`:** Compaction is lossy and exhibits recency bias. The schema forces every field — goal, decisions, completed steps, pending steps, constraints, discovered issues, modified files — to be explicit. Nothing is silently dropped.

```
/handoff                          # save to .claude/handoffs/<timestamp>-<slug>.json
/handoff auth-refactor.json       # save to explicit path
/handoff load auth-refactor.json  # resume from file
```

### agent-os-assist

Your Agent OS v3 reference. Covers installation, slash commands, profiles, standards, and ticket-to-spec workflows — with the version-specific documentation not in Claude's training data.

**Use cases:**

- Bootstrap a fresh Agent OS v3 install end-to-end
- Turn a Jira or GitHub ticket into a `/shape-spec` run
- Configure profile inheritance in `~/agent-os/config.yml`
- Write your first standard after installing Agent OS
- Recover a broken spec without losing conversation history
- Migrate from v2 artifacts to v3 conventions

```
/agent-os-assist
```

Or trigger it naturally:

```
"How do I install Agent OS?"
"Turn this GitHub issue into an Agent OS spec"
"What should be in ~/agent-os/config.yml?"
"I just installed agent-os, where do I start?"
"My spec is wrong — how do I recover without losing history?"
```

```
agent-os-assist/
├── SKILL.md                          Routing table + workflow overview
└── references/
    ├── getting-started.md            Bootstrap and onboarding workflows
    ├── installation.md               Install and scaffold steps
    ├── commands.md                   Slash command reference
    ├── profiles.md                   Profile structure and inheritance
    ├── standards.md                  Writing and managing standards
    ├── standards-vs-skills.md        When to use a standard vs a skill
    ├── file-structure.md             v3 directory layout
    └── v2-vs-v3.md                   Migration reference and v2 artifact flags
```

### agent-os-profile-critique

Your Agent OS profile audit assistant. Reviews profiles and standards files against v3 conventions and produces severity-tagged findings with concrete rewrite suggestions.

**Severity levels:**

| Level | Meaning |
|---|---|
| Blocking | Must fix before the profile is usable |
| Warning | Should fix; degrades AI effectiveness or causes drift |
| Suggestion | Improves clarity, context-window efficiency, or maintainability |

```
/agent-os-profile-critique
```

Or trigger it naturally:

```
"Audit my Agent OS profile"
"Review this standard — is it any good?"
"Critique my agent-os setup"
"What's wrong with this standards file?"
"Validate my profile against v3 conventions"
```

```
agent-os-profile-critique/
├── SKILL.md                          Routing table + audit workflow
└── references/
    ├── review-checklists.md          Severity-tagged audit checklists
    ├── standards.md                  Standards quality criteria
    ├── file-structure.md             v3 directory layout reference
    ├── profiles.md                   Profile conventions
    ├── standards-vs-skills.md        Standards vs skills decision guide
    └── v2-vs-v3.md                   v2 artifact detection patterns
```

---

## Adding a New Skill

1. Create a folder under `skills/` with a lowercase-hyphenated name
2. Add a `SKILL.md` with YAML frontmatter and process instructions
3. Add reference files in `references/` if needed
4. Add examples in `examples/` for better activation rates
5. Add an entry to `.claude-plugin/marketplace.json`
6. Update this README table
7. Open a pull request

```
skills/<skill-name>/
├── SKILL.md              Required — metadata + instructions
├── references/            Optional — detailed reference material
└── examples/              Optional — example input/output pairs
```

---

## Author

**Philip A Senger**

- GitHub: [@psenger](https://github.com/psenger)

---

## License

This project is licensed under the [MIT License](LICENSE).

Copyright (c) 2026 Philip A Senger
