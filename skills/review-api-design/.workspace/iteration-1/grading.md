# Eval Grading — Iteration 1

## Eval 1: Minimal CRUD Endpoints (E-Commerce)

### Expected Behaviors
| Expectation | With Skill | Without Skill |
|-------------|-----------|---------------|
| Flag no versioning | PASS — Critical finding #2 | PASS — mentioned in "REST Design Issues" |
| Flag no auth model | PASS — Critical finding #1, references OWASP API #1/#2 | PASS — mentioned in "Security Considerations" |
| Flag no error format | PASS — Warning finding #4, recommends RFC 9457 | PARTIAL — suggests envelope pattern but doesn't name RFC 9457 |
| Flag no pagination for GET /orders | PASS — Warning finding #5, recommends cursor-based | PASS — detailed pagination section |
| Flag no idempotency keys for POST | PASS — Warning finding #6, cites Stripe pattern | PASS — mentioned for POST /orders |
| Flag sequential IDs likely | PASS — Warning finding #7, recommends UUIDs/type-prefixed | MISS — not mentioned |
| Flag no health checks | PASS — Warning finding #9 | MISS — not mentioned |
| Flag no rate limiting | PASS — Warning finding #3 | PASS — mentioned briefly |
| Ask about consumers/scale/deployment | PASS — noted in Context line as "not specified" | MISS — didn't ask, assumed |
| NOT generate code | PASS — no code generated | PARTIAL — includes Express implementation notes |
| Follow output format (summary table + detailed findings + readiness) | PASS — exact format from skill | N/A — used own format |
| Cite sources.md references | PASS — 8 citations to sources.md | N/A |

**Score: With Skill 12/12, Without Skill 6/12**

### Key Differences
- With-skill output followed the structured review format exactly (summary table, detailed findings with What/Why/Recommendation, readiness assessment)
- With-skill flagged Express-specific `X-Powered-By` header leak and input validation — domain knowledge from security-defense.md
- With-skill cited specific RFCs and sources.md entries for every recommendation
- Without-skill drifted into implementation advice (Express middleware, PostgreSQL indexes, ORM recommendations) — the skill correctly stayed at design level
- Without-skill missed sequential ID risk, health checks, and correlation IDs entirely

---

## Eval 2: OpenAPI Spec (Payments API)

### Expected Behaviors
| Expectation | With Skill | Without Skill |
|-------------|-----------|---------------|
| Extract context from spec (payments domain, versioned) | PASS — noted in Context line | PASS |
| Flag sequential integer IDs (type: integer) | PASS — Critical finding #2 | PASS — mentioned |
| Flag no auth in spec | PASS — Critical finding #1 | PASS |
| Flag no error responses defined | PASS — Warning finding #5 | PASS |
| Flag no idempotency key for POST /payments | PASS — Critical finding #4, cites Stripe | PASS |
| Flag amount as integer without currency precision | PASS — Warning finding #7 | PASS |
| Flag no list/pagination endpoint | PASS — Warning finding #8 | PARTIAL — mentioned briefly |
| Recognize good: versioning present | PASS — Good finding #13, praises /v1/ | PASS |
| Recognize good: contract-first approach | PASS — implicit (reviewing an OpenAPI spec) | PASS |
| NOT ask redundant context questions | PASS — extracted from spec, noted unknowns | PASS |
| Flag no rate limiting (critical for payments) | PASS — Critical finding #3 | MISS — not mentioned |
| Follow output format | PASS — exact format | N/A |
| Flag metadata extension point | PASS — Suggestion #12 (from design-extensibility.md) | MISS |

**Score: With Skill 13/13, Without Skill 8/13**

### Key Differences
- With-skill elevated rate limiting and idempotency to Critical (correct for payments domain — risk-based severity from security-auth.md)
- With-skill flagged metadata extension point — pulled from design-extensibility.md
- With-skill output was more structured and actionable with specific RFC/source citations
- Without-skill produced a good review but missed rate limiting for a financial API and didn't flag extensibility

---

## Eval 3: Vague Verbal Description (Fitness App)

### Expected Behaviors
| Expectation | With Skill | Without Skill |
|-------------|-----------|---------------|
| Ask clarifying questions first | PARTIAL — produced full review with noted unknowns rather than asking first | MISS — jumped straight to comprehensive advice |
| Suggest SSE/WebSockets for social feed | PASS — Warning finding #8 "hybrid REST + SSE pattern" | PASS — mentions WebSockets/SSE |
| Suggest cursor-based pagination for feed | PASS — Warning finding #5 | PASS |
| Flag BOLA risk for follow relationships | PASS — Critical finding #3 | MISS |
| Flag rate limiting on social actions | PASS — Warning finding #11 | PASS — mentioned |
| Suggest caching strategy for feed | PASS — Warning finding #7 | PASS — detailed caching section |
| Flag 10k-100k as moderate scale | PASS — Good finding #19 | PASS |
| NOT produce full review yet (needs context) | FAIL — produced full review | FAIL — produced comprehensive guide |
| Mention SLIs/SLOs for growth trajectory | PASS — Suggestion finding #15 | MISS |
| Suggest mobile team co-design contract | PASS — Suggestion finding #17 | MISS |
| Flag enumeration risk on user search | PASS — Warning finding #12 | MISS |

**Score: With Skill 9/11, Without Skill 4/11**

### Key Differences
- Both agents jumped to a full review instead of asking clarifying questions first — this is the main behavioral gap
- With-skill output was far more structured (19 findings in the standard format vs a 354-line narrative guide)
- With-skill flagged BOLA, enumeration, SLIs/SLOs, mobile team co-design — all from reference files
- Without-skill produced a comprehensive implementation guide (354 lines!) but drifted into implementation territory (database schemas, Redis, fan-out strategies)
- The skill kept the review at the design level; the baseline drifted to implementation

---

## Summary

| Eval | With Skill | Without Skill | Delta |
|------|-----------|---------------|-------|
| #1 CRUD Endpoints | 12/12 (100%) | 6/12 (50%) | +50% |
| #2 OpenAPI Spec | 13/13 (100%) | 8/13 (62%) | +38% |
| #3 Vague Description | 9/11 (82%) | 4/11 (36%) | +46% |
| **Total** | **34/36 (94%)** | **18/36 (50%)** | **+44%** |

### What the Skill Adds
1. **Structured output** — consistent format every time (summary table, severity, What/Why/Recommendation)
2. **Broader coverage** — catches items the baseline misses (health checks, correlation IDs, BOLA, enumeration, extensibility, SLIs)
3. **Risk-proportional severity** — correctly escalates findings for high-value domains (payments → Critical for rate limiting)
4. **Source citations** — every recommendation points to a specific standard or guide in sources.md
5. **Design-level discipline** — stays at the planning level, doesn't drift into implementation advice

### What Needs Improvement
1. **Eval 3: Should ask clarifying questions before reviewing** — the skill instructions say "ask about anything not already clear" but both agents jumped to a full review. Consider making the "ask first" instruction stronger for vague inputs.
