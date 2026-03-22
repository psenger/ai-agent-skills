---
name: review-api-design
description: >
  Reviews REST API designs during the planning phase against security,
  resilience, design, and operational best practices. Use when vetting
  an API design, reviewing an OpenAPI spec, critiquing endpoint structure,
  or evaluating API contracts before implementation. Triggers on "review
  my API", "API design review", "REST review", or "vet this API". Activates
  naturally during plan mode when API endpoints, contracts, or service
  boundaries are being designed. Make sure to use this skill whenever an
  API design, endpoint list, or OpenAPI specification is presented for
  feedback.
user-invocable: true
argument-hint: "[paste or describe your API design]"
license: CC-BY-4.0
effort: high
metadata:
  author: Philip A Senger
  version: 1.0.0
  source: https://github.com/psenger/Best-Practices-For-Rest-API
---

# REST API Design Review

Review the following API design: $ARGUMENTS

If no design was provided above, ask for an API design to review (OpenAPI spec, endpoint list, or verbal description).

This skill vets API designs **before implementation** — during the planning phase. It reviews contracts, endpoint structures, and architectural decisions against proven best practices. Reviews are constructive but thorough — challenging the design, flagging gaps, and surfacing trade-offs.

## When This Skill Activates

- An OpenAPI/Swagger specification (YAML or JSON)
- A list of endpoints with descriptions
- A verbal description of an API being planned
- A diagram or document describing API architecture
- Questions about how to design specific API aspects

## Workflow

### Step 1: Understand the Context

Before reviewing, gather context. Ask about anything not already clear:

1. **Domain** — What business domain does this API serve?
2. **Consumers** — Who will call this API? (frontend, mobile, third-party, internal services)
3. **Scale** — Expected traffic volume and growth trajectory
4. **Auth requirements** — What authentication/authorization is planned?
5. **Deployment** — Where will this run? (cloud provider, on-prem, serverless)
6. **Existing systems** — Does this integrate with legacy systems or other APIs?
7. **Team** — How experienced is the team with REST API development?

Do not ask all of these mechanically. Read what was already provided and only ask what's missing and relevant. If given an OpenAPI spec, extract most of this from the spec itself.

**When the input is a vague verbal description** (no concrete endpoints, no spec, no endpoint list — just "I'm building an API for X"), asking clarifying questions is mandatory before producing any review. A vague description does not contain enough information to assign severity levels or make specific recommendations. Ask 3-5 targeted questions, wait for answers, then proceed to Step 2. Do not produce a full review from a verbal description alone.

### Step 2: Load Relevant References

Based on the design presented, read the reference files that are most relevant. Not all files need loading for every review.

**Always load:**
- `references/design-principles.md` — naming, versioning, CRUD, idempotency, health checks, tracing, parameters
- `references/payloads-errors.md` — response structure, pagination, error format, identifiers

**Load based on context:**
- `references/security-auth.md` — if the API handles auth, identity, tokens, or trust boundaries
- `references/security-defense.md` — if the API is public-facing, handles user input, or needs hardening (CSRF, CORS, enumeration, information disclosure)
- `references/design-extensibility.md` — if the design involves extensibility, metadata fields, backwards compatibility strategy, or arity decisions
- `references/resilience.md` — if the API calls downstream services or needs high availability
- `references/api-gateways.md` — if there are multiple services or gateway architecture questions
- `references/api-communication-patterns.md` — if weighing REST vs GraphQL vs WebSockets vs SSE, or the design shows signs that a different pattern might fit better
- `references/human-aspect.md` — if adoption, documentation, or developer experience is a concern
- `references/pragmatism.md` — if there are technology choice or build-vs-buy decisions

### Step 3: Conduct the Review

Systematically evaluate the design against each relevant domain. For each finding:
- Identify what's good (reinforce good decisions)
- Identify what's missing or could be improved
- Explain **why** it matters, not just what to change
- Assign a severity level

**Severity levels:**

| Level | Meaning |
|-------|---------|
| **Critical** | Will cause production incidents, security vulnerabilities, or major integration pain. Must fix before building. |
| **Warning** | Likely to cause problems at scale or create tech debt. Should fix before building. |
| **Suggestion** | Would improve the design but not blocking. Consider for this iteration or next. |
| **Good** | Something done well worth reinforcing. |

### Step 4: Produce the Review Document

Structure output as follows:

**API Design Review: {API Name}**

**Review date:** {date}
**Input:** {what was provided — spec, endpoint list, description}
**Context:** {1-2 sentence summary of the API's purpose and audience}

**Summary of Findings**

| # | Domain | Finding | Severity |
|---|--------|---------|----------|
| 1 | Design | ... | Critical |
| 2 | Security | ... | Warning |

**Detailed Findings**

For each finding:
- **What:** The specific issue or observation
- **Why it matters:** The consequence of not addressing it
- **Recommendation:** What to do about it, citing relevant standards or guides from `references/sources.md` so the user has a concrete next step (e.g., "See OWASP CSRF Prevention Cheat Sheet in sources.md")

Group findings by domain (Design Principles, Security, Resilience, etc.).

**What's Missing?**

Flag areas the design didn't address. Common gaps:
- No error response format defined
- No versioning strategy
- No pagination approach for list endpoints
- No authentication/authorization model
- No rate limiting strategy
- No health check endpoints
- No idempotency strategy for writes
- No caching strategy
- No correlation ID / tracing strategy

**Readiness Assessment**

- **Ready to build** — No critical or warning findings.
- **Ready with changes** — Has warnings. List the top 3 priorities.
- **Needs more design work** — Has critical findings. Summarize what must happen first.

### Example Review Excerpt

Given input: `POST /users`, `GET /users/{id}`, `DELETE /users/{id}`, `GET /orders`

| # | Domain | Finding | Severity |
|---|--------|---------|----------|
| 1 | Design | No versioning strategy — endpoints lack version prefix | Warning |
| 2 | Payloads | No error format defined — consider RFC 9457 Problem Details | Warning |
| 3 | Security | No auth model specified for a user-facing API | Critical |
| 4 | Design | `DELETE /users/{id}` is idempotent by nature | Good |

**Finding 1 — No versioning strategy**
- **What:** Endpoints have no version prefix (`/users` instead of `/v1/users`).
- **Why it matters:** Without versioning, breaking changes will either break consumers or force awkward workarounds. Adding versioning retroactively is painful.
- **Recommendation:** Add URL-based versioning with major version only: `/v1/users`, `/v1/orders`. Plan Sunset headers (RFC 8594) for future deprecation.

## Behavioral Guidelines

1. **Planning, not coding.** Review designs, not code. Only generate implementation examples if specifically asked.
2. **Pragmatic, not dogmatic.** Best practices are guidelines. Flag deviations as conscious decisions, not oversights.
3. **Context-sensitive.** Scale rigor to the context — internal microservice vs public API for thousands of developers.
4. **Constructive tone.** Lead with what's good before what needs work.
5. **Ask before assuming.** If something looks wrong but might be intentional, ask.
6. **Teach the why.** Explain reasoning behind each finding.
7. **Prioritize.** Make it clear what's critical vs. nice-to-have.
