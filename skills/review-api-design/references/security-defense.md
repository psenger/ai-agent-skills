# Security: Attack Prevention & Hardening — Design Review Checklist

Source: [Best Practices for REST API](https://github.com/psenger/Best-Practices-For-Rest-API) by Philip A Senger (CC BY 4.0)

---

This checklist covers attack prevention, API hardening, and security monitoring.

## Table of Contents

1. [Enumeration Attack Prevention](#enumeration-attack-prevention)
2. [Information Disclosure Prevention](#information-disclosure-prevention)
3. [Input Validation](#input-validation)
4. [CORS](#cors)
5. [CSRF](#cross-site-request-forgery-csrf)
6. [Security Headers](#security-headers)
7. [Security Logging and Monitoring](#security-logging-and-monitoring)
8. [OWASP API Security Top 10](#owasp-api-security-top-10)

---

## Enumeration Attack Prevention

Enumeration attacks probe an API systematically to discover valid resources, usernames, emails, or IDs. They are a top attack vector because they require no authentication and exploit normal API behavior — the API itself tells the attacker what exists.

### Attack Vectors

| Endpoint Type | Attack | How It Works |
|---------------|--------|--------------|
| **User registration** | Email/username enumeration | `POST /register` with `alice@example.com` → "email already taken" reveals the account exists |
| **Login** | Username enumeration | `POST /login` → "user not found" vs "wrong password" reveals which usernames exist |
| **Password reset** | Email enumeration | `POST /forgot-password` → "reset email sent" vs "email not found" reveals registered emails |
| **Resource IDs** | Object enumeration | `GET /users/1`, `GET /users/2`, `GET /users/3` → sequential IDs allow full catalog scraping |
| **Search/autocomplete** | Data harvesting | `GET /users?search=a`, `?search=b` ... extracts the full user directory one letter at a time |
| **Verification endpoints** | Existence probing | `GET /check-email?email=alice@example.com` → explicit existence check designed for UX becomes an attack surface |

### Design-Phase Defenses

**Check for:**

#### Consistent Responses (eliminate information leakage)
- Do authentication endpoints (login, register, password reset) return **identical responses** regardless of whether the account exists? The same HTTP status code, the same response body, the same response time.
  - Registration: always return `200 OK` with "If this email is available, you'll receive a confirmation" — never "email already taken"
  - Login: always return `401 Unauthorized` with "Invalid credentials" — never "user not found" vs "wrong password"
  - Password reset: always return `200 OK` with "If this email is registered, you'll receive a reset link" — never "email not found"
- Are response times consistent? (timing differences between "user exists" and "user not found" paths leak information — use constant-time comparisons and deliberate delays)

#### Opaque Identifiers (eliminate sequential enumeration)
- Are resource IDs non-sequential? (UUIDs, random strings, type-prefixed random IDs)
- Are IDs unpredictable enough that brute-force guessing is infeasible? (UUID v4 has 2^122 possibilities)
- Are "check if exists" endpoints avoided? (e.g., `GET /check-username/{name}` — these are enumeration endpoints by design; if needed, protect with aggressive rate limiting and CAPTCHA)

#### Rate Limiting (slow down automated probing)
- Are authentication-related endpoints rate-limited more aggressively than others?
  - Login: 5-10 attempts per IP per minute
  - Registration: 3-5 per IP per hour
  - Password reset: 3 per email per hour, 10 per IP per hour
- Is rate limiting applied per IP AND per account/email? (per-IP alone fails when attackers use distributed IPs; per-account alone fails for username enumeration across accounts)
- Are search/autocomplete endpoints rate-limited and paginated? (prevent full-catalog extraction)

#### CAPTCHA and Bot Detection
- Are CAPTCHA or proof-of-work challenges applied after N failed attempts?
- Is bot detection considered for high-value endpoints? (behavioral analysis, device fingerprinting)

#### Account Lockout and Alerting
- Is there an account lockout or progressive delay policy after repeated failed attempts?
- Does the lockout policy avoid enabling denial-of-service? (lock the attacker's IP, not the victim's account — or use progressive delays instead of hard lockout)
- Are users notified of unusual login attempts? ("Someone tried to log in to your account from a new device")

#### Monitoring and Detection
- Are sequential ID access patterns detectable? (e.g., `GET /users/100`, `/users/101`, `/users/102` from the same IP)
- Are high-volume 404 patterns flagged? (probing for valid resources)
- Are authentication failure spikes monitored? (credential stuffing detection)
- Are search query patterns analyzed? (alphabetical crawling detection)

---

## Information Disclosure Prevention

Every piece of information leaked through API responses, headers, or error messages gives attackers a map of your internal architecture. The goal is to reveal nothing about the system's internals beyond what consumers need to use the API.

### Error Responses

- Are stack traces suppressed in production? (stack traces reveal framework, language, file paths, line numbers, and dependency versions)
- Are raw database error messages never exposed? (SQL errors reveal table names, column names, query structure, and database engine)
- Are internal service names and URLs hidden? (error messages like "upstream service payment-service-v2.internal:8080 timed out" reveal architecture)
- Do error messages use generic language for internal failures? ("An internal error occurred" not "NullPointerException in PaymentProcessor.java:142")
- Are error codes machine-readable but non-revealing? (`ERR_INTERNAL_001` not `POSTGRES_UNIQUE_VIOLATION`)
- Is debug mode / verbose error output disabled in production?

### Response Headers

- Is the `Server` header removed or genericized? (don't reveal `Server: Apache/2.4.52 (Ubuntu)` or `Server: nginx/1.24.0`)
- Is `X-Powered-By` removed? (don't reveal `X-Powered-By: Express` or `X-Powered-By: PHP/8.2`)
- Are framework-specific headers stripped? (`X-AspNet-Version`, `X-Runtime`, `X-Request-Id` if it reveals internal routing)
- Are technology-specific cookie names avoided? (`JSESSIONID` reveals Java, `PHPSESSID` reveals PHP, `connect.sid` reveals Express)
- Do CORS headers avoid over-exposing internal endpoints?

### API Structure

- Do endpoint paths avoid revealing internal architecture? (`/api/v1/orders` not `/services/order-service/api/v1/orders`)
- Are internal-only endpoints not exposed on the public API? (admin endpoints, debug endpoints, health checks with dependency details)
- Is API documentation scoped appropriately? (public consumers see only public endpoints — internal endpoints have separate docs behind auth)
- Are OpenAPI specs for public APIs stripped of internal annotations, comments, and example values that reveal implementation?

### Responses and Payloads

- Do responses avoid leaking database schema? (field names should match the domain model, not `tbl_users.usr_email_addr`)
- Do responses avoid revealing infrastructure? (no internal IPs, hostnames, container IDs, or cluster names in responses)
- Do 404 responses not distinguish between "resource doesn't exist" and "you don't have permission"? (for sensitive resources, return `404` for unauthorized access to prevent confirming resource existence)
- Are different error response shapes avoided for different internal failure modes? (a timeout vs a crash vs a validation error in a downstream service should all look the same to the consumer if they're internal failures)

---

## Input Validation

- Is request body schema validation enforced? (JSON Schema, OpenAPI validation)
- Are injection attacks prevented? (SQL injection, NoSQL injection, command injection)
- Are request size limits defined? (max body size, max header size)
- Is `Content-Type` validated and enforced? (reject unexpected content types)
- Are path/query parameters validated against expected types and ranges?

---

## CORS

Cross-Origin Resource Sharing misconfiguration is one of the most exploited API weaknesses.

- Is `Access-Control-Allow-Origin: *` explicitly avoided for authenticated endpoints?
- Is the allowed origins list explicit? (no regex or substring matching that could be bypassed)
- Is `Access-Control-Allow-Credentials` restricted to trusted origins only?
- Are only necessary methods and headers exposed?
- Is preflight cache (`Access-Control-Max-Age`) set appropriately?

---

## Cross-Site Request Forgery (CSRF)

CSRF attacks trick an authenticated user's browser into making unintended requests to your API. If the API uses cookie-based authentication (including HttpOnly cookies), the browser automatically attaches cookies to every request — even requests triggered by a malicious site the user is visiting. The attacker doesn't need to steal the cookie; the browser sends it willingly.

### When CSRF Matters

- Does the API use cookie-based authentication? (session cookies, HttpOnly JWT cookies) — **CSRF protection is required**
- Does the API use only bearer tokens in the `Authorization` header? (not cookies) — CSRF is not a concern because browsers don't auto-attach `Authorization` headers on cross-origin requests
- Does the API use the BFF pattern with session cookies? — **CSRF protection is required on the BFF**

> **Key insight:** CSRF is a cookie problem. If auth is cookie-based, you need CSRF protection. If auth is header-based (Bearer tokens), browsers don't auto-attach it on cross-origin requests, so CSRF doesn't apply.

### Prevention Techniques (Defense in Depth)

Use multiple layers — no single technique is sufficient alone.

#### 1. SameSite Cookie Attribute (primary defense)
- Are session cookies set with `SameSite=Strict` or `SameSite=Lax`?
  - **`Strict`** — cookie is never sent on cross-site requests. Most secure but breaks legitimate cross-site navigation (clicking a link from email to your app won't include the cookie on the first request).
  - **`Lax`** — cookie is sent on top-level navigations (GET) but not on cross-site POST/PUT/DELETE. Good balance for most APIs.
  - **`None`** — cookie is always sent (requires `Secure` flag). Only use if the API must be called cross-origin with cookies (e.g., embedded widgets).
- Is `SameSite=Lax` the minimum? (`None` without strong CSRF token protection is dangerous)

#### 2. Anti-CSRF Tokens (synchronizer token pattern)
- For state-changing operations (POST, PUT, PATCH, DELETE): is a unique, unpredictable CSRF token required?
- Is the token generated server-side, tied to the user's session, and validated on every state-changing request?
- Is the token transmitted in a custom header (e.g., `X-CSRF-Token`) or hidden form field — never in a cookie? (cookies are the problem; the token must prove the request came from your own frontend, not a cross-site attacker)
- Are tokens single-use or per-session? (single-use is more secure, per-session is simpler)

#### 3. Fetch Metadata Headers (modern browser defense)
- Are `Sec-Fetch-Site`, `Sec-Fetch-Mode`, and `Sec-Fetch-Dest` headers checked on the server?
  - Reject requests where `Sec-Fetch-Site: cross-site` for state-changing operations
  - These headers are set by the browser and cannot be forged by JavaScript
- Is this used as defense-in-depth alongside SameSite cookies? (not all browsers support Fetch Metadata; not a standalone defense)

#### 4. Re-authentication for Sensitive Operations
- Do high-risk operations (transfer money, change email, delete account) require re-authentication regardless of CSRF protection? (password re-entry, MFA challenge, short-lived step-up tokens)

#### 5. Custom Request Headers
- For AJAX-only APIs: is a custom header required? (e.g., `X-Requested-With: XMLHttpRequest`). Cross-origin requests with custom headers trigger a CORS preflight, which the browser blocks if CORS doesn't allow the origin.

---

## Security Headers

- Is `Strict-Transport-Security` (HSTS) set? (e.g., `max-age=31536000; includeSubDomains`)
- Is `Content-Security-Policy` configured?
- Is `X-Content-Type-Options: nosniff` set?
- Is `X-Frame-Options` or CSP `frame-ancestors` set to prevent clickjacking?
- Are Fetch Metadata headers (`Sec-Fetch-Site`, `Sec-Fetch-Mode`) checked server-side? (see CSRF section above)

---

## Security Logging and Monitoring

- Are all authentication events logged? (login success/failure, token refresh, MFA challenges)
- Are authorization failures logged? (access denied events)
- Are security events forwarded to a SIEM or centralized logging system?
- Is anomaly detection in place for API abuse patterns? (credential stuffing, enumeration attacks)
- Is there an incident response plan for credential compromise?
- Are audit logs tamper-resistant?

---

## OWASP API Security Top 10

Review the design against the OWASP API Security Top 10 (2023):

| # | Risk | What to Check |
|---|------|---------------|
| API1 | Broken Object Level Authorization | Can users access other users' resources by changing IDs? |
| API2 | Broken Authentication | Are auth mechanisms robust? Token handling secure? |
| API3 | Broken Object Property Level Authorization | Can users read/write properties they shouldn't? (mass assignment) |
| API4 | Unrestricted Resource Consumption | Are rate limits, pagination limits, and payload sizes enforced? |
| API5 | Broken Function Level Authorization | Can regular users access admin endpoints? |
| API6 | Unrestricted Access to Sensitive Business Flows | Can automated attacks exploit business logic? (e.g., scalping, credential stuffing) |
| API7 | Server-Side Request Forgery (SSRF) | Do any endpoints fetch external URLs from user input? |
| API8 | Security Misconfiguration | Are defaults secure? Is error info over-exposed? |
| API9 | Improper Inventory Management | Are all API versions and endpoints documented? Are deprecated versions sunset? |
| API10 | Unsafe Consumption of APIs | Are third-party API responses validated before use? |

---

## Common Gaps to Flag

- No input validation strategy
- CORS misconfigured or `Access-Control-Allow-Origin: *` with credentials
- Cookie-based auth with no CSRF protection
- GET requests that perform state changes (side effects on safe methods)
- No security logging or monitoring plan
- No HSTS or security headers configured
- Deprecated API versions still accessible without sunset plan
- Login/register/reset endpoints leak account existence through different responses
- No enumeration defense strategy (consistent responses, rate limiting, CAPTCHA)
- Unprotected "check availability" endpoints
- Stack traces, database errors, or internal service names visible in production responses
- Server/X-Powered-By headers revealing technology stack
- Internal/admin endpoints exposed on public API

## References

See `sources.md` for all source references and further reading.
