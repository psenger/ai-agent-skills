# Security: Identity, Access & Trust — Design Review Checklist

Source: [Best Practices for REST API](https://github.com/psenger/Best-Practices-For-Rest-API) by Philip A Senger (CC BY 4.0)

---

This checklist covers identity, authentication, authorization, and trust boundaries.

## Table of Contents

1. [Security Principles](#security-principles)
2. [Risk-Based Security](#risk-based-security)
3. [Authentication vs Authorization](#authentication-vs-authorization)
4. [Authorization Models](#authorization-models)
5. [Circles of Trust](#circles-of-trust)
6. [Passwords](#passwords)
7. [Multi-Factor Authentication](#multi-factor-authentication)
8. [Encrypted Transmission](#encrypted-transmission)
9. [Tokens](#tokens)
10. [Rate Limiting](#rate-limiting)
11. [Session Management](#session-management)

---

## Security Principles

### Zero Trust

**Check for:**
- Are all requests authenticated, even from internal networks?
- Is least privilege applied? (just-in-time, just-enough-access)
- Is the design assuming breach? (minimized blast radius, segmented access)

### Defense in Depth

Layer security controls so no single mechanism is the only protection.

**Check for:**
- Are there multiple security layers? (gateway rate limiting/WAF, token validation, permission checks, input validation, domain rules)
- If one layer fails, do others still protect the system?

### CIA Triad

| Principle | API Implications |
|-----------|-----------------|
| **Confidentiality** | Encryption in transit (TLS), proper authorization, field-level access control |
| **Integrity** | Input validation, checksums, audit logs, signed payloads |
| **Availability** | Rate limiting, circuit breakers, DDoS protection, redundancy |

### Fail Secure

- When auth service crashes, does the system deny access (not grant it)?
- When token validation fails, is the request treated as unauthenticated?
- When rate limit service is down, are conservative defaults applied?
- When configuration is missing, are secure defaults used?

### Separation of Duties

- Do service accounts have focused permissions, not "god mode" access?
- Do sensitive operations require multiple parties?

---

## Risk-Based Security

Risk-based security prioritizes threats based on their potential business impact and likelihood of exploitation. Instead of treating all vulnerabilities equally, it focuses resources on mitigating the most critical risks.

### Why This Matters at Design Time

Security decisions made during API design have the highest leverage and lowest cost to change. A risk-based approach prevents two common failures:
- **Under-securing critical assets** — treating a payment API with the same security as a public catalog API
- **Over-securing low-value assets** — spending engineering time on defense-in-depth for an internal health check endpoint

### Threat Modeling

**Check for:**
- Has a threat model been created for the API? (even informal — identify what could go wrong, how likely it is, and what the impact would be)
- Are critical assets identified? What data and operations does this API protect?
  - **High value:** Payment processing, PII, authentication, admin operations
  - **Medium value:** User-generated content, preferences, non-sensitive business data
  - **Low value:** Public catalog data, health checks, static configuration
- Are threat actors identified? Who might attack this API?
  - External attackers (automated scanners, targeted attacks)
  - Authenticated users attempting privilege escalation
  - Compromised internal services
  - Malicious insiders
- Are attack vectors mapped to the API surface?
  - Which endpoints are public vs authenticated?
  - Which endpoints handle sensitive data?
  - Which endpoints perform state-changing operations?

### Risk Assessment and Prioritization

- Are security controls proportional to the asset value?

| Asset Value | Security Controls | Example |
|-------------|-------------------|---------|
| **Critical** | Full defense-in-depth: MFA, rate limiting, step-up auth, audit logging, encryption at rest, anomaly detection | Payment API, auth endpoints |
| **High** | Strong auth, rate limiting, input validation, audit logging | User profile API, order management |
| **Medium** | Standard auth, input validation, rate limiting | Content management, search |
| **Low** | Basic auth or public access, standard input validation | Public catalog, health checks |

- Is the risk assessment documented? (so future developers understand why certain endpoints have stricter controls)
- Are security decisions traceable to specific risks? ("We added step-up auth to the payment endpoint because compromise would result in direct financial loss" — not "we add step-up auth to everything because it's best practice")

### Continuous Risk Management

- Is there a plan to reassess risks when the API evolves? (new endpoints, new data types, new consumers)
- Are risk acceptance decisions documented? ("We accept the risk of not rate-limiting the internal health check because it's behind the service mesh and the impact of abuse is minimal")
- Is there a process for responding to new threats? (e.g., a new CVE in a dependency, a new attack technique targeting your auth pattern)

### Common Risk-Based Security Gaps

- All endpoints treated with identical security controls regardless of sensitivity
- No threat model — security controls chosen by copy-pasting from a checklist without understanding what's being protected
- High-value endpoints (payments, auth) without proportionally stronger controls
- Risk acceptance decisions not documented (implicit acceptance is invisible)
- No plan to reassess security when the API scope changes

---

## Authentication vs Authorization

**Check for:**
- Is the design using OAuth 2.0/2.1 for authorization + OpenID Connect for authentication?
- Is PKCE used for ALL OAuth flows, including confidential clients? (mandatory per RFC 9700)
- Is the implicit grant flow explicitly prohibited? (deprecated by RFC 9700 and OAuth 2.1)
- For private/internal APIs: JWT tokens for stateless auth?
- For public-facing APIs: OIDC for auth + OAuth 2.0/2.1 with PKCE for mobile/SPA?
- Is Basic Auth avoided for application-to-application communication? (use mTLS or signed JWTs instead)

> OAuth 2.0 is an authorization framework, not authentication. OIDC builds on OAuth 2.0 to add authentication. OAuth 2.1 consolidates OAuth 2.0 + security best practices (PKCE mandatory, implicit flow removed).

---

## Authorization Models

Choose the right authorization model for your complexity level:

- Is Role-Based Access Control (RBAC) used? Suitable for most APIs with straightforward permission needs.
- For complex authorization: is Attribute-Based Access Control (ABAC) or Relationship-Based Access Control (ReBAC) considered? (e.g., Google Zanzibar model — used by Auth0 FGA, SpiceDB, Ory Permissions)
- Is Broken Object Level Authorization (BOLA) addressed? This is the #1 OWASP API Security risk — users must not be able to access other users' resources by changing IDs.
- Is Broken Function Level Authorization addressed? Users must not be able to access admin endpoints by guessing URLs.
- Is the Principle of Least Privilege applied? (grant only minimum permissions needed)
- Is a grant-based permissions model used? (start with no access, explicitly grant)
- Are roles kept simple? (they always grow more complex over time)

---

## Circles of Trust

| Circle | Trust Level | Auth Required |
|--------|-------------|---------------|
| Public Internet | None | Full auth + rate limiting |
| Partner Network | Low | API keys + mutual TLS |
| Corporate Network | Medium | SSO + network controls |
| Service Mesh | High | Service identity (mTLS) |
| Internal Services | High | Service identity (mTLS) + authorization |

> Even internal services must authenticate in a zero-trust architecture. "Implicit trust" based on network location is the anti-pattern that zero trust eliminates.

**Check for:**
- Is trust NOT based solely on network location?
- Is authentication required at every trust boundary crossing?
- Do internal services authenticate via mTLS or signed tokens?
- Do session tokens from high-trust contexts expire faster in lower-trust contexts?
- Are federation protocols planned? (SAML 2.0, OIDC, OAuth 2.0 across boundaries)

---

## Passwords

If passwords are stored:
- Is a purpose-built password hashing algorithm used?
  - **Argon2id** — preferred (minimum: 19 MiB memory, 2 iterations, 1 parallelism)
  - **scrypt** — strong alternative (minimum: N=2^17, r=8, p=1)
  - **PBKDF2** — acceptable for FIPS-140 compliance (minimum: 600,000+ iterations with HMAC-SHA-256)
  - **bcrypt** — legacy systems only (72-byte input limitation, no longer recommended for new implementations)
- Are general-purpose hashes (MD5, SHA-256) explicitly avoided?
- Does the algorithm include built-in salting?

---

## Multi-Factor Authentication

- Is MFA planned? Ranked by security strength:
  1. **Passkeys / FIDO2 / WebAuthn** — phishing-resistant, NIST-mandated baseline (SP 800-63-4). The current gold standard per NIST SP 800-63-4.
  2. **TOTP (authenticator apps)** — good, works offline, widely supported
  3. **SMS / Email OTP** — fallback only with documented risk acceptance. NIST SP 800-63-4 has significantly downgraded SMS-based authentication. Not acceptable for high-assurance scenarios.
- Is phishing-resistant MFA (FIDO2/WebAuthn/passkeys) supported? Per NIST SP 800-63-4, this is the baseline for strong authentication.
- Are backup codes provided for account recovery?
- Are OTP verification attempts rate limited?
- Is constant-time comparison used for OTP verification? (prevents timing attacks)
- For SMS OTP: is it a last-resort fallback with documented risk acceptance, not a primary or even secondary method?

---

## Encrypted Transmission

- Is TLS 1.3 preferred, with TLS 1.2 as the minimum acceptable version?
- Are TLS 1.0 and 1.1 explicitly disabled?
- Are cipher suites with forward secrecy required? (e.g., ECDHE)
- Is HSTS (HTTP Strict Transport Security) enabled?
- Is there a plan for certificate management and rotation?
- Is certificate pinning considered for mobile apps?

---

## Tokens

### JWT Design

- Are JWT signatures verified with an explicit algorithm? (never trust the `alg` header — attackers can set `alg: none`)
- Are these claims validated: issuer (`iss`), expiration (`exp`), not-before (`nbf`), audience (`aud`)?
- Is JTI (JWT ID) used for token revocation and replay prevention?
- Is DPoP (Demonstration of Proof of Possession, RFC 9449) considered? DPoP binds tokens to a specific client, making stolen bearer tokens useless.

### Token Storage

- For SPAs: is the Backend-for-Frontend (BFF) pattern used? (tokens stay server-side, frontend receives only an HttpOnly session cookie — more secure than cookies containing JWTs)
- If BFF is not used: are JWTs stored in HTTP-only cookies? (never localStorage or sessionStorage)
- Are cookies configured with: `HttpOnly`, `Secure`, `SameSite=Strict`?

### Access and Refresh Tokens

- Is a two-token pattern used?
  - Access token: 15-20 min lifetime, authorizes API requests
  - Refresh token: days/weeks, used only to obtain new access tokens
- Is refresh token rotation implemented? (old token invalidated on refresh)
- Are refresh tokens on a separate cookie path? (`Path=/auth/refresh`)

### Risk-Based Assessment (per-request)

- Are sensitive operations treated differently from normal operations?
- Is step-up authentication required for: password changes, email changes, payment changes, MFA changes, account deletion, data export, permission grants? (see RFC 9470 — OAuth 2.0 Step-Up Authentication Challenge Protocol)
- Are risk signals evaluated? (new device, new location, unusual time, failed attempts, velocity)

### JWS vs JWE

- Is JWS (signed, readable) used when claims aren't sensitive?
- Is JWE (encrypted) considered when tokens contain sensitive data or pass between services?

### Security Model

- Is the design using distributed security (zero trust) over perimeter security?
- Does each service validate tokens and enforce authorization independently?
- Is service-to-service auth planned? (mTLS, service accounts)

### Identity Infrastructure

- Is an established identity provider used? (Keycloak, Okta, Auth0, Zitadel, Ory — don't build your own)
- Is PAM (Privileged Access Management) addressed? (credential vaulting, just-in-time access)
- Are secrets retrieved from a vault at runtime? (HashiCorp Vault, AWS Secrets Manager — not from config files or env vars baked into deployments)

---

## Rate Limiting

- Is rate limiting planned for all endpoints?
- Is rate limiting applied differently per endpoint sensitivity? (e.g., login endpoints stricter than read-only endpoints)
- Are standard headers used? The current IETF draft defines `RateLimit` and `RateLimit-Policy` as structured headers. The older three-header convention (`RateLimit-Limit`, `RateLimit-Remaining`, `RateLimit-Reset`) remains widely used in practice.
- Is `429 Too Many Requests` returned with `Retry-After` header?
- What is the rate limit key? (IP address is problematic behind NAT; user ID or JTI+device is better)

---

## Session Management

- Is the session policy defined?
  - Single session (more secure, frustrating for multi-device users)
  - Multiple sessions (better UX, requires session listing UI and individual revocation)
  - Concurrent session limits (N sessions max, evict oldest)
- For high-security apps: single session + step-up auth for sensitive operations?
- Is session ID regenerated after authentication and privilege escalation?
- Are idle and absolute session timeouts defined? (OWASP recommends 2-5 min idle for high-value, 15-30 min for lower-risk)

---

## Common Gaps to Flag

- Auth strategy undefined ("we'll figure it out later")
- No distinction between authentication and authorization
- Tokens planned for localStorage (XSS vulnerable)
- No rate limiting strategy
- No MFA plan for sensitive operations
- No passkey/FIDO2 support planned
- Passwords hashed with SHA-256, MD5, or bcrypt in new systems
- No session management policy defined
- Service-to-service communication without auth ("it's internal")
- Secrets in environment variables baked into deployments
- Implicit grant flow still in use
- No threat model — security controls chosen without understanding what's being protected
- All endpoints treated identically regardless of sensitivity
- Risk acceptance decisions not documented
- BOLA not addressed (users can access other users' data by guessing IDs)
- Sequential/predictable IDs exposed in public API URLs (enumeration risk — use opaque/random IDs, not sequential integers)

## References

See `sources.md` for all source references and further reading.
