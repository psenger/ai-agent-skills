# API Design Review: E-Commerce Platform API

**Review date:** 2026-03-22
**Input:** Endpoint list (7 endpoints for users and orders resources)
**Context:** REST API for an e-commerce platform serving user management and order operations, built with Express and PostgreSQL. Consumers not specified — assumed to include at least a frontend (web/mobile). Scale and auth requirements not stated.

---

## Summary of Findings

| # | Domain | Finding | Severity |
|---|--------|---------|----------|
| 1 | Security | No authentication or authorization model specified | Critical |
| 2 | Design | No versioning strategy — endpoints lack version prefix | Critical |
| 3 | Security | No rate limiting strategy defined | Warning |
| 4 | Payloads | No error response format defined | Warning |
| 5 | Payloads | No pagination strategy for list endpoints (`GET /users`, `GET /orders`) | Warning |
| 6 | Design | No idempotency key strategy for POST operations | Warning |
| 7 | Security | ID format not specified — risk of sequential/enumerable IDs | Warning |
| 8 | Design | Missing PATCH endpoints for partial updates | Warning |
| 9 | Design | No health check endpoints defined | Warning |
| 10 | Design | No correlation ID / distributed tracing strategy | Warning |
| 11 | Security | Express `X-Powered-By` header leaks technology stack | Warning |
| 12 | Security | No input validation strategy defined | Warning |
| 13 | Resilience | No caching strategy defined | Suggestion |
| 14 | Design | No OpenAPI/contract-first approach mentioned | Suggestion |
| 15 | Design | `DELETE /users/{id}` and `PUT /users/{id}` are idempotent by nature | Good |
| 16 | Design | Resource names are plural and use nouns, not verbs | Good |
| 17 | Design | HTTP methods map correctly to CRUD operations | Good |
| 18 | Design | Resources reflect business domain (users, orders) rather than database tables | Good |

---

## Detailed Findings

### Design Principles

**Finding 1 — No versioning strategy (Critical)**

- **What:** Endpoints have no version prefix (`/users` instead of `/v1/users`). No versioning strategy (URL-based, header-based, or otherwise) has been mentioned.
- **Why it matters:** Without versioning, breaking changes will either break existing consumers or force awkward workarounds. Adding versioning retroactively is painful and requires coordinating all consumers simultaneously. For an e-commerce platform that will inevitably evolve (new payment methods, shipping options, user attributes), this is a matter of when, not if.
- **Recommendation:** Add URL-based versioning with major version only: `/v1/users`, `/v1/orders`. Plan Sunset headers (RFC 8594) for future deprecation. See Stripe API Versioning in `sources.md` for a mature example of API version management.

**Finding 8 — Missing PATCH endpoints for partial updates (Warning)**

- **What:** The design includes `PUT /users/{id}` for updates but no `PATCH` endpoints. There is no update endpoint for orders at all.
- **Why it matters:** `PUT` requires the client to send the complete resource representation. For user profiles with many fields, this is wasteful and error-prone — clients must fetch the current state, merge changes, and send everything back. This also creates race conditions when two clients update different fields simultaneously. For orders, the lack of any update mechanism means the design cannot handle common e-commerce flows like updating shipping addresses or applying coupons.
- **Recommendation:** Add `PATCH /v1/users/{id}` for partial updates (using JSON Merge Patch or JSON Patch). Consider what order state transitions are needed and model them appropriately — for domain actions like cancellation, consider `POST /v1/orders/{id}/cancel` rather than generic `PATCH` (see Domain-Driven Design guidance in `references/design-principles.md`). Per RFC 9110, use `PUT` for full replacement and `PATCH` for partial modification.

**Finding 6 — No idempotency key strategy for POST operations (Warning)**

- **What:** `POST /users` and `POST /orders` are non-idempotent by nature, and no idempotency key mechanism is described.
- **Why it matters:** Network failures and client retries can result in duplicate user accounts or duplicate orders. In an e-commerce context, duplicate orders mean double charges, duplicate shipments, and customer complaints. This is especially dangerous for `POST /orders` where real money is involved.
- **Recommendation:** Support an `Idempotency-Key` header (UUID format) on all POST endpoints. Store the key with a 24-48 hour TTL and return the cached response for duplicate requests. See Stripe Idempotent Requests in `sources.md` for the industry-standard implementation pattern.

**Finding 9 — No health check endpoints (Warning)**

- **What:** The endpoint list includes no health or readiness check endpoints.
- **Why it matters:** Without health checks, load balancers and orchestrators (Kubernetes, ECS) cannot determine if the service is alive or ready to accept traffic. This leads to routing traffic to unhealthy instances, longer outages during deployments, and difficulty diagnosing production issues. With PostgreSQL as a dependency, a readiness check that verifies database connectivity is essential.
- **Recommendation:** Add `GET /health/live` (is the process running — no dependency checks) and `GET /health/ready` (can it serve traffic — check PostgreSQL connection). Return `200` for healthy, `503` for unhealthy.

**Finding 10 — No correlation ID / distributed tracing strategy (Warning)**

- **What:** No mention of request tracing, correlation IDs, or observability strategy.
- **Why it matters:** When a customer reports "my order failed," you need to trace that request across the Express application, PostgreSQL queries, and any downstream services. Without correlation IDs, debugging production issues becomes a log-grepping exercise. This gets exponentially harder as the platform grows.
- **Recommendation:** Generate an `X-Request-ID` for each request (or accept one from the client/gateway). Log it in every log line. Consider adopting W3C Trace Context or OpenTelemetry from the start. See W3C Trace Context and OpenTelemetry in `sources.md`.

**Finding 14 — No OpenAPI/contract-first approach mentioned (Suggestion)**

- **What:** The API is presented as an endpoint list rather than a formal OpenAPI specification.
- **Why it matters:** Contract-first development enables parallel frontend/backend development, generates client SDKs automatically, produces always-current documentation, and catches design flaws before code is written. Starting with an endpoint list and coding first typically results in APIs shaped by implementation convenience rather than consumer needs.
- **Recommendation:** Create an OpenAPI 3.1 specification before implementation. Use it to generate Express route stubs and client SDKs. Consider contract testing with Pact (see `sources.md`).

**Findings 15-18 — Good practices**

- **What:** Resource names are plural (`/users`, `/orders`), use nouns not verbs, and HTTP methods map correctly to CRUD operations (POST for create, GET for read, PUT for update, DELETE for delete). The resources reflect the business domain. `DELETE /users/{id}` and `PUT /users/{id}` are naturally idempotent.
- **Why it matters:** These are foundational REST design decisions done correctly. They make the API intuitive for consumers and follow established conventions per RFC 9110.

---

### Security

**Finding 1 — No authentication or authorization model specified (Critical)**

- **What:** The design specifies no authentication mechanism, no authorization model, and no mention of who can access what. An e-commerce API handles PII (user data), financial transactions (orders), and account management (create/delete users).
- **Why it matters:** Without auth, anyone can read any user's data, place orders on behalf of others, or delete accounts. This is OWASP API Security #1 (Broken Object Level Authorization) and #2 (Broken Authentication) waiting to happen. User endpoints expose PII; order endpoints involve financial transactions. Both are high-value targets.
- **Recommendation:** Define the auth model before building. At minimum: (1) Choose an identity provider (Auth0, Keycloak, Zitadel — do not build your own). (2) Use OAuth 2.0 / OIDC with PKCE for frontend/mobile clients. (3) Implement RBAC: regular users can only access their own resources; admin users can list/manage all. (4) Enforce object-level authorization — `GET /users/{id}` must verify the caller owns that user ID or is an admin. See OWASP API Security Top 10 and RFC 9700 in `sources.md`.

**Finding 3 — No rate limiting strategy (Warning)**

- **What:** No rate limiting is mentioned for any endpoint.
- **Why it matters:** Without rate limiting, the API is vulnerable to brute-force attacks (credential stuffing on login flows), resource exhaustion (automated order creation), and data scraping (`GET /orders` enumeration). Express without rate limiting will happily serve requests until PostgreSQL connection pools are exhausted.
- **Recommendation:** Implement rate limiting at the Express layer (e.g., `express-rate-limit`) and/or at a gateway. Apply stricter limits on auth-related and write endpoints. Return `429 Too Many Requests` with `Retry-After` header. Use standard rate limit headers per the IETF Rate Limit Headers draft (see `sources.md`).

**Finding 7 — ID format not specified (Warning)**

- **What:** The design uses `{id}` parameters but doesn't specify the ID format. If PostgreSQL serial/bigserial integers are used directly, these are sequential and enumerable.
- **Why it matters:** Sequential IDs in a public-facing e-commerce API enable enumeration attacks: an attacker can iterate `GET /users/1`, `/users/2`, `/users/3` to scrape all user data. Sequential IDs also reveal business intelligence (how many users/orders exist, growth rate). This makes BOLA exploitation trivial.
- **Recommendation:** Use UUIDs (PostgreSQL `uuid` type with `gen_random_uuid()`) or type-prefixed random IDs (e.g., `user_abc123`, `order_xyz789` following the Stripe pattern). Represent IDs as strings in JSON responses to avoid JavaScript precision issues with large integers. See the Identifiers section in `references/payloads-errors.md`.

**Finding 11 — Express `X-Powered-By` header (Warning)**

- **What:** Express sends an `X-Powered-By: Express` header by default, and the `Server` header may also reveal infrastructure details.
- **Why it matters:** These headers tell attackers exactly what framework and potentially what version you are running, enabling targeted exploits. This is unnecessary information disclosure.
- **Recommendation:** Disable with `app.disable('x-powered-by')` or use Helmet middleware (`helmet()` strips this and adds security headers). Also remove or genericize the `Server` header. See Information Disclosure Prevention in `references/security-defense.md`.

**Finding 12 — No input validation strategy (Warning)**

- **What:** No mention of input validation, request body schema enforcement, or size limits.
- **Why it matters:** Without input validation, the API is vulnerable to SQL injection (especially relevant with PostgreSQL), payload size attacks (sending a 100MB JSON body), and data integrity issues. Express does not enforce any schema validation by default.
- **Recommendation:** Define request body schemas in OpenAPI and enforce them with validation middleware (e.g., `express-openapi-validator`, `joi`, `zod`). Set max body size (`express.json({ limit: '100kb' })`). Use parameterized queries (never string concatenation) for PostgreSQL. See OWASP Input Validation Cheat Sheet in `sources.md`.

---

### Payloads & Errors

**Finding 4 — No error response format defined (Warning)**

- **What:** No error format is specified for any endpoint.
- **Why it matters:** Without a consistent error format, every endpoint will invent its own error shape. Frontend developers will write different error handling code for every endpoint. Support burden increases because error messages are inconsistent. This is especially painful in e-commerce where validation errors (invalid address, payment declined, out of stock) are frequent and need to be displayed clearly to users.
- **Recommendation:** Adopt RFC 9457 Problem Details as the error format. Return `Content-Type: application/problem+json` for all errors. Include structured validation errors with `field`, `code`, and `message`. Ensure stack traces and database errors are never exposed in production. See RFC 9457 in `sources.md`.

**Finding 5 — No pagination strategy for list endpoints (Warning)**

- **What:** `GET /orders` and (implied) `GET /users` are list endpoints with no pagination strategy defined.
- **Why it matters:** Without pagination, these endpoints will return all records. As the e-commerce platform grows, `GET /orders` will eventually return thousands or millions of records in a single response, causing timeouts, memory exhaustion in Express, and heavy PostgreSQL load. Even at modest scale, unbounded queries are a performance and availability risk.
- **Recommendation:** Implement cursor-based pagination for `GET /orders` (orders are time-series data — cursor-based handles this well and avoids the `OFFSET` performance penalty in PostgreSQL). Include `next`/`prev` links in responses. Set a maximum page size (e.g., 100) and a sensible default (e.g., 20). Consider whether `GET /users` should even be a public endpoint or admin-only. See Pagination in `references/payloads-errors.md` and Slack API Pagination in `sources.md`.

---

### Resilience

**Finding 13 — No caching strategy defined (Suggestion)**

- **What:** No caching headers or strategy mentioned.
- **Why it matters:** For an e-commerce platform, product/order data has different caching profiles. Without planning cache headers from the start, you will either over-fetch from PostgreSQL (performance penalty) or add caching later in an ad-hoc way that creates stale data bugs. User data should use `Cache-Control: private, no-cache` with ETags for revalidation. Order lists may benefit from short TTLs.
- **Recommendation:** Plan `Cache-Control`, `ETag`, and `Vary` headers per endpoint. Use `no-store` for sensitive data. Consider `stale-while-revalidate` for frequently accessed, tolerant-of-staleness data. See Caching in `references/resilience.md`.

---

## What's Missing?

The following areas were not addressed in the design:

| Gap | Impact |
|-----|--------|
| **No authentication/authorization model** | Cannot secure any endpoint. Blocks implementation. |
| **No versioning strategy** | First breaking change will break all consumers. |
| **No error response format** | Inconsistent error handling across frontend. |
| **No pagination approach** | List endpoints will fail at scale. |
| **No rate limiting strategy** | Vulnerable to abuse and resource exhaustion. |
| **No health check endpoints** | Cannot integrate with orchestrators or load balancers. |
| **No idempotency strategy for writes** | Duplicate orders/users from retries. |
| **No caching strategy** | Unnecessary database load, missed performance gains. |
| **No correlation ID / tracing strategy** | Cannot debug production issues efficiently. |
| **No input validation strategy** | SQL injection and data integrity risks. |
| **No CORS configuration mentioned** | If browser clients will call this API, CORS must be planned. |
| **No relationship between users and orders** | Should `GET /orders` return only the authenticated user's orders? Can users see other users' orders? No scoping defined. |
| **No sub-resources or filtering** | No `GET /users/{id}/orders` to get a user's orders. No filtering on `GET /orders` (by status, date range, etc.). |

---

## Readiness Assessment

**Needs more design work** -- The design has two critical findings and ten warnings that must be addressed before implementation.

**Before building, the team must:**

1. **Define the authentication and authorization model.** Choose an identity provider, decide on OAuth 2.0/OIDC, and define who can access what (object-level authorization). This is the single most important gap -- an e-commerce API without auth is a data breach waiting to happen.

2. **Add API versioning.** Prefix all endpoints with `/v1/`. This is a one-time decision that is trivial now and painful later.

3. **Define the error format, pagination strategy, and ID format.** These are cross-cutting decisions that affect every endpoint. Changing them after consumers are built requires coordinated migration.

Once these three areas are addressed, revisit the warning-level findings (rate limiting, idempotency, health checks, input validation, tracing) before going to production.
