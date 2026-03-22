# Payloads & Errors — Design Review Checklist

Source: [Best Practices for REST API](https://github.com/psenger/Best-Practices-For-Rest-API) by Philip A Senger (CC BY 4.0)

---

How you structure requests and responses matters. Consistent payloads reduce integration friction. Good error messages reduce support burden.

## Table of Contents

1. [Response Structure](#response-structure)
2. [Field Selection](#field-selection)
3. [Pagination](#pagination)
4. [Error Format](#error-format)
5. [Identifiers](#identifiers)
6. [Content Negotiation](#content-negotiation)

---

## Response Structure

**Check for:**
- Is the response envelope strategy consistent?
  - **With envelope:** wrap responses in `{ "data": ..., "meta": { ... } }` — consistent, room for metadata
  - **Without envelope:** raw array/object with metadata in headers — cleaner, less nesting
- Is one approach chosen and applied everywhere? (don't mix)
- Are responses deterministic? (same input → same output)
- If using envelopes:
  - `data` is an array for collections, object for singles?
  - `meta` used for pagination metadata?
  - Errors use Problem Details (RFC 9457), not a custom `errors` field?

---

## Field Selection

Allow clients to request only the fields they need.

**Check for:**
- Is field selection supported for large payloads? (`?fields=firstName,email`)
- Is an additive approach used? (specify what to include, not what to exclude)
- Is the syntax documented?

---

## Pagination

Essential for any API returning collections.

### Approaches

| Approach | Best For |
|----------|----------|
| Offset-based | Simple admin interfaces, small datasets |
| Cursor-based | Infinite scroll, large datasets, real-time feeds |
| Link headers | Hypermedia clients, minimal payloads |

**Offset-based pagination:**
Drawbacks: `OFFSET 10000` is slow; insertions/deletions can skip/duplicate items.

**Cursor-based pagination:**
Better performance at depth, handles insertions/deletions gracefully.

**Link-based pagination (headers):**
```
X-Total-Count: 2340
Link: </users?page=1>; rel="prev", </users?page=3>; rel="next"
```

**Check for:**
- Is a pagination strategy defined?
- Does it match the use case? (cursor for large/real-time, offset for simple)
- Are pagination links included in responses? (`next`, `prev`, `first`, `last`)
- Is there a maximum page size? (prevent clients from requesting all records)
- Is the default page size reasonable? (20-50 typical)

---

## Error Format

### RFC 9457 — Problem Details

The standard for REST API error responses.

**Check for:**
- Is Problem Details (RFC 9457) used as the error format?
- Is `Content-Type: application/problem+json` returned for errors?
- Are standard fields used?

| Field | Type | Description |
|-------|------|-------------|
| `type` | URI | Identifies the problem type. Stable identifier, should never change. |
| `title` | string | Short, human-readable summary. |
| `status` | number | HTTP status code. |
| `detail` | string | Explanation specific to this occurrence. |
| `instance` | URI | Identifies this specific occurrence. |

### Validation Errors

- Do validation errors include structured details?
  - `field` — path to the problematic field (supports nested: `address.zipCode`)
  - `code` — machine-readable error code for programmatic handling
  - `message` — human-readable description

**Example:**
```json
{
  "type": "https://example.net/validation-error",
  "title": "Your request parameters didn't validate.",
  "status": 400,
  "errors": [
    { "field": "age", "code": "invalid_format", "message": "must be a positive integer" },
    { "field": "color", "code": "out_of_range", "message": "must be 'green', 'red', or 'blue'" }
  ]
}
```

### Error Security

- Are stack traces hidden in production?
- Are database error messages never exposed to clients?
- Are internal service names never revealed in errors?

---

## Identifiers

### UUIDs over Sequential IDs

| Sequential | UUID/Random |
|------------|-------------|
| Predictable, easy to enumerate | Random, no information leakage |
| Reveals record count | No business intelligence exposed |
| Collisions in distributed systems | Globally unique |

**Check for:**
- Are UUIDs or random strings used instead of sequential integers?
- Are IDs represented as strings in JSON? (prevents JavaScript precision issues with large integers — Twitter's tweet ID problem)

### Type-Prefixed IDs

Stripe/Slack pattern: `user_abc123`, `order_xyz789`, `txn_qrs456`

**Check for:**
- Are type-prefixed IDs used? Benefits:
  - Immediately identify entity type from any ID
  - Easier log searching and debugging
  - Prevents using an order ID where a user ID is expected
  - Works well with detached data (logs, error reports, exported JSON)

---

## Content Negotiation

- Are `Accept` and `Content-Type` headers used properly?
- Is JSON the default format?
- If multiple formats are supported (XML), is the structure consistent across formats?

---

## Common Gaps to Flag

- No error format defined ("we'll figure it out per endpoint")
- Custom error format instead of RFC 9457 Problem Details
- Sequential integer IDs (enumeration risk, distributed collision risk)
- No pagination strategy for list endpoints
- Stack traces or database errors exposed in responses
- IDs as numbers in JSON (JavaScript precision issues)
- No field selection for large payloads
- Mixing envelope and non-envelope response styles
- Validation errors without field/code/message structure

## References

See `sources.md` for all source references and further reading.
