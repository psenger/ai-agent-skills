---
type: brainstorming
title: "Caching Strategy Options"
author: "Philip A Senger"
category: "Software Architecture"
tags:
  - brainstorming
  - caching
  - architecture
  - performance
description: "Exploring caching approaches for read-heavy API endpoints"
summary: >
  Evaluated cache-aside, write-through, and write-behind patterns.
  Converged on cache-aside with Redis for the read-heavy API layer.
status: published
date_created: 2026-03-14
date_updated: 2026-03-14
action_items:
  - "Prototype cache-aside with Redis for the top 3 endpoints"
  - "Define TTL policy per resource type"
---

# Caching Strategy Options

## Overview

API response times are climbing as data volume grows. Need a caching layer for read-heavy endpoints.

## Options Explored

| Pattern | Pros | Cons |
|---|---|---|
| **Cache-aside** | Simple, app controls cache | Cache misses hit DB |
| **Write-through** | Cache always fresh | Write latency increases |
| **Write-behind** | Fast writes | Risk of data loss on crash |

## Decision

> [!IMPORTANT]
> **Selected: Cache-aside with Redis.** Simplest to implement, and read-heavy workloads benefit most from explicit cache population.

## Action Items

- [ ] Prototype cache-aside with Redis for the top 3 endpoints
- [ ] Define TTL policy per resource type

> [!abstract] TL;DR
> Cache-aside with Redis chosen for read-heavy API endpoints. Simple, explicit, and sufficient for current scale.
