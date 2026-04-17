# API Design Review: Payments API

**Review date:** 2026-03-22
**Input:** OpenAPI 3.0.3 specification (YAML) with two endpoints: `POST /v1/payments` and `GET /v1/payments/{id}`
**Context:** A payments API for creating and retrieving payment records. Consumer type, scale, deployment, and auth requirements are not specified in the spec. Given this is a payments domain, security and correctness are treated as high priority throughout this review.

---

## Summary of Findings

| # | Domain | Finding | Severity |
|---|--------|---------|----------|
| 1 | Security | No authentication or authorization model defined | Critical |
| 2 | Payloads | Payment ID uses integer type -- enables enumeration and has precision risks | Critical |
| 3 | Security | No rate limiting strategy for a financial API | Critical |
| 4 | Design | No idempotency key support on POST /v1/payments | Critical |
| 5 | Payloads | No error response format defined | Warning |
| 6 | Payloads | No response body schema defined for either endpoint | Warning |
| 7 | Payloads | Amount represented as integer with no format or currency precision rules | Warning |
| 8 | Design | No pagination or list endpoint for payments | Warning |
| 9 | Design | No health check endpoints | Warning |
| 10 | Design | No request tracing / correlation ID strategy | Warning |
| 11 | Resilience | No caching strategy or conditional request support | Suggestion |
| 12 | Extensibility | No metadata extension point on payment objects | Suggestion |
| 13 | Design | Versioning present in URL path | Good |
| 14 | Design | Resource naming follows REST conventions (plural nouns) | Good |
| 15 | Design | HTTP methods used correctly (POST for create, GET for read) | Good |

---

## Detailed Findings

### Design Principles

**Finding 13 (Good) -- URL-based versioning with major version prefix**

- **What:** The API uses `/v1/` prefix, which is a clean versioning strategy.
- **Why it matters:** URL-based versioning is the most widely adopted approach, easily understood by consumers, and works well with API gateways and routing rules.
- **Recommendation:** Plan ahead for deprecation by documenting a Sunset header strategy (RFC 8594) for when v2 is eventually needed. See RFC 8594 in sources.md.

**Finding 14 (Good) -- Plural noun resource naming**

- **What:** The resource is named `/payments` (plural), not `/payment`.
- **Why it matters:** Consistent plural naming avoids ambiguity between single-resource and collection endpoints. This aligns with standard REST conventions.

**Finding 15 (Good) -- Correct HTTP method usage**

- **What:** POST is used for creation, GET for retrieval.
- **Why it matters:** Correct method semantics per RFC 9110 ensure standard behavior for caching, retries, and middleware.

**Finding 4 (Critical) -- No idempotency key support for POST /v1/payments**

- **What:** The `POST /v1/payments` endpoint has no idempotency mechanism. There is no `Idempotency-Key` header or equivalent defined in the spec.
- **Why it matters:** In a payments API, network retries, client timeouts, or user double-clicks can cause duplicate payment creation. This leads to customers being charged multiple times. For a financial API, this is not optional -- it is a hard requirement.
- **Recommendation:** Add an `Idempotency-Key` request header (UUID format). Define a TTL for idempotency records (24-48 hours is typical). Return the cached response for duplicate keys. See the Stripe Idempotent Requests pattern at stripe.com/docs/api/idempotent_requests referenced in sources.md.

**Finding 8 (Warning) -- No list endpoint or pagination strategy**

- **What:** There is no `GET /v1/payments` collection endpoint. The only retrieval is by single ID.
- **Why it matters:** Consumers will almost certainly need to list payments (by date range, status, customer, etc.). Without a list endpoint, consumers are forced to store payment IDs client-side. If a list endpoint is planned, it will need pagination from day one -- adding it later is a breaking change.
- **Recommendation:** Add `GET /v1/payments` with query parameters for filtering (e.g., `?status=`, `?created_after=`, `?customer_id=`). Define cursor-based pagination for a financial dataset (offset pagination degrades with large datasets). See the Slack pagination evolution at slack.engineering referenced in sources.md for a cautionary tale on pagination choices.

**Finding 9 (Warning) -- No health check endpoints**

- **What:** No liveness or readiness endpoints are defined.
- **Why it matters:** Without health checks, orchestrators (Kubernetes, ECS, etc.) cannot determine if the service is running or ready for traffic. This leads to routing traffic to unhealthy instances and makes deployment rollouts unsafe.
- **Recommendation:** Add `GET /health/live` (liveness -- is the process running?) and `GET /health/ready` (readiness -- are database and downstream dependencies available?). Return 200 for healthy, 503 for unhealthy.

**Finding 10 (Warning) -- No request tracing or correlation ID strategy**

- **What:** The spec does not define any tracing headers (`X-Request-ID`, `X-Correlation-ID`, or W3C Trace Context headers).
- **Why it matters:** In a payments system, traceability is essential for debugging failed transactions, reconciling with payment processors, and meeting audit requirements. Without correlation IDs, cross-service debugging becomes guesswork.
- **Recommendation:** Define `X-Request-ID` (generated per request if not provided) and `X-Correlation-ID` (propagated across the call chain). Consider adopting W3C Trace Context (`traceparent`, `tracestate`) for interoperability with OpenTelemetry. See W3C Trace Context spec in sources.md.

---

### Payloads & Errors

**Finding 2 (Critical) -- Payment ID uses integer type, enabling enumeration**

- **What:** The `{id}` path parameter is defined as `type: integer`. This implies sequential, predictable IDs.
- **Why it matters:** Sequential integer IDs in a payments API are a serious security and business intelligence risk. An attacker can enumerate all payments (`/v1/payments/1`, `/v1/payments/2`, ...), discover total payment volume, and attempt Broken Object Level Authorization (BOLA) attacks -- the #1 risk on the OWASP API Security Top 10. Additionally, large integer IDs can cause precision loss in JavaScript clients (numbers above 2^53 lose precision).
- **Recommendation:** Use UUIDs or type-prefixed random IDs (e.g., `pay_abc123xyz`) as strings. Define the path parameter as `type: string` with a pattern constraint. This prevents enumeration, avoids JavaScript precision issues, and makes IDs self-describing in logs. See OWASP API Security Top 10 (API1: BOLA) in sources.md.

**Finding 5 (Warning) -- No error response format defined**

- **What:** Neither endpoint defines error responses (400, 401, 403, 404, 409, 422, 429, 500). The spec only defines the happy path (201 and 200).
- **Why it matters:** Without a standardized error format, each endpoint will invent its own error shape, leading to inconsistent consumer experience and increased integration cost. For a payments API, clear error messages are essential -- consumers need to know if a payment failed due to insufficient funds, invalid currency, or a server error, and they need to handle each programmatically.
- **Recommendation:** Adopt RFC 9457 Problem Details as the error format. Return `Content-Type: application/problem+json` for all errors. Define error responses for at least: 400 (validation), 401 (unauthenticated), 403 (forbidden), 404 (not found), 409 (duplicate/conflict), 429 (rate limited), 500 (internal error). See RFC 9457 in sources.md.

**Finding 6 (Warning) -- No response body schema defined**

- **What:** The 201 and 200 responses have descriptions but no response body schemas. Consumers do not know what fields are returned when a payment is created or retrieved.
- **Why it matters:** Without response schemas, consumers cannot generate typed clients, cannot write contract tests, and must discover the response shape empirically. This undermines the contract-first approach that having an OpenAPI spec is supposed to provide.
- **Recommendation:** Define response schemas for both endpoints. At minimum, the payment object should include: `id` (string), `amount` (integer), `currency` (string), `status` (string enum), `created_at` (string, date-time format). Consider including `self` links for discoverability. Use a consistent response envelope (`{ "data": { ... } }`) or document that raw objects are returned.

**Finding 7 (Warning) -- Amount as integer with no precision semantics**

- **What:** The `amount` field is `type: integer` with no further constraints -- no minimum, no maximum, no description of what unit it represents.
- **Why it matters:** Currency amounts are notoriously error-prone. Does `100` mean 100 dollars or 100 cents? Without explicit documentation, consumers will guess, and some will guess wrong. Negative amounts, zero amounts, and extremely large amounts also need to be addressed. Using floating-point numbers for money is a well-known anti-pattern, so integer (minor units) is the right type -- but it must be documented.
- **Recommendation:** Document that `amount` is in the smallest currency unit (e.g., cents for USD, so $10.00 = 1000). Add `minimum: 1` to prevent zero or negative amounts (unless refunds are supported). Add `description: "Amount in the smallest currency unit (e.g., cents for USD)"`. Consider adding `currency` validation against ISO 4217 codes with a pattern or enum. The Stripe API uses this minor-unit convention and documents it explicitly.

---

### Security

**Finding 1 (Critical) -- No authentication or authorization model defined**

- **What:** The spec defines no security schemes. There is no `securityDefinitions`, no `security` field at the operation or global level, and no mention of tokens, API keys, or OAuth.
- **Why it matters:** This is a payments API -- it handles financial transactions. Without authentication, anyone can create payments. Without authorization, any authenticated user can view any other user's payments. For a financial API, this is the single highest priority gap.
- **Recommendation:** Define a security scheme in the OpenAPI spec (OAuth 2.0 with PKCE for consumer-facing, or Bearer JWT for service-to-service). Apply it globally. Design authorization to prevent BOLA -- a user must only be able to access their own payments. For high-value operations (large payments, payment method changes), consider step-up authentication (see RFC 9470 in sources.md). See OWASP API Security Top 10 and OWASP REST Security Cheat Sheet in sources.md.

**Finding 3 (Critical) -- No rate limiting strategy**

- **What:** No rate limiting is defined or mentioned.
- **Why it matters:** Without rate limiting, a payments API is vulnerable to abuse: automated fraud (testing stolen card numbers at high speed), denial-of-service attacks, and resource exhaustion. Rate limiting is also a business requirement for managing payment processor costs and API quotas.
- **Recommendation:** Define rate limits per endpoint, with stricter limits on `POST /v1/payments` (creation) than `GET /v1/payments/{id}` (retrieval). Use standard rate limit headers (`RateLimit`, `RateLimit-Policy`, or the widely-used `RateLimit-Limit`, `RateLimit-Remaining`, `RateLimit-Reset`). Return `429 Too Many Requests` with `Retry-After` header when limits are exceeded. See IETF Rate Limit Headers draft in sources.md.

---

### Resilience

**Finding 11 (Suggestion) -- No caching or conditional request support**

- **What:** No `ETag`, `Last-Modified`, or `Cache-Control` headers are planned for `GET /v1/payments/{id}`.
- **Why it matters:** Payment records are mostly immutable once created (the amount and currency don't change). ETags would enable efficient polling and conditional requests, reducing server load and improving client performance. For high-traffic systems, this is important at scale.
- **Recommendation:** Add `ETag` headers to GET responses. Support `If-None-Match` for conditional requests (return 304 Not Modified when unchanged). Set `Cache-Control: private, no-cache` to allow conditional caching while ensuring authorization is always checked. See RFC 7232 (Conditional Requests) in sources.md.

---

### Extensibility

**Finding 12 (Suggestion) -- No metadata extension point**

- **What:** The payment creation request only accepts `amount` and `currency`. There is no `metadata` or extensible field.
- **Why it matters:** Consumers frequently need to attach their own context to payments (internal order IDs, reference numbers, customer notes, accounting codes). Without a metadata field, consumers either overload existing fields or request new fields constantly, requiring API changes for each use case.
- **Recommendation:** Add an optional `metadata` field (object with string keys and string values, max 50 keys). Document constraints and that metadata is inert storage with no functional impact on payment processing. See the Stripe metadata pattern at docs.stripe.com/metadata referenced in sources.md.

---

## What's Missing?

The following areas are not addressed in the current spec:

- **Authentication and authorization model** -- no security scheme defined
- **Error response format** -- no error responses documented, no RFC 9457 adoption
- **Response body schemas** -- consumers cannot see what data is returned
- **Idempotency strategy** -- no idempotency key for payment creation
- **Pagination approach** -- no collection endpoint, no pagination defined
- **Rate limiting strategy** -- no rate limits defined
- **Health check endpoints** -- no liveness or readiness checks
- **Correlation ID / tracing strategy** -- no request tracing headers
- **Caching strategy** -- no ETag or conditional request support
- **Input validation constraints** -- amount has no min/max, currency has no format validation
- **CORS configuration** -- not specified (relevant if browser clients will call this API)
- **Webhook / async notification support** -- no mechanism for notifying consumers of payment status changes (common requirement for payment APIs where processing is asynchronous)

---

## Readiness Assessment

**Needs more design work** -- This spec has four critical findings that must be resolved before implementation begins.

**Top priorities before building:**

1. **Define authentication and authorization** -- Decide on OAuth 2.0 / Bearer JWT, apply security schemes globally, and design BOLA prevention so users cannot access each other's payments.

2. **Add idempotency key support to POST /v1/payments** -- For a payments API, duplicate payment prevention is non-negotiable. Define the `Idempotency-Key` header, TTL, and duplicate-handling behavior.

3. **Replace integer IDs with opaque string identifiers** -- Switch from sequential integers to UUIDs or type-prefixed random IDs to prevent enumeration attacks and JavaScript precision issues.

4. **Define error response format and response body schemas** -- Adopt RFC 9457 Problem Details for errors. Define the payment object schema in responses. Without these, the spec does not fulfill its purpose as a contract.

Once these critical items are addressed, the warning-level findings (pagination, health checks, rate limiting, tracing, amount semantics) should be resolved before going to production.
