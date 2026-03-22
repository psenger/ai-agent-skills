# Design Principles — Design Review Checklist

Source: [Best Practices for REST API](https://github.com/psenger/Best-Practices-For-Rest-API) by Philip A Senger (CC BY 4.0)

---

## Table of Contents

1. [Contract-First Development](#contract-first-development)
2. [Domain-Driven Design](#domain-driven-design)
3. [API as a Product](#api-as-a-product)
4. [Naming Convention](#naming-convention)
5. [Versioning](#versioning)
6. [CRUD and HTTP Methods](#crud-and-http-methods)
7. [HATEOAS and Self-Discovery](#hateoas-and-self-discovery)
8. [Idempotency](#idempotency)
9. [Conditional Requests](#conditional-requests)
10. [CORS](#cors)
11. [Health Checks](#health-checks)
12. [Request Tracing](#request-tracing)
13. [Parameters](#parameters)
14. [Attribute Convention](#attribute-convention)

---

## Contract-First Development

Define the API contract before writing implementation code.

**Check for:**
- Is the OpenAPI spec written first, before implementation?
- Has the spec been reviewed with consumers (frontend, mobile, partners)?
- Will server stubs and client SDKs be generated from the spec?
- Is contract testing planned to ensure implementation matches spec? (Pact)

**Why contract-first matters:**
- Parallel development — frontend and backend work simultaneously
- Catch design flaws early — cheaper to change a spec than refactor code
- Better APIs — designing without implementation pressure yields better decisions
- Documentation is always current — the spec is the source of truth

> The alternative (code-first with generated docs) leads to APIs shaped by implementation convenience rather than consumer needs.

---

## Domain-Driven Design

The API should reflect the business domain, not the database schema.

**Check for:**
- Does the API use the same terms the business uses? (ubiquitous language)
- Are bounded contexts respected? (same term can mean different things in different domains)
- Are aggregates exposed as roots? (`/orders/{id}` not `/line-items/{id}`)
- Is there an anti-corruption layer for legacy system integration?

**Red flags:**
- Endpoints named after database tables
- `PUT /orders/{id}/status` with body `{ "status": "cancelled" }` instead of `POST /orders/{id}/cancel`
- URLs like `/database/customers/join/orders`

---

## API as a Product

- Is naming consistent across all endpoints? (don't mix `created_at` and `createdDate`)
- Is versioning treated as a promise? (v1 means you won't break it)
- Are error messages educational? (tell the developer what went wrong and how to fix it)
- Is there a deprecation strategy? (warnings, migration paths, timelines)

---

## Naming Convention

**Check for:**
- Are endpoints nouns, not verbs?

| Bad | Good |
|-----|------|
| `/doPayroll` | `/payroll` |
| `/createUser` | `POST /users` |
| `/getUserById` | `GET /users/{id}` |

- Are resource names plural? (`/books` not `/book`)
- Do names avoid leaking implementation details?
- Are names consistent with the business domain?

---

## Versioning

- Is there a versioning strategy?
- Is URL-based versioning used? (`/v2/books` — major version only, not `/v2.14.2/books`)
- Or is header-based versioning used? (`Accept-Version: 2`)
- Is there a plan for removing old versions? (usage statistics, inactivity monitoring, Sunset headers)
- Does versioning follow Semantic Versioning for the API version number?

---

## CRUD and HTTP Methods

- Are HTTP methods used correctly per RFC 9110?

| Operation | Method | Example |
|-----------|--------|---------|
| Create | POST | `POST /books` |
| Read (list) | GET | `GET /books` |
| Read (single) | GET | `GET /books/123` |
| Update (full) | PUT | `PUT /books/123` |
| Update (partial) | PATCH | `PATCH /books/123` |
| Delete | DELETE | `DELETE /books/123` |

- Is the API serving resources, not acting as RPC?

---

## HATEOAS and Self-Discovery

Full HATEOAS is rarely needed. Adopt selectively.

**Check for:**
- Do resources include `self` links?
- Do collections include pagination links? (`next`, `prev`, `last`)
- Are related resource links included where useful?
- Are `rel` values documented using IANA link relations where applicable?

**When full HATEOAS makes sense:** public APIs with long-lived clients, workflow APIs modeling state machines, discoverable developer portals.

**When to skip it:** internal APIs with controlled clients, simple CRUD without complex state transitions.

---

## Idempotency

GET, PUT, and DELETE are naturally idempotent. POST is not.

**Check for:**
- Do non-idempotent operations (POST) support idempotency keys?
- Is the idempotency key format defined? (UUID recommended)
- Is there a TTL for idempotency keys? (24-48 hours typical)
- Does the server check for duplicate keys and return cached responses?

Example header: `Idempotency-Key: 550e8400-e29b-41d4-a716-446655440000`

---

## Conditional Requests

ETags prevent lost updates and optimize caching.

**Check for:**
- Are ETags planned for GET responses? (caching with `If-None-Match` → `304 Not Modified`)
- Is optimistic locking planned for updates? (`If-Match` → `412 Precondition Failed`)
- Are ETags used to prevent concurrent update conflicts?

---

## CORS

Essential for browser-based API consumers.

**Check for:**
- Is CORS needed? (Yes if browser-based consumers will call the API cross-origin)
- Is `Access-Control-Allow-Origin: *` avoided when credentials are used?
- Is the `Origin` header validated against an allowlist?

---

## Health Checks

**Check for:**
- Is a liveness endpoint planned? (`GET /health/live` — is the service running?)
- Is a readiness endpoint planned? (`GET /health/ready` — is the service ready for traffic?)
- Does the readiness check verify database and critical dependency connections?
- Do health checks return `200` for healthy, `503` for unhealthy?
- Are liveness checks kept simple (no dependency checks)?

---

## Request Tracing

**Check for:**
- Is a correlation ID strategy planned?
  - `X-Request-ID` — unique to each request, generated by API if not provided
  - `X-Correlation-ID` — passed through the entire call chain across services
- Are these IDs logged in every service?
- Is W3C Trace Context or OpenTelemetry considered?

---

## Parameters

- Are path parameters used for resource identification only? (`/users/123`)
- Are query parameters used for filtering, sorting, pagination? (`?status=active&sort=-createdAt`)
- Is sensitive data sent in the request body, never in URLs? (URLs visible in logs, browser history)
- Are redundant parent IDs avoided in nested paths?

### ID Exposure in URLs — Public vs Private APIs

IDs in path and query parameters are visible in access logs, CDN logs, browser history, referrer headers, and network monitoring tools. For public-facing APIs, this creates enumeration and information leakage risks.

**Check for:**
- For public APIs: are IDs in URLs opaque and non-sequential? (UUIDs, random strings, or type-prefixed random IDs like `user_abc123`)
- For public APIs: can an attacker enumerate resources by incrementing IDs? (`/users/1`, `/users/2`, `/users/3`...)
- For public APIs: do IDs in URLs reveal business intelligence? (sequential IDs expose record count, creation order, growth rate)
- Is authorization enforced on every resource access, regardless of ID format? (opaque IDs are defense-in-depth, not a substitute for authorization — see BOLA in security checklist)
- For private/internal APIs: sequential or predictable IDs are acceptable when behind authentication and network controls, but prefer opaque IDs if there's any chance the API will become public-facing later

**Encoded IDs with expiry** — some teams encode private IDs with a time-limited signature (e.g., encrypted tokens in URLs). While this prevents direct enumeration, it still raises concerns with most compliance teams: encoded IDs still appear in logs, referrer headers, and CDN caches, and expired tokens create confusing 404-vs-403 semantics. This approach should generally be avoided for public APIs; prefer opaque random IDs with server-side authorization.

> Sequential IDs in public API URLs are a security smell. They enable enumeration attacks, reveal business metrics, and make BOLA exploitation trivial. Use opaque IDs for public APIs and treat path parameters as potentially logged everywhere.

---

## Attribute Convention

- Is a single naming convention chosen and applied consistently?
  - camelCase (JavaScript/Java convention — most common for JSON APIs)
  - snake_case (Python/Ruby convention)
- Is the convention documented and enforced?
- Are conventions not mixed within the same API?

---

## Common Gaps to Flag

- No OpenAPI spec (designing by coding)
- Endpoints named after database operations
- Mixed singular and plural resource names
- No versioning strategy
- No idempotency keys for POST operations
- No CORS configuration for browser consumers
- Missing health check endpoints
- No correlation ID strategy
- No ETag support for concurrent updates
- Inconsistent attribute naming across endpoints
- Sequential/predictable IDs in public API URLs (enumeration risk)

## References

See `sources.md` for all source references and further reading.
