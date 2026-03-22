# Resilience — Design Review Checklist

Source: [Best Practices for REST API](https://github.com/psenger/Best-Practices-For-Rest-API) by Philip A Senger (CC BY 4.0)

---

APIs fail. Networks drop. Services crash. Resilience is about designing systems that handle failure gracefully rather than catastrophically.

## Table of Contents

1. [Service Unavailability](#service-unavailability)
2. [Retry Strategy](#retry-strategy)
3. [Circuit Breaker](#circuit-breaker)
4. [Graceful Degradation](#graceful-degradation)
5. [Timeouts](#timeouts)
6. [Bulkheads](#bulkheads)
7. [Caching](#caching)
8. [Observability and Metrics](#observability-and-metrics)

---

## Service Unavailability

**Check for:**
- Does the API return `503 Service Unavailable` (not 504) when temporarily unavailable?
- Is a `Retry-After` header included with 503 responses?
- Is there a strategy for handling dynamic horizontal scaling (brief unavailability during scale-up)?

---

## Retry Strategy

Clients should implement retry logic with exponential backoff and jitter.

**Check for:**
- Is a retry strategy defined for client-facing documentation?
- Does the strategy use exponential backoff? (1s, 2s, 4s, 8s, 16s)
- Does the strategy include jitter? (random delay added to prevent thundering herd)
- Is there a max retry limit?
- Does the client honor `Retry-After` headers when present?
- Are only retryable status codes retried? (503, 429 — not 400, 401, 404)

**Why jitter matters:** Without jitter, when a service recovers from an outage, all waiting clients retry simultaneously, causing a thundering herd that brings the service down again.

---

## Circuit Breaker

The circuit breaker prevents cascading failures by failing fast when a downstream service is unhealthy.

**Three states:**
- **Closed** — Normal operation. Requests pass through. Track failure rate.
- **Open** — Service is down. Fail immediately. Return cached data or graceful degradation.
- **Half-Open** — After timeout, allow test requests. Success closes circuit; failure reopens.

**Check for:**
- Are circuit breakers planned for downstream service calls?
- Are failure thresholds defined? (e.g., 5 failures in 60 seconds)
- Is the open duration defined? (e.g., 30 seconds before trying half-open)
- Is there a fallback strategy when the circuit is open?
- Are production-ready libraries considered? (opossum for Node.js, resilience4j for Java, Polly for .NET)

---

## Graceful Degradation

When circuits open, the system should degrade, not collapse.

**Check for:**
- Is there a strategy for each degradation scenario?
  - Return cached data (even if stale)
  - Return partial results
  - Use fallback services
  - Queue requests for later processing
- Is the degradation behavior documented for consumers?
- Does the system communicate its degraded state? (health check readiness, response headers)

---

## Timeouts

Every external call needs a timeout. Without timeouts, a slow downstream service can exhaust connection pools and bring down the entire system.

**Check for:**
- Are timeouts defined for all external calls?
  - **Connect timeout** — How long to wait for a connection (1-5 seconds)
  - **Read timeout** — How long to wait for a response (varies by operation)
  - **Total timeout** — Maximum time for the entire operation including retries
- Are timeouts aligned with SLAs? (if you promise p99 < 200ms, downstream timeouts must be well under that)
- Is there a cascading timeout budget? (each service in the chain gets a portion of the total budget)

---

## Bulkheads

Bulkheads isolate failures to prevent them from spreading. Named after ship compartments that contain flooding.

**Check for:**
- Are resource pools isolated by dependency? (if payment service is slow, it shouldn't take down the product catalog)
- Is there a strategy for isolation?
  - Thread pool isolation — each dependency gets its own pool
  - Connection pool isolation — separate pools per service
  - Semaphore isolation — limit concurrent requests per dependency

---

## Caching

### Strategy

**Check for:**
- Are standard HTTP cache headers used? (`Cache-Control`, `ETag`, `Last-Modified`, `Vary`)
- Is proprietary caching avoided in favor of HTTP standards?
- Is there a clear cache topology? (where are caches, who's responsible for each)

### Cache-Control Directives

| Directive | Purpose |
|-----------|---------|
| `max-age` | How long (seconds) the response can be cached |
| `no-cache` | Must revalidate with origin before using |
| `no-store` | Never cache (sensitive data) |
| `private` | Only browser can cache, not CDNs |
| `public` | Any cache can store |
| `must-revalidate` | Once stale, must check origin |

### What to Cache vs. What Not to Cache

**Good candidates:** Reference data, public content, expensive computations, static assets

**Never cache:** User-specific data without `Vary` headers, sensitive information (`no-store`), data that must be current (account balances), responses to POST/PUT/PATCH/DELETE

### Cache Invalidation

- Is the invalidation strategy defined?
  - Time-based expiry (TTL) — simple but may serve stale data
  - Event-driven invalidation — publish events when data changes
  - Conditional requests (ETags) — check if cached data is still valid
- Is `stale-while-revalidate` considered for popular cached items?
- Is there a plan to prevent cache stampedes? (lock-based refresh, probabilistic early refresh)
- Are cache hit rates monitored?

### Debugging

- Are cache diagnostic headers planned? (`X-Cache: HIT` or `X-Cache: MISS`)
- Is cache interaction logging planned?
- Is the cache topology documented?

---

## Observability and Metrics

Observability is the ability to understand what's happening inside the system by examining its outputs. Plan for this at design time — bolting it on after launch is expensive and incomplete.

### The Three Pillars

| Pillar | What It Tells You | API Design Implications |
|--------|-------------------|------------------------|
| **Metrics** | How the system is performing (quantitative) | Define what to measure, expose metric endpoints |
| **Logs** | What happened (events, errors, decisions) | Structured logging format, correlation IDs |
| **Traces** | How a request flowed through the system | Distributed tracing headers, span context propagation |

### SLIs, SLOs, and Error Budgets

Define these at design time, not after launch.

- **SLI (Service Level Indicator)** — a quantitative measure of service health. Examples: request latency (p99), error rate, availability, throughput.
- **SLO (Service Level Objective)** — a target value for an SLI. Example: "p99 latency < 200ms" or "error rate < 0.1%".
- **SLA (Service Level Agreement)** — a contractual promise to consumers based on SLOs. Breaking an SLA has business consequences.
- **Error Budget** — the amount of unreliability you can tolerate (100% - SLO). If your SLO is 99.9% availability, your error budget is 0.1% downtime (~8.7 hours/year). When the budget is spent, freeze deployments and focus on reliability.

**Check for:**
- Are SLIs defined for the API? At minimum:
  - **Availability** — percentage of successful requests (non-5xx)
  - **Latency** — p50, p95, p99 response times
  - **Error rate** — percentage of requests returning errors
  - **Throughput** — requests per second
- Are SLOs set for each SLI? (concrete targets, not "it should be fast")
- Are error budgets defined? (how much unreliability is acceptable before action is taken)
- Are SLOs aligned with downstream timeout budgets? (if SLO is p99 < 200ms but a downstream call has a 5s timeout, something is wrong)

### Metrics to Plan For

**Check for:**
- Are RED metrics planned for every endpoint?
  - **R**ate — requests per second
  - **E**rrors — error count/rate by status code
  - **D**uration — latency distribution (p50, p95, p99)
- Are saturation metrics planned?
  - Connection pool utilization
  - Thread/goroutine count
  - Memory usage
  - Queue depth
- Is metric cardinality considered? (high-cardinality labels like user_id or request_id on metrics can explode storage costs and query times — use traces for high-cardinality data, not metric labels)
- Are business metrics planned? (orders created/sec, payments processed/sec — not just infrastructure metrics)
- Is a metrics endpoint exposed? (`/metrics` in Prometheus format, or equivalent)

### Structured Logging

**Check for:**
- Are logs structured (JSON) rather than unstructured text?
- Do all log entries include: timestamp, log level, service name, correlation ID, request ID?
- Are log levels used consistently? (ERROR for failures requiring action, WARN for degradation, INFO for business events, DEBUG for development)
- Is sensitive data excluded from logs? (passwords, tokens, PII — log the request ID, not the request body)
- Is there a log aggregation strategy? (centralized logging — ELK, Loki, CloudWatch, Datadog)

### Distributed Tracing

**Check for:**
- Is distributed tracing planned? (OpenTelemetry, Jaeger, Zipkin)
- Are trace context headers propagated across service boundaries? (W3C Trace Context: `traceparent`, `tracestate`)
- Are spans created for key operations? (HTTP handler, database query, external API call, queue publish/consume)
- Is trace sampling configured? (100% tracing at scale is expensive — sample 1-10% in production, 100% for errors)

### Alerting

**Check for:**
- Are alerts defined for SLO violations? (not just "CPU > 80%" — alert on user-facing impact)
- Are alerts based on burn rate? (how fast are we consuming the error budget, not just "is it above threshold right now")
- Is there a clear escalation path? (who gets paged, in what order)
- Are alerts actionable? (every alert should have a runbook or at least a clear first step)

### Common Observability Gaps to Flag

- No SLIs or SLOs defined ("we'll figure out what 'healthy' means later")
- Metrics planned but no alerting strategy
- Unstructured logs (grep-based debugging at scale is unsustainable)
- No distributed tracing across service boundaries
- High-cardinality metric labels (user_id, request_path with IDs)
- Alerts on infrastructure metrics only (CPU, memory) with no user-facing SLO alerts
- No log aggregation strategy
- Sensitive data in logs (tokens, passwords, PII)

---

## Common Gaps to Flag

- No retry strategy documented for consumers
- No circuit breakers on downstream service calls
- No timeouts on external calls
- "We'll add caching later" without a strategy
- Cache layers piled up without clear ownership or invalidation strategy
- No graceful degradation — circuits open and the system just errors
- No bulkhead isolation — one slow dependency takes down everything
- SLAs defined but timeout budgets not aligned with them
- No SLIs/SLOs defined for the API
- No observability strategy (metrics, logs, traces not planned)
- No alerting on user-facing SLO violations

## References

See `sources.md` for all source references and further reading.
