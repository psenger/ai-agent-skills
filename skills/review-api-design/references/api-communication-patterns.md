# API Communication Patterns — Design Review Checklist

Source: [Best Practices for REST API](https://github.com/psenger/Best-Practices-For-Rest-API) by Philip A Senger (CC BY 4.0)

---

When reviewing an API design, sometimes the right question isn't "is this a good REST API?" but "is REST the right pattern at all?" This reference helps evaluate REST, GraphQL, WebSockets, and Server-Sent Events — and when to combine them.

## Table of Contents

1. [Decision Drivers](#decision-drivers)
2. [REST](#rest)
3. [GraphQL](#graphql)
4. [WebSockets](#websockets)
5. [Server-Sent Events (SSE)](#server-sent-events-sse)
6. [Comparison Matrix](#comparison-matrix)
7. [When to Choose What](#when-to-choose-what)
8. [Hybrid Architectures](#hybrid-architectures)
9. [Anti-Patterns](#anti-patterns)
10. [Red Flags](#red-flags)

---

## Decision Drivers

Before reviewing specific endpoints, consider the broader communication pattern:

- Is data flow **unidirectional** (server → client) or **bidirectional** (both ways)?
- Is the data **request-response** (client asks, server answers) or **event-driven** (server pushes when something happens)?
- How critical is **real-time latency**? (milliseconds vs seconds vs acceptable polling interval)
- What are the **caching requirements**?
- What is the **client landscape**? (browsers, mobile, IoT, server-to-server)
- What is the **team's expertise**?
- What is the **infrastructure reality**? (load balancers, proxies, firewalls that may not support persistent connections)

---

## REST

REST uses HTTP methods and resource URLs. Each endpoint returns a fixed data structure.

**Strengths:**
- HTTP caching works out of the box (CDN, browser, proxy layers). Cache keys are just URLs.
- Predictable performance — each endpoint has known, testable characteristics.
- Mature tooling — monitoring, rate limiting, load balancing work without special configuration.
- Simple mental model — junior developers are productive quickly.
- Stateless by design.

**Weaknesses:**
- Over-fetching — endpoints return fixed shapes, clients may receive unneeded data.
- Under-fetching — complex views may require multiple round trips.
- Versioning overhead — breaking changes require new versions.
- Endpoint proliferation — many specialized endpoints as requirements grow.
- No server push — clients must poll for updates, which is inefficient for real-time data.

---

## GraphQL

GraphQL provides a query language that lets clients request exactly the data they need. Single endpoint, strongly typed schema.

**Strengths:**
- Client-specified queries reduce over-fetching.
- Single endpoint — simpler client configuration.
- Strong typing — self-documenting schema, excellent tooling.
- Reduced round trips for complex data requirements.
- Evolvable schema — adding fields doesn't break existing clients.
- **Subscriptions** — GraphQL has a built-in subscription model for real-time data over WebSockets.

**Weaknesses:**
- **N+1 query problem** — the most common performance killer. A query for users with orders can generate hundreds of database queries. DataLoader helps but adds complexity.
- **Unbounded query complexity** — clients can construct expensive queries that overwhelm the server. Requires query cost analysis, depth limiting, complexity scoring.
- **Caching is hard** — POST requests don't cache at HTTP layer. Requires application-level caching (Apollo Client, Relay) or persisted queries.
- **Monitoring is harder** — all requests hit one endpoint. Need GraphQL-aware tooling.
- **Partial success complexity** — some fields resolve while others error. Clients must handle this.
- **Performance problems are hidden** — REST exposes performance per endpoint; GraphQL hides it behind a flexible query interface.

---

## WebSockets

WebSockets (RFC 6455) provide a persistent, full-duplex communication channel over a single TCP connection. After an HTTP upgrade handshake, both client and server can send messages at any time.

**Strengths:**
- **Bidirectional** — both client and server can push messages at any time without request-response overhead.
- **Low latency** — no HTTP overhead per message after the initial handshake. Sub-millisecond delivery possible.
- **Real-time** — ideal for data that changes continuously and must be reflected immediately.
- **Efficient for high-frequency updates** — chat, gaming, collaborative editing, live trading, IoT telemetry.

**Weaknesses:**
- **Stateful connections** — each client holds an open connection. This complicates load balancing, scaling, and deployment (rolling restarts drop connections).
- **No HTTP caching** — messages bypass the HTTP caching layer entirely.
- **Firewall/proxy issues** — some corporate firewalls, proxies, and older load balancers don't handle WebSocket upgrades well.
- **Scaling complexity** — sticky sessions or a pub/sub backbone (Redis, NATS, Kafka) needed to fan out messages across server instances.
- **No built-in reconnection** — clients must implement reconnection logic with backoff. The server has no way to "replay" missed messages without additional infrastructure.
- **Harder to monitor and debug** — persistent connections don't produce the same access log patterns as HTTP. Need specialized tooling.
- **Security surface** — persistent connections can be used for slow-read DoS attacks, and each open connection consumes server resources.

**Check for:**
- Is there a reconnection strategy with exponential backoff?
- How are missed messages handled during disconnection? (message queue, sequence numbers, event replay)
- Is there a heartbeat/ping-pong mechanism to detect stale connections?
- How does the design handle horizontal scaling? (sticky sessions, pub/sub backbone)
- Is authentication handled at connection time AND periodically revalidated?
- Are connection limits defined per user/IP to prevent resource exhaustion?

---

## Server-Sent Events (SSE)

SSE (EventSource API) provides a unidirectional, server-to-client push channel over standard HTTP. The server sends a stream of events; the client listens.

**Strengths:**
- **Simple** — built on standard HTTP. Works through firewalls, proxies, and load balancers that support HTTP/1.1 or HTTP/2.
- **Auto-reconnection** — the browser's EventSource API automatically reconnects with `Last-Event-ID`, and the server can resume from where it left off. This is built into the spec, not bolted on.
- **HTTP/2 multiplexing** — multiple SSE streams can share a single TCP connection, eliminating the browser's 6-connection-per-domain limit that affects HTTP/1.1.
- **Text-based protocol** — easy to debug with standard HTTP tools (curl, browser dev tools).
- **Standard HTTP caching and auth** — cookies, headers, and existing auth infrastructure work as-is.
- **Efficient for server-push patterns** — notifications, live feeds, progress updates, real-time dashboards.

**Weaknesses:**
- **Unidirectional only** — server to client. The client cannot send data over the SSE connection (use REST/fetch for client-to-server).
- **Text only** — no binary data support (WebSockets support binary frames). Must base64-encode binary data, which adds overhead.
- **HTTP/1.1 connection limit** — browsers allow only ~6 connections per domain on HTTP/1.1. Each SSE stream uses one. This is resolved by HTTP/2 but may matter for legacy deployments.
- **No native mobile support** — the EventSource API is a browser standard. Mobile apps need a library or custom implementation.
- **Less ecosystem** — fewer libraries and frameworks compared to WebSockets.

**Check for:**
- Is the data flow truly unidirectional (server → client only)?
- Is `Last-Event-ID` used for resumption after reconnection?
- Is HTTP/2 available? (eliminates the connection limit issue)
- Are events structured with `id`, `event`, and `data` fields?
- Is there a keep-alive mechanism? (send comments `: keep-alive\n\n` to prevent proxy timeouts)

---

## Comparison Matrix

| Aspect | REST | GraphQL | WebSockets | SSE |
|--------|------|---------|------------|-----|
| **Direction** | Request-response | Request-response (+ subscriptions) | Bidirectional | Server → client |
| **Connection** | Stateless, new per request | Stateless (subscriptions are stateful) | Persistent, stateful | Persistent, stateful |
| **Caching** | Native HTTP caching | Application-level only | None | Standard HTTP |
| **Real-time** | Polling only | Via subscriptions | Native | Native |
| **Protocol** | HTTP | HTTP (subscriptions over WS) | WS (TCP after HTTP upgrade) | HTTP |
| **Binary data** | Yes (multipart) | No (base64) | Yes (binary frames) | No (text only) |
| **Firewall-friendly** | Yes | Yes | Sometimes problematic | Yes |
| **Browser support** | Universal | Via client libraries | Universal | Universal (EventSource) |
| **Scaling** | Stateless = easy | Stateless = easy (subscriptions hard) | Stateful = hard | Stateful but simpler than WS |
| **Reconnection** | N/A | N/A | Manual (client must implement) | Automatic (built into spec) |
| **Auth** | Per-request headers/cookies | Per-request headers/cookies | At handshake (revalidation needed) | Per-request headers/cookies |
| **Monitoring** | Standard HTTP tooling | Needs GraphQL-aware tools | Specialized tooling | Standard HTTP tooling |
| **Best for** | CRUD, public APIs, cacheable data | Complex queries, multi-client | Chat, gaming, collaboration | Notifications, feeds, dashboards |

---

## When to Choose What

### Choose REST when:
- Data is request-response (client asks, server answers)
- Caching is critical (CDN, browser cache)
- Data model maps naturally to resources
- Team is new to API development
- Predictable, optimizable performance is needed
- Public API with third-party consumers
- High-traffic endpoints with simple data shapes

### Choose GraphQL when:
- Multiple clients with different data needs (web, mobile, third-party)
- Rapid frontend iteration is prioritized over backend simplicity
- Data is highly interconnected (social graphs, content management)
- Team has expertise to implement correctly
- Willing to invest in tooling and monitoring
- Mobile clients where bandwidth matters significantly

### Choose WebSockets when:
- Communication must be **bidirectional** (both client and server initiate messages)
- **Sub-second latency** is required (chat, gaming, live collaboration, trading)
- **High-frequency** updates in both directions (collaborative editing, multiplayer)
- The client needs to send data unprompted (not just in response to user action)
- The team can handle stateful connection management, scaling, and reconnection

### Choose SSE when:
- Data flow is **server-to-client only** (notifications, live feeds, progress updates)
- You want **automatic reconnection** with event replay (built into the spec)
- You need **standard HTTP** compatibility (firewalls, proxies, auth, caching)
- The update frequency is moderate (not sub-millisecond; seconds to minutes is fine)
- You want simplicity — SSE is dramatically simpler to implement and operate than WebSockets

### Choose polling (REST) when:
- Updates are infrequent and latency tolerance is high (check every 30s-5min)
- Infrastructure doesn't support persistent connections
- Simplicity is paramount and the team has no real-time experience
- The cost of occasional stale data is acceptable

---

## Hybrid Architectures

Most production systems combine patterns. Common combinations:

**REST + SSE** — REST for CRUD operations, SSE for real-time notifications. The most common hybrid for web applications.
```
POST /orders          → REST (create order)
GET  /orders/{id}     → REST (read order)
GET  /orders/stream   → SSE  (live order status updates)
```

**REST + WebSockets** — REST for data operations, WebSockets for bidirectional real-time features (chat, collaboration).
```
GET  /messages        → REST (message history)
POST /messages        → REST (send message)
ws://api/chat         → WS   (real-time message delivery + typing indicators)
```

**REST + GraphQL** — REST for simple, high-traffic, cacheable endpoints. GraphQL for complex, client-specific queries.

**GraphQL + GraphQL Subscriptions** — GraphQL for queries/mutations, subscriptions (over WebSockets) for real-time updates. Apollo Server and Relay support this natively.

**Check for:**
- Is the hybrid justified? (don't add WebSockets for a feature that SSE handles fine)
- Is auth consistent across patterns? (REST auth via headers, WS auth at handshake — are they using the same identity provider and tokens?)
- Is there a clear boundary? (which operations go through which pattern, documented)
- Can the team operate multiple communication patterns? (monitoring, debugging, scaling for each)

---

## Anti-Patterns

### GraphQL over REST
Wrapping existing REST APIs with a GraphQL layer adds latency and complexity without solving the underlying data fetching problems.

### GraphQL as Database Proxy
Exposing database schema directly as GraphQL schema leads to security and performance issues. The GraphQL schema should reflect the domain model, not the database.

### Ignoring Query Complexity
Launching without query cost analysis is asking for production incidents. Malicious or naive clients will find expensive queries.

### Assuming GraphQL is Faster
GraphQL reduces over-fetching for clients but often increases server-side work. Network savings may not offset backend costs.

### WebSockets for Unidirectional Data
Using WebSockets when data only flows server-to-client. SSE is simpler, auto-reconnects, works through all proxies, and uses standard HTTP auth. WebSockets add complexity for no benefit in this case.

### WebSockets for Infrequent Updates
Using WebSockets (or SSE) for data that changes every few minutes. Polling with REST is simpler, stateless, and cacheable. Persistent connections have a cost — don't pay it for data that updates infrequently.

### Polling for Real-Time Data
Using REST polling every second for data that needs sub-second delivery. This wastes bandwidth, hits rate limits, and still delivers stale data. Use SSE or WebSockets.

### No Reconnection Strategy for WebSockets
Deploying WebSockets without client-side reconnection logic, backoff, and missed-message handling. Connections will drop (deployments, network blips, idle timeouts) — the client must handle this gracefully.

---

## Red Flags

### In a REST design suggesting another pattern might be better:
- Many endpoints that return the same data in slightly different shapes for different clients → GraphQL
- Clients consistently need to make 5+ requests to assemble a single view → GraphQL
- Frequent discussions about "should we add this field to this endpoint?" → GraphQL
- Client polling an endpoint every 1-5 seconds for updates → SSE
- Requirement for "live" or "real-time" updates in a REST-only design → SSE or WebSockets
- Requirement for server-initiated notifications → SSE

### In a GraphQL design suggesting REST might be better:
- All queries are simple resource lookups (no complex nesting)
- Caching is a primary concern
- The team has no GraphQL experience
- There's only one client consuming the API
- No plan for query cost analysis or depth limiting

### In a WebSocket design suggesting SSE might be better:
- Data flows server-to-client only (no client-initiated messages over the connection)
- The team is struggling with connection management, load balancing, or scaling
- Standard HTTP auth/caching/monitoring would simplify the architecture
- Update frequency is seconds-to-minutes, not sub-second

### In any design suggesting WebSockets are needed:
- Collaborative editing (multiple users editing simultaneously)
- Chat or messaging (bidirectional, low-latency)
- Live gaming (bidirectional, sub-millisecond)
- IoT device control (bidirectional command/telemetry)

---

## Key Principle

> For most API projects, REST remains the pragmatic default. Add SSE for server-push needs, WebSockets for bidirectional real-time, and GraphQL for complex multi-client query flexibility. The choice is about which trade-offs align with your constraints, not which technology is "better." Most production systems use a combination.

## References

See `sources.md` for all source references and further reading.
