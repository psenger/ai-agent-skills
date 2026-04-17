# API Design Review: Payments API (OpenAPI 3.0.3)

## Overall Assessment

The spec defines a minimal payments API with two endpoints. While it captures the basic intent, there are significant gaps in resource modeling, error handling, security, and adherence to REST/API design best practices. Below is a detailed review organized by category.

---

## 1. Resource & Data Modeling

### 1.1 `amount` should not be `integer`

**Severity: High**

Using `type: integer` for a monetary amount is problematic. Currency amounts frequently include fractional units (e.g., $19.99). Two common approaches:

- Use `type: string` with a pattern constraint (e.g., `"19.99"`) to avoid floating-point precision issues.
- Use `type: integer` but explicitly document that the value is in the smallest currency unit (e.g., cents), so `1999` means $19.99. This is the Stripe convention.

The spec should clearly document which convention is used. If the intent is minor units, add a `description` stating so.

### 1.2 `currency` lacks validation

**Severity: High**

The `currency` field is an unconstrained `type: string`. It should be restricted to a well-known set of values:

- Add `minLength: 3` and `maxLength: 3` with a `pattern: "^[A-Z]{3}$"` to enforce ISO 4217 codes.
- Alternatively, use an `enum` listing supported currencies.
- Add an `example` value (e.g., `"USD"`).

### 1.3 `id` path parameter should be `string`, not `integer`

**Severity: Medium**

Using `type: integer` for resource IDs couples the API contract to an internal database implementation detail. Best practice is to use `type: string` (with `format: uuid` if UUIDs are used). This gives flexibility to change ID generation strategies without breaking clients.

### 1.4 No response body schemas defined

**Severity: High**

Neither the `201` nor the `200` response includes a response body schema. Clients have no contract for what they will receive. At minimum, define:

- **POST 201 response**: Return the created payment resource including `id`, `amount`, `currency`, `status`, and `created_at`.
- **GET 200 response**: Return the full payment resource.

Consider defining a reusable `Payment` schema under `components/schemas`.

### 1.5 Missing `additionalProperties: false`

**Severity: Low**

The request body schema does not set `additionalProperties: false`. Without this, clients can send arbitrary extra fields that may be silently ignored or cause unexpected behavior.

---

## 2. Error Handling

### 2.1 No error responses defined

**Severity: High**

The spec only defines success responses. A production API must document error cases:

| Endpoint | Missing Responses |
|---|---|
| `POST /v1/payments` | `400` (validation error), `401` (unauthorized), `403` (forbidden), `409` (duplicate/idempotency conflict), `422` (unprocessable entity), `500` (server error) |
| `GET /v1/payments/{id}` | `401`, `403`, `404` (not found), `500` |

### 2.2 No standard error schema

**Severity: High**

Define a reusable error response schema (e.g., under `components/schemas/Error`) with fields like `code`, `message`, and optionally `details` for field-level validation errors. This enables clients to build consistent error-handling logic.

---

## 3. Security

### 3.1 No security scheme defined

**Severity: Critical**

A payments API with no authentication or authorization is a serious omission. The spec should include:

- A `components/securitySchemes` section defining the auth mechanism (e.g., Bearer token, OAuth2, API key).
- A global or per-operation `security` requirement.

### 3.2 No idempotency support on POST

**Severity: High**

Payment creation must be idempotent to prevent double charges. The standard approach is to accept an `Idempotency-Key` request header. Define this as a parameter on the POST operation.

---

## 4. Pagination & Filtering

### 4.1 No list endpoint

**Severity: Medium**

There is no `GET /v1/payments` endpoint to list or search payments. Most APIs need this. If added, it should support:

- Cursor-based or offset pagination (`limit`, `starting_after` or `page`).
- Filtering by `status`, `created_at` date range, etc.
- A defined response envelope (e.g., `{ "data": [...], "has_more": true }`).

---

## 5. Spec Hygiene & Best Practices

### 5.1 No `operationId` on operations

**Severity: Medium**

Each operation should have a unique `operationId` (e.g., `createPayment`, `getPayment`). This is required for reliable SDK generation and is considered a best practice.

### 5.2 No `tags` for grouping

**Severity: Low**

Adding `tags: [Payments]` to each operation improves documentation organization in tools like Swagger UI or Redoc.

### 5.3 No `description` on the API or operations

**Severity: Low**

The top-level `info` block lacks a `description`. Individual operations only have `summary` but no `description`. Adding descriptions improves developer experience.

### 5.4 No `components/schemas` reuse

**Severity: Medium**

The request body schema is defined inline. Extract it to `components/schemas/CreatePaymentRequest` and define a `Payment` response schema. This promotes reuse and makes the spec easier to maintain.

### 5.5 No `servers` block

**Severity: Low**

The spec does not define a `servers` section. Adding at least one server URL (even a placeholder like `https://api.example.com`) helps tooling and documentation.

### 5.6 Missing content type on responses

**Severity: Medium**

The responses do not specify a `content` block with `application/json`. Without this, clients and code generators do not know the response format.

---

## 6. Recommended Revised Structure

Below is a high-level outline of what a more complete spec would include:

```
components:
  securitySchemes:
    BearerAuth:
      type: http
      scheme: bearer

  schemas:
    Payment:
      type: object
      properties:
        id: { type: string, format: uuid }
        amount: { type: integer, description: "Amount in smallest currency unit (e.g., cents)" }
        currency: { type: string, pattern: "^[A-Z]{3}$", example: "USD" }
        status: { type: string, enum: [pending, succeeded, failed] }
        created_at: { type: string, format: date-time }

    CreatePaymentRequest:
      type: object
      required: [amount, currency]
      additionalProperties: false
      properties:
        amount: { type: integer, description: "Amount in smallest currency unit" }
        currency: { type: string, pattern: "^[A-Z]{3}$" }

    Error:
      type: object
      properties:
        code: { type: string }
        message: { type: string }

security:
  - BearerAuth: []
```

---

## Summary of Findings

| Severity | Count | Key Issues |
|----------|-------|------------|
| Critical | 1 | No security/authentication |
| High | 5 | No response schemas, no error responses, no error schema, no idempotency, weak currency/amount typing |
| Medium | 4 | Integer ID, no list endpoint, no operationId, no schema reuse, no response content type |
| Low | 4 | No additionalProperties constraint, no tags, no descriptions, no servers block |

The spec needs substantial work before it is production-ready. The most urgent items are adding authentication, defining response and error schemas, and tightening the data model for monetary values.
