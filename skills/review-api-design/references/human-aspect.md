# Human Aspect — Design Review Checklist

Source: [Best Practices for REST API](https://github.com/psenger/Best-Practices-For-Rest-API) by Philip A Senger (CC BY 4.0)

---

The biggest barrier to API adoption isn't technical — it's human. Resistance shows up as laziness, other priorities, stubbornness, or "we don't need to change." A well-designed API that nobody uses is a failed API.

## Review Checkpoints

### Adoption

The four pillars of adoption: Ease of use, Documentation, Stability, Assurance.

**Check for:**

- Is the API designed with a contract-first approach using OpenAPI 3.x?
- Will interactive documentation be generated (Swagger UI, Redoc, Stoplight)?
- Are barriers to getting started minimized? (self-service access, clear onboarding)
- Is there a 30-second elevator pitch for what this API does?

### Documentation

- Does the plan include API specifications, user stories, and examples?
- Will documentation be indexed and searchable?
- Are edge cases and error scenarios documented, not just happy paths?
- Is the documentation strategy sustainable? (generated from spec, not manually maintained)
- Will client SDKs or server stubs be generated from the spec? (OpenAPI Generator, Swagger Codegen)

### Stability — Non-Functional Requirements

- Are NFRs defined and published?
  - Response time targets (p50, p95, p99 latency)
  - Availability SLA (99.9%, 99.95%, etc.)
  - Throughput (requests per second)
  - Payload size limits
- Is there a strategy for introducing breaking changes? (versioning, Sunset headers per RFC 8594, migration guides)
- Are deprecation timelines communicated to consumers?

### Assurance — Testing Strategy

- Is there a plan for load testing? (k6, Gatling, Locust)
- Will synthetic monitoring probe endpoints continuously?
- Has chaos engineering been considered for failure mode testing?
- Are NFRs validated continuously, not just at launch?

### Intuitiveness

- Can the API be explored with a browser (GET endpoints return JSON)?
- Does the naming reflect the domain in language consumers understand?
- Is JSON the data format? (de facto standard)
- Are data structures formally defined? (JSON Schema)
- Is the API consistent — same patterns and conventions across all endpoints?

## Key Principle

> Consistency coupled with good documentation will win over hearts and minds.

## Common Gaps to Flag

- API designed without consumer input (no frontend/mobile team review of the contract)
- No documentation strategy beyond "we'll add Swagger later"
- NFRs undefined or hand-waved ("it'll be fast enough")
- No plan for SDK generation or developer portal
- Breaking changes handled by "we'll just tell people"

## References

See `sources.md` for all source references and further reading.
