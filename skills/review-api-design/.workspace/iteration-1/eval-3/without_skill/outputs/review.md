# API Design Review: Mobile Fitness App

## Context

You are building an API for a mobile fitness app with three core domains: workout tracking, social following, and a social feed. You expect 10k DAU growing to 100k. Below is a comprehensive set of considerations organized by topic.

---

## 1. Resource Modeling and URL Structure

Design your API around clear, noun-based resources. A suggested resource hierarchy:

```
/users/{userId}
/users/{userId}/workouts
/users/{userId}/workouts/{workoutId}
/users/{userId}/followers
/users/{userId}/following
/users/{userId}/feed
```

**Key recommendations:**

- Use plural nouns for collections (`/workouts`, not `/workout`).
- Nest resources only one level deep. Avoid deep nesting like `/users/{id}/workouts/{id}/exercises/{id}/sets/{id}`. Instead, promote deeply nested resources to top-level when they need to be independently addressable: `/exercises/{exerciseId}`, `/sets/{setId}`.
- Use UUIDs or opaque string identifiers rather than sequential integers. Sequential IDs leak information (total user count, workout volume) and are enumerable by attackers.
- Keep URLs lowercase with hyphens for multi-word segments: `/workout-templates`, not `/workoutTemplates`.

---

## 2. Authentication and Authorization

- Use **OAuth 2.0 with short-lived JWTs** (15-minute access tokens) and longer-lived refresh tokens (30-90 days). Mobile apps need seamless token refresh without forcing re-login.
- Store refresh tokens server-side so you can revoke them (e.g., when a user changes their password or reports a stolen device).
- Implement **scope-based authorization**. Example scopes: `workouts:read`, `workouts:write`, `social:read`, `social:write`, `profile:read`, `profile:write`.
- For the social feed and follow system, enforce that users can only see content from public profiles or users they follow. This is business-logic authorization, not just token validation -- apply it at the service layer.
- Consider supporting **Sign in with Apple** and **Google Sign-In** as primary auth flows since this is a mobile app.

---

## 3. Workout Tracking API Design

### Creating Workouts

Workouts are complex objects (exercises, sets, reps, weights, duration, GPS routes, heart rate data). Handle this carefully:

```json
POST /users/{userId}/workouts
{
  "type": "strength",
  "startedAt": "2026-03-22T08:00:00Z",
  "completedAt": "2026-03-22T08:45:00Z",
  "exercises": [
    {
      "exerciseId": "ex_deadlift",
      "sets": [
        { "reps": 5, "weightKg": 100, "restSeconds": 120 }
      ]
    }
  ],
  "notes": "Felt strong today"
}
```

**Considerations:**

- **Offline-first design**: Mobile fitness apps are frequently used in gyms with poor connectivity. Support client-generated IDs (UUIDs) and idempotent creation via `Idempotency-Key` headers or PUT-based creation (`PUT /workouts/{client-generated-id}`). This prevents duplicate workouts when the client retries.
- **Partial sync**: Allow workouts to be created in a "draft" or "in-progress" state and completed later. This supports the use case where a user starts logging mid-workout.
- **Units**: Store all measurements in metric internally. Accept a `unitSystem` preference on the user profile and handle conversion at the API layer or client layer -- just be consistent. Always document which unit the API expects and returns.

### Querying Workouts

```
GET /users/{userId}/workouts?startDate=2026-03-01&endDate=2026-03-22&type=strength
```

- Support date range filters, workout type filters, and cursor-based pagination (see Section 6).
- Return summary data in list endpoints and full detail in single-resource endpoints to reduce payload sizes on the feed.

---

## 4. Social Graph (Follow System)

```
POST   /users/{userId}/following       # Follow a user (body: { "targetUserId": "..." })
DELETE /users/{userId}/following/{targetUserId}  # Unfollow
GET    /users/{userId}/followers        # List followers
GET    /users/{userId}/following        # List following
```

**Considerations:**

- **Asymmetric follow model** (like Twitter/Instagram) is simpler than mutual friendship and fits fitness apps well. Users follow others for motivation without requiring acceptance.
- Return follower/following **counts** as fields on the user profile resource to avoid requiring separate count queries:
  ```json
  {
    "id": "usr_abc123",
    "username": "runner_jane",
    "followerCount": 342,
    "followingCount": 128,
    "isFollowedByMe": true
  }
  ```
- The `isFollowedByMe` field is contextual (depends on the authenticated user). This avoids N+1 client requests to check follow status when rendering a list of users.
- **Rate limit follow/unfollow actions** aggressively to prevent spam-following (e.g., 50 follows per hour).

---

## 5. Social Feed

The feed is the most architecturally challenging feature. At 10k DAU it is manageable; at 100k DAU it requires planning now.

### Two Approaches

| Approach | How it works | Tradeoffs |
|---|---|---|
| **Fan-out on read (pull)** | When a user requests their feed, query all followed users' recent workouts, merge, and sort. | Simple to implement. Scales poorly as follow counts grow. Works fine at 10k DAU. |
| **Fan-out on write (push)** | When a user posts a workout, write it to all followers' feed inboxes. | More complex. Scales better for reads. "Celebrity problem" (users with many followers) requires special handling. |

**Recommendation for your scale**: Start with fan-out on read. At 10k DAU with reasonable follow counts (say, average 50-100 follows per user), a well-indexed database query is fast enough. Prepare to migrate to fan-out on write or a hybrid approach as you approach 100k DAU.

### Feed Endpoint

```
GET /users/{userId}/feed?cursor={opaque_cursor}&limit=20
```

Response:

```json
{
  "data": [
    {
      "id": "fi_abc123",
      "type": "workout_completed",
      "actor": { "id": "usr_xyz", "username": "runner_jane", "avatarUrl": "..." },
      "workout": {
        "id": "wk_def456",
        "type": "run",
        "summary": "5.2 km in 28:03",
        "completedAt": "2026-03-22T07:30:00Z"
      },
      "stats": { "likeCount": 12, "commentCount": 3, "isLikedByMe": false },
      "createdAt": "2026-03-22T07:31:00Z"
    }
  ],
  "pagination": {
    "nextCursor": "eyJ0IjoiMjAyNi0wMy0yMlQwNzozMTowMFoiLCJpIjoiZmlfYWJjMTIzIn0=",
    "hasMore": true
  }
}
```

**Key points:**

- Embed enough data in the feed item to render it without additional API calls. Include actor info, workout summary, and engagement counts inline.
- Use **cursor-based pagination** (not offset-based) because feed items are constantly being added. Offset pagination leads to duplicates or missed items.
- The cursor should be opaque to clients (base64-encoded composite of timestamp + ID for stable ordering).

---

## 6. Pagination Strategy

Use **cursor-based pagination** across all list endpoints, not just the feed.

```
GET /users/{userId}/workouts?cursor=abc123&limit=20

Response:
{
  "data": [...],
  "pagination": {
    "nextCursor": "def456",
    "hasMore": true
  }
}
```

**Why not offset-based?**
- Offset pagination breaks when new items are inserted (user sees duplicates or skips items).
- Offset pagination degrades in performance at high offsets (`OFFSET 10000` is slow in most databases).
- Cursor-based pagination gives stable, performant results regardless of dataset size.

Default `limit` to 20, cap at 100. Document these limits.

---

## 7. Rate Limiting and Throttling

At 10k-100k DAU, you need rate limiting from day one.

- **Per-user rate limits**: 100-200 requests per minute for normal endpoints, lower for write-heavy endpoints.
- **Use standard headers** to communicate limits:
  ```
  X-RateLimit-Limit: 100
  X-RateLimit-Remaining: 67
  X-RateLimit-Reset: 1679500800
  ```
- Return `429 Too Many Requests` with a `Retry-After` header when exceeded.
- Implement **sliding window** rate limiting (not fixed window) to prevent burst abuse at window boundaries.
- Consider separate tiers: unauthenticated requests get very low limits, authenticated users get standard limits.

---

## 8. Caching Strategy

- **Feed**: Cache aggressively with short TTLs (30-60 seconds). Users expect near-real-time but not instant. Use `Cache-Control: private, max-age=30`.
- **User profiles**: Cache with moderate TTLs (5 minutes). Use `ETag` headers for conditional requests.
- **Workout detail**: Cache with longer TTLs (workouts are immutable once completed). `Cache-Control: private, max-age=3600`.
- **Follower counts**: These are eventually consistent anyway. Cache for 1-5 minutes.
- Use `304 Not Modified` responses for conditional requests to save bandwidth on mobile networks.
- Consider a CDN for static assets (avatar images, exercise illustrations) from day one.

---

## 9. Versioning

- Use **URL-based versioning**: `/v1/users/{id}/workouts`. It is explicit, easy to route, and well-understood by mobile developers.
- Alternatively, use a custom header (`API-Version: 2026-03-22` date-based) if you prefer evolution over revolution. This works well for gradual rollouts.
- **Do not break existing versions.** Mobile apps have long update tails -- users may be running app versions months old. You must support old API versions for at least 6-12 months after deprecation.
- Communicate deprecation via response headers: `Deprecation: true`, `Sunset: Sat, 22 Mar 2027 00:00:00 GMT`.

---

## 10. Error Handling

Use a consistent error response structure across all endpoints:

```json
{
  "error": {
    "code": "WORKOUT_NOT_FOUND",
    "message": "The requested workout does not exist.",
    "details": [
      {
        "field": "workoutId",
        "reason": "No workout with ID wk_invalid exists for this user."
      }
    ],
    "requestId": "req_abc123"
  }
}
```

**Rules:**

- Always return a machine-readable `code` (not just HTTP status). Clients switch on these codes, not on message strings.
- Include a `requestId` for support and debugging. Log it server-side with the full request context.
- Use appropriate HTTP status codes: 400 for validation errors, 401 for missing/invalid auth, 403 for insufficient permissions, 404 for not found, 409 for conflicts (e.g., already following this user), 422 for semantically invalid input, 429 for rate limits, 500 for server errors.
- Never expose stack traces or internal details in production error responses.

---

## 11. Data Validation and Input Safety

- Validate all inputs server-side. Never trust the client.
- Set maximum lengths on text fields (workout notes: 500 chars, usernames: 30 chars).
- Validate that timestamps are not in the far future (prevent users from logging a workout next month).
- Sanitize any user-generated text that will be displayed to other users (workout notes, comments on the feed) to prevent stored XSS if you ever build a web client.
- Reject unknown fields in request bodies (strict parsing) to catch client bugs early.

---

## 12. Scalability Concerns (10k to 100k DAU)

### Database

- **Start with PostgreSQL.** It handles relational data (users, follows, workouts) well and scales to your target range easily with proper indexing.
- Index the follow graph: composite index on `(follower_id, followed_id)` and `(followed_id, follower_id)`.
- Index workouts by `(user_id, completed_at DESC)` for efficient feed queries.
- At 100k DAU, consider **read replicas** for feed queries and reporting, keeping writes on the primary.

### Feed at Scale

- At 100k DAU with fan-out-on-read, expect feed generation queries to hit ~50-100ms if well-indexed. This is acceptable.
- If feed latency grows, introduce a **materialized feed** (Redis sorted sets keyed by user ID, scored by timestamp). This is the hybrid approach -- fan-out on write into Redis, fall back to database for older items.
- Precompute feed items asynchronously using a background job queue (e.g., Sidekiq, Celery, Bull).

### API Infrastructure

- Deploy behind a **load balancer** with health checks.
- Use **connection pooling** for database connections (PgBouncer or application-level pooling).
- At 100k DAU, expect ~50-200 requests/second sustained, with spikes (morning workouts, evening workouts). Ensure your infrastructure handles 3-5x your average load for spikes.

---

## 13. Mobile-Specific Considerations

- **Minimize round trips.** Mobile networks have high latency. Design endpoints to return everything needed to render a screen in one call. For the feed, embed actor info and workout summaries inline rather than requiring separate lookups.
- **Support partial responses** if payloads get large: `GET /workouts/{id}?fields=id,type,summary,completedAt`.
- **Compression**: Require `Accept-Encoding: gzip` and compress all responses. JSON compresses well (often 70-80% reduction).
- **Idempotency**: Mobile networks drop connections. Every write operation should be idempotent or guarded by an idempotency key.
- **Background sync**: Provide a `GET /users/{userId}/workouts?updatedSince=2026-03-21T00:00:00Z` endpoint for efficient background sync of workout data.

---

## 14. Real-Time Features

For a social fitness app, consider whether you need real-time updates:

- **Live workout tracking** (showing a friend is currently running): Use **WebSockets** or **Server-Sent Events (SSE)**. SSE is simpler and sufficient for one-way updates (server to client).
- **Feed updates**: Polling every 30-60 seconds is fine at your scale. Real-time feed via WebSocket is a nice-to-have, not essential initially.
- **Push notifications** (someone liked your workout, a friend completed a run): Handle these server-side via APNs/FCM. Decouple notification generation from API request handling using a message queue.

---

## 15. Privacy and Compliance

- Allow users to set profiles as **public or private**. Private profiles' workouts should not appear in non-followers' feeds.
- Provide a `DELETE /users/{userId}` endpoint (or account deletion flow) for GDPR/CCPA compliance. This must cascade to workouts, feed items, follow relationships, and any cached data. Apple and Google both require account deletion capability for app store approval.
- Allow users to control what is shared: some users may want to log workouts without broadcasting to the feed.
- Location data (GPS routes for runs) is sensitive. Let users strip or generalize location data before sharing.
- Log access to personal data for audit purposes.

---

## 16. Monitoring and Observability

Instrument from day one:

- **Request logging**: Log method, path, status code, latency, user ID, request ID for every request.
- **Key metrics**: p50/p95/p99 latency per endpoint, error rate, requests per second, active users.
- **Alerting**: Alert on error rate spikes (>1% 5xx), latency spikes (p95 > 500ms), and authentication failure spikes (brute force detection).
- **Distributed tracing**: Use OpenTelemetry or similar. When a feed request is slow, you need to know whether it was the database, a downstream service, or serialization.
- **Health check endpoint**: `GET /health` returning service status, database connectivity, and dependency health.

---

## 17. API Documentation

- Use **OpenAPI 3.1** to document your API. Generate it from code or write it spec-first.
- Include request/response examples for every endpoint.
- Document error codes and their meanings.
- Provide a changelog for each API version.
- If your mobile team is separate from the backend team, treat the API spec as a contract and review changes together before implementation.

---

## Summary: Priority Order for Implementation

| Priority | Item | Why |
|----------|------|-----|
| 1 | Auth (OAuth 2.0 + JWT) | Nothing works without it |
| 2 | User profiles and workout CRUD | Core value proposition |
| 3 | Consistent error handling | Reduces debugging pain from day one |
| 4 | Idempotency for writes | Mobile networks are unreliable |
| 5 | Follow system | Enables social features |
| 6 | Feed (fan-out on read) | Social engagement driver |
| 7 | Cursor-based pagination | Correct UX for lists and feed |
| 8 | Rate limiting | Protects your infrastructure |
| 9 | Caching | Performance at scale |
| 10 | Real-time features | Polish and engagement |

Start simple, measure everything, and evolve the architecture based on real usage data rather than anticipated bottlenecks.
