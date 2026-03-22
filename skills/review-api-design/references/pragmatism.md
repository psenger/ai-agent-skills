# Pragmatism — Design Review Checklist

Source: [Best Practices for REST API](https://github.com/psenger/Best-Practices-For-Rest-API) by Philip A Senger (CC BY 4.0)

---

Being pragmatic means making decisions that work in the real world, not just in theory. Over-engineering and dependency accumulation can cripple long-term maintainability.

## Review Checkpoints

### Dependency Evaluation

- Have dependencies been critically evaluated? For each one, ask:
  - Can this be written in under 100 lines?
  - How many transitive dependencies does it bring?
  - Is it actively maintained?
  - What's the download size impact?
- Is there a plan for auditing dependencies for vulnerabilities? (npm-audit, Snyk, Socket.dev)
- Are standard library functions preferred over utility packages?

### Framework Lock-in

- Is business logic kept framework-agnostic? (no Express/NestJS/etc. types in domain code)
- Is the architecture using ports and adapters (Hexagonal Architecture)?
  - Business logic should be testable without HTTP
  - Business logic should be reusable across contexts (CLI, serverless, etc.)
- Has the framework's longevity been evaluated?
- Are libraries preferred over frameworks where possible? (libraries you call; frameworks call you)

### Build vs Buy

- For each "buy" decision (managed auth, rate limiting, API gateway), has this been evaluated:
  - **Vendor lock-in** — Can you migrate away if needed?
  - **Cost at scale** — Cheap at low volume doesn't mean cheap at high volume
  - **Complexity** — Does the "simple" solution actually simplify things?
  - **Control** — What happens when the service doesn't do exactly what you need?

### AI-Assisted Development

- If AI tools are planned for development, is there human oversight for:
  - Security-critical code (auth, validation, access control)
  - Edge case handling
  - Performance-sensitive operations

## Key Principle

> Evaluate every technology choice against the real-world constraints of your team, timeline, and maintenance burden. The best tool is the one your team can operate sustainably.

## Common Gaps to Flag

- "We'll use this framework because it's popular" without evaluating lock-in
- Dozens of dependencies for functionality that could be written in-house
- "We'll use a managed service" without evaluating cost at scale or migration path
- Business logic tightly coupled to HTTP framework types
- No plan for dependency auditing or supply chain security

## References

See `sources.md` for all source references and further reading.
