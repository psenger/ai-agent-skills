---
type: article
title: "Understanding Circuit Breaker Patterns"
author: "Philip A Senger"
category: "Software Architecture"
tags:
  - circuit-breaker
  - resilience
  - distributed-systems
  - fault-tolerance
description: "Overview of the circuit breaker pattern for fault-tolerant distributed systems"
summary: >
  Explains the circuit breaker pattern, its three states, and when to apply it
  to prevent cascading failures in distributed architectures.
status: published
date_created: 2026-03-10
date_updated: 2026-03-14
---

# Understanding Circuit Breaker Patterns

A circuit breaker wraps remote calls and monitors failures. When failures exceed a threshold, the breaker **trips open** and fails fast — preventing cascading failures.

## How It Works

| State | Behaviour |
|---|---|
| **Closed** | Requests pass through. Failures are counted. |
| **Open** | Requests fail immediately. No remote call made. |
| **Half-Open** | A limited number of test requests pass through to check recovery. |

## Practical Example

```python
breaker = CircuitBreaker(failure_threshold=5, recovery_timeout=30)

@breaker
def call_payment_service(order_id):
    return requests.post(f"{PAYMENT_URL}/charge", json={"order_id": order_id})
```

> [!WARNING]
> **Set realistic timeouts.** A circuit breaker without a request timeout just moves the bottleneck — the breaker stays closed while requests hang.

## Further Reading & References

| Resource | Link |
|---|---|
| Martin Fowler — Circuit Breaker | [martinfowler.com/bliki/CircuitBreaker](https://martinfowler.com/bliki/CircuitBreaker.html) |

> [!abstract] TL;DR
> Circuit breakers prevent cascading failures by failing fast when a downstream service is unhealthy. Three states: closed, open, half-open.
