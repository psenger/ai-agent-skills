# API Design Review: E-Commerce Platform

## Endpoints Under Review

```
POST   /users
GET    /users/{id}
PUT    /users/{id}
DELETE /users/{id}
GET    /orders
POST   /orders
GET    /orders/{id}
```

**Stack:** Express + PostgreSQL

---

## 1. Missing Endpoints

### Users collection listing
There is no `GET /users` endpoint. Even if public listing is not needed, an admin-facing list/search endpoint is typically required for an e-commerce platform. Consider adding it with appropriate authorization and pagination.

### Order lifecycle operations
- **`PUT /orders/{id}` or `PATCH /orders/{id}`** — There is no way to update an order (e.g., update shipping address before fulfillment, change order status).
- **`DELETE /orders/{id}`** — There is no way to cancel an order. Depending on business rules, this could be a `DELETE` or, more commonly, a status transition via `PATCH /orders/{id}` with `{ "status": "cancelled" }`.

### Relationship between users and orders
There is no way to retrieve orders for a specific user. Consider:
- `GET /users/{id}/orders` — nested resource approach, or
- `GET /orders?userId={id}` — query parameter filtering on the existing collection endpoint.

Both are valid; the query parameter approach is simpler and avoids deep nesting.

### Order items / line items
Orders in e-commerce almost always contain line items. Consider:
- `GET /orders/{id}/items`
- `POST /orders/{id}/items`
- `DELETE /orders/{id}/items/{itemId}`

Or embed items within the order resource payload if they are always read/written together.

---

## 2. REST Design Issues

### Use PATCH instead of (or alongside) PUT
`PUT` semantically means a full replacement of the resource. For partial updates (e.g., changing just an email address on a user profile), `PATCH` is more appropriate and reduces the risk of accidentally nullifying fields the client did not intend to change. Consider:
- Replace `PUT /users/{id}` with `PATCH /users/{id}`, or
- Support both, where `PUT` requires the full resource body and `PATCH` accepts partial updates.

### Pluralization and consistency
The endpoints use plural nouns consistently (`/users`, `/orders`), which is good. Maintain this pattern for any new resources.

### API versioning
There is no versioning scheme. For a production e-commerce API, add a version prefix:
```
/api/v1/users
/api/v1/orders
```
This allows non-breaking evolution and side-by-side deployment of API versions.

---

## 3. Pagination, Filtering, and Sorting

### GET /orders
A collection endpoint without pagination will become a serious performance problem as the order table grows. At minimum, support:
```
GET /orders?page=1&limit=20
GET /orders?offset=0&limit=20
```

Consider also:
- **Cursor-based pagination** (`?cursor=abc123&limit=20`) for better performance with large PostgreSQL tables, since `OFFSET`-based queries degrade as the offset increases.
- **Filtering:** `?status=shipped&createdAfter=2026-01-01`
- **Sorting:** `?sort=createdAt&order=desc`

### GET /users/{id} and GET /orders/{id}
For single-resource endpoints, consider supporting field selection to reduce payload size:
```
GET /users/{id}?fields=id,name,email
```

---

## 4. Security Considerations

### Authentication and authorization
The API design does not indicate any auth mechanism. For an e-commerce platform:
- All endpoints should require authentication (JWT or session-based).
- `DELETE /users/{id}` should be restricted to the user themselves or an admin.
- `GET /orders` should be scoped — regular users should only see their own orders; admins can see all.
- `POST /users` (registration) may be the only public endpoint.

### Rate limiting
Apply rate limiting especially to `POST /users` (to prevent account enumeration and abuse) and `POST /orders` (to prevent order flooding).

### Input validation
With Express and PostgreSQL, ensure:
- Use parameterized queries (e.g., via `pg` library's `$1` placeholders or an ORM like Knex/Prisma) to prevent SQL injection.
- Validate and sanitize all input at the route handler level (consider `express-validator` or `zod`).
- Reject unexpected fields in request bodies to prevent mass assignment vulnerabilities.

### Soft delete for users
`DELETE /users/{id}` in e-commerce should almost certainly be a soft delete (set a `deleted_at` timestamp) rather than a hard delete, because:
- Order history references the user.
- Regulatory requirements (tax records, audits) may require retaining user data.
- GDPR "right to erasure" can be handled by anonymizing PII while retaining the record.

---

## 5. Response Design

### Consistent response envelope
Adopt a consistent response structure:
```json
{
  "data": { ... },
  "meta": { "page": 1, "limit": 20, "total": 354 }
}
```
Or for errors:
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Email is required",
    "details": [ { "field": "email", "message": "must not be empty" } ]
  }
}
```

### HTTP status codes
Ensure correct status codes are used:
| Operation | Success Code | Notes |
|---|---|---|
| `POST /users` | `201 Created` | Return `Location` header with new resource URL |
| `GET /users/{id}` | `200 OK` | `404` if not found |
| `PATCH /users/{id}` | `200 OK` | Return the updated resource |
| `DELETE /users/{id}` | `204 No Content` | No body needed |
| `GET /orders` | `200 OK` | Always return an array, even if empty |
| `POST /orders` | `201 Created` | Return the created order with its ID |
| `GET /orders/{id}` | `200 OK` | `404` if not found |

### Idempotency
`POST /orders` should support an idempotency key (e.g., `Idempotency-Key` header) to prevent duplicate orders from network retries. This is critical for e-commerce where a duplicated order means real money.

---

## 6. Missing Resources for E-Commerce

A real e-commerce platform will almost certainly need these additional resources:

| Resource | Purpose |
|---|---|
| `/products` | Product catalog (CRUD) |
| `/cart` or `/users/{id}/cart` | Shopping cart management |
| `/payments` | Payment processing |
| `/addresses` | Shipping/billing addresses |
| `/categories` | Product categorization |
| `/reviews` | Product reviews and ratings |

These do not all need to exist at launch, but the current API covers only users and orders, which is insufficient for an e-commerce platform.

---

## 7. Express + PostgreSQL Implementation Notes

- **Use a connection pool** (`pg.Pool`) rather than creating a new connection per request.
- **Add database indexes** on `orders.user_id`, `orders.status`, and `orders.created_at` for the query patterns implied by this API.
- **Use transactions** for `POST /orders` since order creation typically involves multiple table writes (order, order_items, inventory updates, payment records).
- **Consider an ORM or query builder** (Prisma, Knex, or Drizzle) for type safety and migration management rather than raw SQL strings.

---

## Summary of Recommendations

| Priority | Recommendation |
|---|---|
| High | Add pagination to `GET /orders` |
| High | Add `GET /users/{id}/orders` or `GET /orders?userId={id}` |
| High | Add authentication and authorization |
| High | Support idempotency keys on `POST /orders` |
| High | Use soft delete for `DELETE /users/{id}` |
| Medium | Add `PATCH` support (partial updates) |
| Medium | Add API versioning (`/api/v1/...`) |
| Medium | Add order update/cancel capability |
| Medium | Standardize response envelope and error format |
| Low | Add field selection support |
| Low | Add `GET /users` with admin authorization |
| Low | Plan additional resources (products, cart, payments) |
