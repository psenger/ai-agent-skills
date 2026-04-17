# API Design Review: Mobile Fitness App API

**Review date:** 2026-03-22
**Input:** Verbal description of a planned API for a mobile fitness app with workout tracking, social follows, and a social feed.
**Context:** A mobile-facing REST API for a fitness application serving 10k DAU growing to 100k. Core domains are workout tracking, social graph (follows), and an activity feed. Primary consumer is a mobile app.

---

## Summary of Findings

| # | Domain | Finding | Severity |
|---|--------|---------|----------|
| 1 | Design | No versioning strategy defined | Critical |
| 2 | Security | No authentication/authorization model specified | Critical |
| 3 | Security | BOLA risk is high for a social app with user-to-user data access | Critical |
| 4 | Payloads | No error response format defined | Warning |
| 5 | Payloads | No pagination strategy for feed and list endpoints | Warning |
| 6 | Design | No idempotency strategy for workout creation | Warning |
| 7 | Resilience | No caching strategy for feed and social data | Warning |
| 8 | Communication | Social feed may benefit from a hybrid REST + SSE pattern | Warning |
| 9 | Design | No health check endpoints mentioned | Warning |
| 10 | Design | No correlation ID / distributed tracing strategy | Warning |
| 11 | Security | No rate limiting strategy defined | Warning |
| 12 | Security | Enumeration risk on user search and follow endpoints | Warning |
| 13 | Payloads | No identifier strategy defined (sequential vs opaque IDs) | Warning |
| 14 | Design | Social domain (follows, feed) is a strong candidate for domain-driven resource modeling | Suggestion |
| 15 | Resilience | Define SLIs/SLOs early given growth trajectory | Suggestion |
| 16 | Extensibility | Consider metadata fields on workout resources for future extensibility | Suggestion |
| 17 | Human Aspect | Mobile team should co-design the API contract before implementation | Suggestion |
| 18 | Design | Resource modeling for workouts as aggregate roots is a natural fit | Good |
| 19 | Design | The 10k-to-100k growth trajectory is well-scoped for planning proportional infrastructure | Good |

---

## Detailed Findings

### Design Principles

**Finding 1 -- No versioning strategy defined**

- **What:** No versioning approach has been specified for the API.
- **Why it matters:** Without versioning, any breaking change to workout payloads, feed structure, or social endpoints will break the mobile app. Mobile apps are particularly vulnerable because users do not update immediately -- you will have multiple app versions in the wild calling your API simultaneously. Adding versioning retroactively is painful and error-prone.
- **Recommendation:** Use URL-based versioning with major version only: `/v1/workouts`, `/v1/users/{id}/feed`. Plan Sunset headers (RFC 8594) for future deprecation. Since mobile clients update slowly, expect to support at least two major versions concurrently. See Stripe's API versioning approach in `sources.md` for a proven model.

**Finding 6 -- No idempotency strategy for workout creation**

- **What:** Workout logging is a core write operation, but no idempotency approach has been discussed.
- **Why it matters:** Mobile networks are unreliable. Users will tap "save workout" on spotty connections, triggering retries. Without idempotency keys, the same workout could be recorded multiple times. At 100k DAU with daily workout logging, duplicate records will become a significant data quality problem.
- **Recommendation:** Support an `Idempotency-Key` header on `POST /v1/workouts`. Use UUID v4 format. Store keys with a 24-48 hour TTL and return the cached response on duplicate submissions. See Stripe's idempotent requests documentation in `sources.md`.

**Finding 9 -- No health check endpoints mentioned**

- **What:** No liveness or readiness endpoints are planned.
- **Why it matters:** Without health checks, your orchestrator (Kubernetes, ECS, etc.) cannot distinguish between a running but broken service and a healthy one. This leads to routing traffic to unhealthy instances and delayed recovery during incidents.
- **Recommendation:** Plan `GET /health/live` (is the process running) and `GET /health/ready` (are database and downstream dependencies reachable). Liveness should be simple with no dependency checks. Readiness should verify the database connection and any critical service dependencies.

**Finding 10 -- No correlation ID / distributed tracing strategy**

- **What:** No request tracing approach has been discussed.
- **Why it matters:** When a user reports "my workout didn't save," you need to trace that request from the mobile app through your API and into downstream services. Without correlation IDs, debugging user-reported issues at 100k DAU becomes a needle-in-a-haystack exercise.
- **Recommendation:** Generate an `X-Request-ID` for every request (or accept one from the client). Propagate `X-Correlation-ID` across service boundaries. Consider W3C Trace Context with OpenTelemetry for structured distributed tracing. See W3C Trace Context specification in `sources.md`.

**Finding 14 -- Social domain is a strong candidate for domain-driven resource modeling**

- **What:** The three domains (workouts, social graph, feed) map naturally to REST resources, but the social interactions (follow, unfollow, like, comment) need careful modeling.
- **Why it matters:** Social actions are often modeled as RPC-style verbs (`/followUser`, `/likeWorkout`) instead of as resources. This leads to inconsistency and makes the API harder to extend.
- **Recommendation:** Model social relationships as resources: `POST /v1/users/{id}/followers` (follow a user), `DELETE /v1/users/{id}/followers/{followerId}` (unfollow). Model feed as a read-only collection: `GET /v1/users/{id}/feed`. Workout interactions could be: `POST /v1/workouts/{id}/likes`, `POST /v1/workouts/{id}/comments`. Use nouns, not verbs, and let HTTP methods convey the action.

**Finding 18 -- Resource modeling for workouts as aggregate roots is a natural fit**

- **What:** Workouts are a natural aggregate root containing exercises, sets, reps, and duration.
- **Why it matters:** This is a good domain-to-API alignment.
- **Recommendation:** Expose workouts as the root resource: `POST /v1/workouts`, `GET /v1/workouts/{id}`, `GET /v1/users/{id}/workouts`. Exercises and sets should be nested within the workout payload, not separate top-level resources (unless there is a clear need to access them independently).

---

### Security

**Finding 2 -- No authentication/authorization model specified**

- **What:** No auth approach has been defined for a user-facing mobile API.
- **Why it matters:** This is a user-facing app handling personal health data (workout history, body metrics) and social relationships. Auth is not optional -- it is foundational. Designing endpoints without an auth model leads to retrofitting authorization checks that inevitably miss edge cases, especially around social features where "who can see whose data" is complex.
- **Recommendation:** Use OAuth 2.1 with PKCE for the mobile client (mandatory per RFC 9700; the implicit grant is deprecated). Use OpenID Connect for authentication. Implement a short-lived access token (15-20 min) with refresh token rotation. Consider an established identity provider (Auth0, Keycloak, Zitadel) rather than building your own. For token storage on mobile, use the platform secure storage (iOS Keychain, Android Keystore). See RFC 9700 (OAuth 2.0 Security Best Current Practice) in `sources.md`.

**Finding 3 -- BOLA risk is high for a social app**

- **What:** A social fitness app inherently has complex object-level authorization: users have private workouts, followers-only workouts, and public workouts. Users can view profiles of people they follow. The feed aggregates data across authorization boundaries.
- **Why it matters:** Broken Object Level Authorization (BOLA) is the #1 OWASP API Security risk. In a social app, the attack surface is large: changing a user ID in `/v1/users/{id}/workouts` should not expose another user's private workouts. The feed endpoint must enforce visibility rules for every item. This is where most social app APIs fail.
- **Recommendation:** Enforce authorization on every resource access at the service layer, not just at the API gateway. Design visibility levels explicitly (private, followers-only, public) and document them in the API contract. Consider Relationship-Based Access Control (ReBAC) for the social graph -- it models "can user A see user B's workout" more naturally than RBAC. Test authorization boundaries explicitly with negative test cases. See OWASP API Security Top 10 (API1: BOLA) in `sources.md`.

**Finding 11 -- No rate limiting strategy defined**

- **What:** No rate limiting approach has been discussed.
- **Why it matters:** At 100k DAU, you will attract automated abuse: scraping the social feed, brute-forcing login, spamming follow requests. Without rate limiting, a single bad actor can degrade the experience for all users. Login and registration endpoints are especially vulnerable to credential stuffing.
- **Recommendation:** Apply tiered rate limiting: stricter on auth endpoints (5-10 attempts/min per IP), moderate on write operations (follow, post workout), lenient on reads (feed, profile views). Use `429 Too Many Requests` with `Retry-After` header. Rate limit by authenticated user ID (not just IP, which is unreliable behind mobile carrier NAT). See IETF Rate Limit Headers draft in `sources.md`.

**Finding 12 -- Enumeration risk on user search and follow endpoints**

- **What:** A social app necessarily has user search and user discovery features. These are enumeration attack surfaces by design.
- **Why it matters:** Attackers can use search and user listing endpoints to harvest your user directory. At 100k users, this is a meaningful dataset. User email addresses, usernames, and activity patterns are valuable for phishing and social engineering.
- **Recommendation:** Rate-limit search endpoints aggressively. Paginate results with a maximum page size. Do not expose email addresses in search results or public profiles. Return consistent responses on login/registration endpoints (never reveal whether an email is already registered). Consider requiring authentication for search endpoints. See the enumeration attack prevention checklist in `security-defense.md` and OWASP REST Security Cheat Sheet in `sources.md`.

---

### Payloads and Errors

**Finding 4 -- No error response format defined**

- **What:** No standard error format has been specified.
- **Why it matters:** Without a consistent error format, the mobile team will handle errors ad-hoc per endpoint, leading to inconsistent error UI and poor user experience. Workout validation errors ("weight must be positive"), authorization errors ("this workout is private"), and server errors will all look different to the client.
- **Recommendation:** Adopt RFC 9457 Problem Details as your error format. Return `Content-Type: application/problem+json`. Include `type`, `title`, `status`, and `detail` fields. For validation errors (invalid workout data), include structured `errors` array with `field`, `code`, and `message`. See RFC 9457 in `sources.md`.

**Finding 5 -- No pagination strategy for feed and list endpoints**

- **What:** The social feed and workout history are unbounded collections with no pagination approach defined.
- **Why it matters:** The social feed is an infinite-scroll use case on mobile. Offset-based pagination breaks when new items are added (users see duplicate or missing items as they scroll). Workout history grows over time. Without pagination, list endpoints will return increasingly large payloads, degrading mobile performance and consuming cellular data.
- **Recommendation:** Use cursor-based pagination for the feed (ideal for infinite scroll and real-time data insertion). Use offset-based pagination for workout history (simpler, data changes less frequently). Set a reasonable default page size (20-25 items) with a maximum (100). Include `next` and `prev` cursor links in response metadata. See Slack's pagination evolution in `sources.md` for a real-world example of cursor-based pagination at scale.

**Finding 13 -- No identifier strategy defined**

- **What:** No decision has been made about ID format for users, workouts, and other resources.
- **Why it matters:** Sequential integer IDs in a public-facing social API enable trivial enumeration: `/v1/users/1`, `/v1/users/2`, etc. They also reveal business intelligence (how many users you have, your growth rate). In a distributed system, sequential IDs create collision risks if you later split into multiple services.
- **Recommendation:** Use UUIDs or type-prefixed random IDs (`user_abc123`, `workout_xyz789`, `comment_qrs456`). Type-prefixed IDs are especially valuable in a social app where IDs appear in logs, URLs, and debugging -- you can immediately identify what entity an ID refers to. Represent IDs as strings in JSON to avoid JavaScript precision issues. See the Stripe ID pattern referenced in `payloads-errors.md`.

---

### Resilience

**Finding 7 -- No caching strategy for feed and social data**

- **What:** No caching approach has been discussed for the feed, user profiles, or workout data.
- **Why it matters:** The social feed is a read-heavy endpoint (every user checks it multiple times daily). At 100k DAU, uncached feed queries will hammer your database. User profiles and public workout data are also highly cacheable. Without a caching strategy, you will hit scaling problems well before 100k DAU.
- **Recommendation:** Layer your caching: use HTTP `Cache-Control` headers for client-side caching of user profiles and workout details (short TTL, e.g., 60 seconds). Use a server-side cache (Redis) for computed feed data. Apply `ETag` headers on workout and profile endpoints for conditional requests (`If-None-Match` returning `304 Not Modified`). Never cache authenticated-user-specific data without `Vary: Authorization`. Plan cache invalidation for when users update their profile or post a new workout. See RFC 7234 (HTTP Caching) and RFC 7232 (Conditional Requests) in `sources.md`.

**Finding 15 -- Define SLIs/SLOs early given growth trajectory**

- **What:** No service level indicators or objectives have been discussed.
- **Why it matters:** Going from 10k to 100k DAU (10x growth) means you need to know what "healthy" looks like before you start scaling. Without defined SLOs, you cannot make informed decisions about caching, infrastructure, or when to invest in optimization vs. new features.
- **Recommendation:** Define at minimum: availability SLO (e.g., 99.9%), latency SLOs (p99 < 500ms for feed, p99 < 200ms for workout creation), and error rate SLO (< 0.1% 5xx). Define an error budget and use it to balance feature velocity against reliability work. See Google SRE Book chapters on Monitoring and Service Level Objectives in `sources.md`.

---

### Communication Patterns

**Finding 8 -- Social feed may benefit from a hybrid REST + SSE pattern**

- **What:** The social feed is described as a feature users will check frequently for updates from people they follow. A pure REST approach means the mobile client must poll for new feed items.
- **Why it matters:** Polling at high frequency (every few seconds) wastes battery and cellular data on mobile. Polling at low frequency (every few minutes) means users see stale feeds. This is a classic case where server-push improves both efficiency and user experience.
- **Recommendation:** Start with REST for the feed (`GET /v1/users/{id}/feed` with cursor pagination). Add a lightweight notification mechanism for "new items available" so the client knows when to refresh. SSE (`GET /v1/users/{id}/feed/stream`) is a natural fit for server-to-client push of new feed items, with automatic reconnection built into the spec. However, SSE has limited native mobile support (requires a library). Evaluate whether push notifications (APNs/FCM) for "new activity" combined with REST polling on app open is sufficient for your latency requirements -- this is simpler to implement and operates well on mobile. Only invest in SSE or WebSockets if near-real-time feed updates are a core product requirement. See the communication patterns comparison matrix in `api-communication-patterns.md`.

---

### Extensibility

**Finding 16 -- Consider metadata fields on workout resources**

- **What:** Workout data structures are not yet defined, but fitness apps tend to evolve rapidly (new exercise types, integration with wearables, custom metrics).
- **Why it matters:** If the workout schema is rigid, every new metric or integration requires a schema change and potentially an API version bump. Fitness tracking data is inherently variable -- different workout types have different data shapes.
- **Recommendation:** Include a `metadata` key-value field on workout resources for consumer-owned extension data (e.g., heart rate data from a wearable, GPS coordinates, custom tags). Define constraints: max 50 keys, string values only, max 500 chars per value. Keep core fields (duration, type, exercises, sets, reps) in the typed schema and use metadata for the long tail. When metadata patterns become universal, promote them to first-class fields in the next API version. See Stripe's metadata pattern in `sources.md`.

---

### Human Aspect

**Finding 17 -- Mobile team should co-design the API contract**

- **What:** The primary consumer is a mobile app, but it is unclear whether the mobile team is involved in the API design.
- **Why it matters:** APIs designed without consumer input end up shaped by backend convenience rather than mobile needs. Mobile clients have specific constraints: limited bandwidth, high latency, battery sensitivity, offline scenarios. The mobile team knows which data they need per screen, which round trips are painful, and what error handling looks like in a mobile UX.
- **Recommendation:** Adopt contract-first development. Write the OpenAPI spec collaboratively with the mobile team before implementation. Generate client SDKs from the spec. Use Pact or similar contract testing to ensure the implementation matches the agreed contract. See Pact Contract Testing in `sources.md`.

---

## What's Missing?

The following areas have not been addressed and should be considered before implementation:

- **Authentication/authorization model** -- No auth strategy defined for a user-facing API handling personal health data
- **Error response format** -- No standard error format (recommend RFC 9457 Problem Details)
- **Versioning strategy** -- No approach for managing breaking changes across slow-updating mobile clients
- **Pagination approach** -- No strategy for feed and workout history list endpoints
- **Rate limiting strategy** -- No plan for protecting against abuse at scale
- **Idempotency strategy for writes** -- No plan for handling mobile network retries on workout creation
- **Caching strategy** -- No plan for a read-heavy social feed
- **Health check endpoints** -- No liveness/readiness probes
- **Correlation ID / tracing strategy** -- No plan for debugging user-reported issues
- **Identifier format** -- No decision on sequential vs opaque IDs
- **Input validation strategy** -- No plan for validating workout data, user input, search queries
- **CORS configuration** -- Needed if there will ever be a web client alongside mobile
- **Offline support strategy** -- Mobile fitness apps commonly need offline workout logging with sync
- **Data privacy considerations** -- Health/fitness data may be subject to regulations (HIPAA in US contexts, GDPR in EU) depending on what is tracked

---

## Readiness Assessment

**Needs more design work.**

There are three critical findings that must be resolved before building:

1. **Authentication and authorization model** -- A user-facing social app handling personal health data cannot proceed without a defined auth strategy. The social graph (follows, visibility levels) makes authorization particularly complex.

2. **BOLA prevention strategy** -- The social nature of the app creates numerous object-level authorization boundaries. Without an explicit authorization model for "who can see whose workouts and feed items," you will ship vulnerabilities.

3. **API versioning strategy** -- Mobile clients update slowly. Without versioning from day one, you cannot evolve the API without breaking users on older app versions.

After resolving these critical items, prioritize the warning-level findings in this order:

1. Error format and pagination (directly impacts mobile team's ability to build)
2. Rate limiting and identifier strategy (security foundations)
3. Caching and idempotency (scaling foundations for 10x growth)
