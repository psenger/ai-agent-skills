---
type: article
title: "Idempotency in API Design"
author: "Philip A Senger"
category: "Software Engineering"
tags:
  - idempotency
  - api-design
  - rest
  - distributed-systems
description: "Why idempotency matters in API design and how to implement it"
summary: >
  Covers idempotency keys, safe HTTP methods, and practical implementation
  patterns for reliable APIs.
status: published
date_created: 2026-03-12
date_updated: 2026-03-14
source: "https://www.youtube.com/watch?v=example123"
---

# Idempotency in API Design

An operation is **idempotent** if performing it multiple times produces the same result as performing it once.

## How It Works

| HTTP Method | Idempotent? | Notes |
|---|---|---|
| `GET` | Yes | Read-only |
| `PUT` | Yes | Full replace |
| `DELETE` | Yes | Delete once or many times — same result |
| `POST` | **No** | Use idempotency keys to make it safe |

## Practical Example

```bash
curl -X POST /api/payments \
  -H "Idempotency-Key: abc-123" \
  -d '{"amount": 50}'
```

> [!WARNING]
> **Always use idempotency keys for `POST` requests** that create resources or trigger side effects. Without them, retries cause duplicates.

## Further Reading & References

| Resource | Link |
|---|---|
| Stripe — Idempotent Requests | [stripe.com/docs/api/idempotent_requests](https://stripe.com/docs/api/idempotent_requests) |

> [!abstract] TL;DR
> Make non-idempotent operations safe with idempotency keys. `GET`, `PUT`, `DELETE` are naturally idempotent. `POST` needs explicit handling.

---

## Transcript

Transcript from: [Idempotency in API Design — Tech Talk](https://www.youtube.com/watch?v=example123)
Date of material: 2026-03-10

```
So idempotency — it simply means doing something twice has the same
effect as doing it once. GET is naturally idempotent. PUT replaces the
whole resource, so doing it twice gives the same result. DELETE — same
thing, deleting something that's already gone is fine.

The tricky one is POST. POST creates things. If the client retries, you
get duplicates. The fix is idempotency keys. The client sends a unique
key, the server checks if it has seen that key before, and if so returns
the original response instead of creating a duplicate.

Stripe does this really well. Every POST to their API accepts an
Idempotency-Key header. Store the key, store the response, return it
on retry. Simple.
```
