# API Gateways — Design Review Checklist

Source: [Best Practices for REST API](https://github.com/psenger/Best-Practices-For-Rest-API) by Philip A Senger (CC BY 4.0)

---

API gateways sit between clients and backend services, providing a single entry point. They handle cross-cutting concerns so your services don't have to. They are a well-established architectural pattern, not an anti-pattern.

## Core Functions

An API gateway handles:
- **Routing** — direct requests to the appropriate backend
- **Authentication** — validate tokens, API keys, certificates
- **Rate limiting** — protect backends from traffic spikes
- **Transformation** — modify requests/responses (headers, body, format)
- **Aggregation** — combine multiple backend calls into one response
- **Caching** — cache responses to reduce backend load
- **Monitoring** — collect metrics, logs, traces

---

## Review Checkpoints

### Do You Need a Gateway?

**Use a gateway when:**
- Multiple backend services need consistent authentication
- External clients need a stable API while internals evolve
- You need to aggregate or transform responses
- Rate limiting and throttling are critical
- You want a developer portal for API documentation

**Skip the gateway when:**
- You have a single service (put concerns in the service itself)
- Internal-only APIs where services call each other directly
- Adding complexity without clear benefit
- Your team can't operate another critical system

### Gateway Selection

| Product | Strengths | Weaknesses |
|---------|-----------|------------|
| **Kong** (open-source) | Large plugin ecosystem, runs anywhere, lower cost | Enterprise features need paid subscription |
| **Apigee** (Google) | Comprehensive analytics, API monetization, dev portal | Complex, expensive, Google Cloud lock-in |
| **AWS API Gateway** | Serverless, native AWS integration, pay-per-request | AWS coupling, limited transformations, Lambda cold starts |
| **Azure API Management** | Native Azure integration, good dev portal, policy engine | Azure lock-in, complex pricing, slow deployments |
| **Traefik** | Cloud-native, good for Kubernetes | |
| **Envoy** | Service mesh focused, used by Istio | |

### Gateway Patterns

**Simple Proxy** — pass-through with cross-cutting concerns (auth, rate limiting). Use for basic protection of existing APIs.

**Request/Response Transformation** — modify requests/responses for format normalization, legacy client support, header injection.

**Aggregation (Backend for Frontend / BFF)** — combine multiple backend calls into a single response. Benefits: reduced latency (parallel calls), simpler clients, hidden internal boundaries. Risks: gateway becomes complex, partial failure handling is tricky.

**Pipeline/Mediation** — sequence of transformations (validate → enrich → transform → route). Common in Apigee/Azure APIM with declarative policies.

**Service Mesh Integration** — gateway handles north-south traffic (external → internal), service mesh handles east-west traffic (service ↔ service). Gateway handles API versioning, public rate limits; mesh handles mTLS, circuit breaking, retries.

---

## Anti-Patterns to Flag

### Gateway as Business Logic Layer
If the gateway contains calculations, conditional flows, or data lookups, you've built a monolith. Business logic belongs in services.

### Over-Aggregation
Aggregating 10+ backend calls in the gateway creates a fragile, hard-to-debug system. Consider a dedicated BFF service instead.

### Configuration Drift
Gateway configuration edited manually in production without version control. Treat gateway config as code, store in git, review changes.

### Ignoring Failures
Gateway aggregation must handle partial failures. If one of five backends fails, what does the client get? This must be defined explicitly.

---

## Pros and Cons Summary

**Advantages:**
- Centralized cross-cutting concerns (auth, rate limiting, logging — implemented once)
- Single entry point for clients (consistent versioning)
- Backend flexibility (refactor, split, migrate without changing client contracts)
- Security boundary (external traffic never touches backends directly)
- Observability (single point for metrics, logs, traces)

**Disadvantages:**
- Single point of failure (requires HA configuration)
- Added latency (extra hop for every request)
- Operational complexity (another system to monitor, secure, update, scale)
- Logic sprawl (temptation to put "just one more thing" in the gateway)
- Vendor lock-in (gateway-specific policies don't port easily)
- Cost (enterprise gateways are expensive)

---

## Practical Recommendations

1. **Start simple** — begin with basic routing and auth, add complexity only when needed
2. **Version your configuration** — store gateway config in git, review like code
3. **Monitor gateway performance** — track latency added by the gateway itself
4. **Plan for failure** — what happens when the gateway is unavailable? Have a runbook
5. **Limit transformation complexity** — if transformations get complex, build a dedicated service
6. **Document policies** — future maintainers need to understand why each policy exists

---

## Common Gaps to Flag

- Gateway planned but no HA/failover strategy
- Business logic creeping into gateway configuration
- No plan for gateway config version control
- Over-reliance on gateway for things that should be in services
- Gateway selected without evaluating vendor lock-in
- No plan for monitoring gateway-added latency
- Aggregation pattern without defined partial failure behavior

## References

See `sources.md` for all source references and further reading.
