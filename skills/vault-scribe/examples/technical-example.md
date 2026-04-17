---
type: technical
title: "Event Bus Architecture"
author: "Philip A Senger"
category: "Software Architecture"
tags:
  - event-bus
  - architecture
  - messaging
  - distributed-systems
  - pub-sub
description: "Design specification for the internal event bus used across platform services"
summary: >
  Documents the publish/subscribe architecture of the internal event bus,
  including topic conventions, consumer group patterns, and failure handling.
  Covers both the synchronous and asynchronous delivery paths.
status: published
version: "1.1.0"
date_created: 2026-01-20
date_updated: 2026-03-14
system: "Platform Core"
component: "Event Bus"
reviewers:
  - "Alice Johnson"
  - "Bob Chen"
next_reviewer:
  - "Carol Williams"
next_review_date: 2026-07-01
signoff:
  - name: "Alice Johnson"
    date: "2026-01-25"
  - name: "Bob Chen"
    date: "2026-01-26"
revision_notes:
  - "1.0.0 - Initial architecture specification"
  - "1.1.0 - Added dead-letter queue pattern and retry policy"
related: "[[platform-core-overview]]"
---

# Event Bus Architecture

The event bus is the internal pub/sub backbone used by all platform services. Producers publish typed events to named topics; consumers subscribe via consumer groups and process events independently.

## Overview

| Concept | Description |
|---|---|
| **Topic** | Named channel scoped to a domain, e.g. `orders.created` |
| **Producer** | Any service that emits events to a topic |
| **Consumer Group** | A set of service instances sharing a subscription cursor |
| **Dead-Letter Queue (DLQ)** | Receives events that fail processing after all retries |

## How It Works

```
Producer → Topic → [Consumer Group A]
                 → [Consumer Group B]
                 → [DLQ] (on repeated failure)
```

Each consumer group maintains its own cursor. Multiple groups can consume the same topic independently without interfering.

### Topic Naming Convention

```
<domain>.<entity>.<event>

orders.payment.captured
users.account.created
inventory.item.reserved
```

- All lowercase, dot-separated
- Domain first, then entity, then past-tense verb

## Delivery Guarantees

| Mode | Guarantee | When to use |
|---|---|---|
| `at-least-once` | Default. Events may be delivered more than once | Most use cases |
| `exactly-once` | Requires idempotent consumers + transactional producers | Financial events |

> [!IMPORTANT]
> Consumers **must** be idempotent. Duplicate delivery is possible under failure scenarios even in `at-least-once` mode.

## Retry and Failure Handling

```yaml
retry_policy:
  max_attempts: 5
  backoff: exponential
  initial_delay: 500ms
  max_delay: 30s
```

After `max_attempts`, the event is routed to the DLQ for the topic:

```
orders.payment.captured  →  dlq.orders.payment.captured
```

> [!WARNING]
> Monitor DLQ depth in your service dashboard. Unprocessed DLQ events indicate a persistent consumer failure that will not self-heal.

## Practical Example

**Publishing an event (Node.js):**

```typescript
await eventBus.publish("orders.payment.captured", {
  orderId: "ord_abc123",
  amount: 4999,
  currency: "USD",
  capturedAt: new Date().toISOString(),
});
```

**Consuming events:**

```typescript
eventBus.subscribe("orders.payment.captured", "fulfilment-service", async (event) => {
  await fulfilmentQueue.enqueue(event.payload.orderId);
});
```

## Schema Versioning

All event payloads are versioned. Breaking schema changes require a new topic name:

```
orders.payment.captured.v1   →  deprecated
orders.payment.captured.v2   →  current
```

> [!CAUTION]
> Never modify the schema of an active topic in a breaking way. Old consumers will silently fail to deserialise the payload.

## Further Reading & References

| Resource | Link |
|---|---|
| Platform Core Overview | `[[platform-core-overview]]` |
| Dead-Letter Queue Runbook | `[[dlq-runbook]]` |
| CloudEvents Spec | [cloudevents.io](https://cloudevents.io) |

> [!abstract] TL;DR
> The event bus uses named topics with consumer groups. Producers publish typed, versioned events. Consumers must be idempotent. Failed events go to per-topic DLQs after exponential backoff retries. Topic names follow `<domain>.<entity>.<past-tense-verb>` convention.