# API Extensibility & Evolution — Design Review Checklist

Source: [Best Practices for REST API](https://github.com/psenger/Best-Practices-For-Rest-API) by Philip A Senger (CC BY 4.0)

---

## Table of Contents

1. [Arity and Extensibility](#arity-and-extensibility)
   - [Fixed vs Variable Arity](#fixed-vs-variable-arity)
   - [Metadata as an Extension Point](#metadata-as-an-extension-point)
   - [Response-Side Arity and Extensibility](#response-side-arity-and-extensibility)
   - [Connection to SOLID Principles](#connection-to-solid-principles)
   - [Connection to Other Design Principles](#connection-to-other-design-principles)
   - [The Design Pattern](#the-design-pattern)
   - [Risks to Flag](#risks-to-flag)

---

## Arity and Extensibility

How many parameters an endpoint accepts (its "arity") and whether the payload shape is fixed or open has profound impact on API sustainability, backwards compatibility, and adherence to SOLID principles.

### Fixed vs Variable Arity

**Fixed arity** — the endpoint accepts a known, documented set of parameters. The request shape is fully specified in the OpenAPI contract.

```
POST /v1/customers
{ "name": "Alice", "email": "alice@example.com", "description": "VIP" }
```

**Variable arity** — the endpoint accepts a dynamic or open-ended set of parameters (query parameter bags, filter objects, extensible bodies).

```
GET /v1/issues?labels=bug,enhancement&state=open&assignee=alice&sort=updated&per_page=30
```

| Aspect | Fixed Arity | Variable Arity |
|--------|-------------|----------------|
| **Validation** | Strong, schema-enforceable | Harder to validate |
| **Documentation** | Clear, exhaustive | Harder to cover all combinations |
| **Code generation** | Excellent (typed clients) | Requires conventions |
| **Evolution** | Requires versioning to add params | Can add optional params without breaking |
| **Type safety** | Strong | Weak for the variable parts |
| **Discoverability** | High | Lower — consumers must know conventions |

**Check for:**
- Are core operations fixed-arity with strong schema validation? (create, update, delete)
- Are search/filter operations appropriately variable-arity with documented conventions?
- Are new parameters added as optional (not required) to preserve backwards compatibility?

### Metadata as an Extension Point

A `metadata` field is an intentionally schema-less key-value map that lets consumers store arbitrary data without the API provider changing the contract. This is the primary pattern for API extensibility without versioning.

**Real-world examples:**
- **Stripe** — `metadata` on every object (Customer, PaymentIntent, Subscription). Up to 50 keys, key names up to 40 chars, values up to 500 chars. Explicitly documented as having no functional impact on Stripe's behavior.
- **AWS** — Resource "tags" across every service. Up to 50 tags per resource. Used for cost allocation, access control policies, and automation — despite being schema-less.
- **Slack** — Structured `metadata` with `event_type` and `event_payload`. Optionally validated against a registered schema — a hybrid approach.

```json
{
  "id": "cus_abc123",
  "name": "Alice",
  "email": "alice@example.com",
  "metadata": {
    "cms_id": "6573",
    "plan_tier": "enterprise",
    "referred_by": "user_42"
  }
}
```

**Check for:**
- Do API objects include a `metadata` (or `tags`) extension point for consumer-owned data?
- Are metadata constraints defined? (max keys, max key length, max value length, string-only values)
- Is metadata documented as inert storage (no side effects) or as having functional impact?
- Is metadata searchable/filterable, or storage-only? (this affects consumer expectations)
- In OpenAPI, is the metadata field defined with `additionalProperties: { type: string }` and `maxProperties`?

### Response-Side Arity and Extensibility

The same principles apply to API responses. A response with a fixed, rigid shape is predictable but inflexible. A response with extension points evolves without breaking consumers.

**Fixed response shape** — every field is documented, typed, and always present:

```json
{ "id": "user_abc123", "name": "Alice", "email": "alice@example.com", "role": "admin" }
```

**Extensible response shape** — the core is fixed, but the response can grow:

```json
{
  "id": "user_abc123",
  "name": "Alice",
  "email": "alice@example.com",
  "role": "admin",
  "metadata": { "cms_id": "6573", "plan_tier": "enterprise" }
}
```

**Backwards-compatible response evolution** (adding fields is safe, removing is not):

| Change | Safe? | Why |
|--------|-------|-----|
| Add new optional field to response | Yes | Consumers should ignore unknown fields (Postel's Law) |
| Add new value to enum field | Risky | Consumers with exhaustive switch/case will break (Hyrum's Law) |
| Remove a field | No | Consumers depending on it will break (LSP violation) |
| Change a field's type | No | Breaks deserialization in typed clients |
| Change field from always-present to sometimes-null | Risky | Consumers not handling null will break |
| Add nested object where there was a scalar | No | Breaks all consumers |

**Check for:**
- Are response schemas designed to be additive? (new fields can be added without breaking consumers)
- Are consumers expected to ignore unknown fields? (documented in API guidelines — Postel's Law)
- Is field selection supported for large responses? (`?fields=id,name,email` — lets consumers request only what they need)
- Are envelope wrappers used consistently? (`{ "data": {...}, "meta": {...} }` — provides a stable outer structure that can grow)
- Are enum values documented as potentially extensible? ("New values may be added — do not use exhaustive matching")
- Is the response shape consistent across similar endpoints? (all list endpoints return the same pagination structure)
- Do response objects include a `metadata` or `tags` field for consumer-owned extension data?
- Is response shape versioned? (consumers pinned to a version always get the same shape)

**Stripe's approach to response evolution:**
- Adding new properties to responses is backwards-compatible
- Changing the order of properties is backwards-compatible
- Removing fields or changing types requires a new API version
- Consumers are version-pinned and opt into new shapes explicitly

### Connection to SOLID Principles

**Open/Closed Principle (OCP)** — the API is "closed" for existing consumers but "open" for extension through optional parameters and metadata. Adding optional fields is backwards-compatible; removing or changing types requires a new version.

**Interface Segregation Principle (ISP)** — each endpoint should accept only the parameters relevant to its concern. Avoid one fat endpoint doing everything.

**Liskov Substitution Principle (LSP)** — a new API version must be substitutable for the old. Preconditions cannot be strengthened; postconditions cannot be weakened.

### Connection to Other Design Principles

**Postel's Law (Robustness Principle)** — "Be conservative in what you send, be liberal in what you accept." Metadata embodies this: the API accepts arbitrary key-value pairs (liberal) while returning them in a consistent format (conservative). Variable arity on inputs aligns with the liberal acceptance side. But beware: being too liberal means bugs become entrenched as de facto standards.

**Hyrum's Law** — "With a sufficient number of users, all observable behaviors of your system will be depended on by somebody." This is the biggest risk of metadata fields. If consumers consistently store `metadata[order_id]`, downstream systems will depend on it — it becomes a de facto contract even though it was never in the schema. Fixed arity reduces Hyrum's Law exposure; variable arity and metadata increase the surface area for implicit dependencies.

**Principle of Least Astonishment** — metadata should be inert storage with no hidden side effects. If `metadata[priority]=urgent` secretly triggers a different processing queue, that's astonishing behavior. Document clearly whether metadata is passive or functional.

### The Design Pattern

The best APIs combine both: a **strict core schema** (fixed arity, typed, validated) with a **metadata escape hatch** (variable arity, untyped, consumer-owned). The core carries the contract; the metadata carries the extensibility.

```
RIGID ←——————————————————————————————→ FLEXIBLE
Fixed arity (core params)              Variable arity (metadata, filters)
Strong contracts, typed                Schema-less, unvalidated
Easy to version                        Hard to version (what's in metadata?)
Hyrum-resistant                        Hyrum-vulnerable
```

When a metadata pattern becomes universal across consumers, consider promoting it to a first-class field in the next API version.

### Risks to Flag

- Metadata used as a substitute for proper schema design ("just put it in metadata")
- No size constraints on metadata (unbounded storage, performance risk)
- Metadata with hidden functional side effects (violates Least Astonishment)
- Consumers storing sensitive data (PII, credentials) in metadata without encryption or access controls
- No plan for promoting common metadata patterns to first-class fields

---

## Common Gaps to Flag

- No metadata/extension point on API objects (rigid schema, no room to grow without versioning)
- No guidance for consumers on handling unknown response fields
- Enum fields documented as exhaustive with no plan for adding values
- Response shape changes treated casually (no additive-only policy)

## References

See `sources.md` for all source references and further reading.
