# Handoff Schema v2.0.0

## Full Schema

```json
{
  "schema_version": "2.0.0",
  "generated_at": "<ISO 8601 UTC timestamp>",
  "task": {
    "goal": "<one sentence — plain English, no jargon>",
    "acceptance_criteria": [
      "<testable criterion 1>",
      "<testable criterion 2>"
    ]
  },
  "current_state": "<one paragraph describing where things stand right now>",
  "completed_steps": [
    "<past tense, verifiably done>"
  ],
  "pending_steps": [
    "<imperative, ordered by priority — first item is the next action>"
  ],
  "constraints": [
    "<hard limit that must not be violated>"
  ],
  "discovered_issues": [
    "<known unfixed problem — include file path and symptom when known>"
  ],
  "modified_files": [
    {
      "path": "<repo-relative path>",
      "status": "<created | modified | deleted>",
      "note": "<one-line description of what changed>"
    }
  ],
  "decisions": [
    {
      "decision": "<what was decided>",
      "rationale": "<why>",
      "alternatives_rejected": ["<option A>", "<option B>"]
    }
  ],
  "resume_prompt": "<ready-to-paste prompt for the new session — reference the handoff file by name>"
}
```

## Field Rules

| Field | Rules |
|---|---|
| `schema_version` | Always `"2.0.0"` |
| `generated_at` | ISO 8601 UTC, e.g. `"2026-04-23T14:32:00Z"` |
| `task.goal` | One sentence. Plain English, no jargon. |
| `task.acceptance_criteria` | At least one entry. Must be testable/verifiable. |
| `completed_steps` | Past tense. Only steps that are verifiably done. |
| `pending_steps` | Imperative. Ordered by priority. First item = next action. |
| `constraints` | Hard limits — things that must not be violated. |
| `discovered_issues` | Known unfixed problems. Include file paths when known. |
| `modified_files` | Every file the session touched. Use repo-relative paths. |
| `modified_files[].status` | One of: `created` · `modified` · `deleted` |
| `decisions` | Architectural/design choices — always include rationale. |
| `resume_prompt` | Complete, ready-to-use prompt. Must name the handoff file. |

## Example

```json
{
  "schema_version": "2.0.0",
  "generated_at": "2026-04-23T14:32:00Z",
  "task": {
    "goal": "Refactor auth middleware to store tokens in httpOnly cookies instead of localStorage",
    "acceptance_criteria": [
      "All token read/write operations go through TokenService",
      "No token values are written to localStorage or sessionStorage",
      "Existing /login and /refresh API contracts are unchanged",
      "All existing auth tests pass"
    ]
  },
  "current_state": "TokenService class created and JWT validation logic migrated. Unit tests for TokenService pass. SessionStore and the legacy /login route still reference the old token helpers directly.",
  "completed_steps": [
    "Created src/auth/token-service.ts with full token lifecycle methods",
    "Migrated JWT validation from auth-middleware.ts into TokenService",
    "Updated unit tests for TokenService — all passing"
  ],
  "pending_steps": [
    "Update SessionStore to call TokenService instead of token helpers",
    "Update legacy /login route to use TokenService",
    "Write integration test for full auth flow end-to-end",
    "Delete deprecated token helper functions"
  ],
  "constraints": [
    "Must not break existing /login and /refresh API contracts",
    "All tokens must be set as httpOnly, Secure, SameSite=Strict cookies",
    "Session TTL is 15 minutes — must be enforced in TokenService, not middleware"
  ],
  "discovered_issues": [
    "src/auth/token-service.ts — TokenService.validate() has an off-by-one on expiry check (expiresAt <= now instead of < now)",
    "src/routes/login.ts — still bypasses TokenService entirely, must be updated"
  ],
  "modified_files": [
    {
      "path": "src/auth/token-service.ts",
      "status": "created",
      "note": "New — JWT validation + cookie management. Off-by-one on expiry (pending fix)."
    },
    {
      "path": "src/auth/auth-middleware.ts",
      "status": "modified",
      "note": "JWT validation removed; now delegates to TokenService.validate()"
    },
    {
      "path": "tests/auth/token-service.test.ts",
      "status": "created",
      "note": "Unit tests for TokenService — all passing"
    }
  ],
  "decisions": [
    {
      "decision": "Use httpOnly cookies for all token storage",
      "rationale": "Legal/compliance requirement — session tokens must not be accessible via JavaScript",
      "alternatives_rejected": ["localStorage", "sessionStorage", "in-memory store"]
    },
    {
      "decision": "Centralise all token logic in TokenService",
      "rationale": "Removes scattered token handling from middleware and routes; single place to enforce cookie policy",
      "alternatives_rejected": ["Patch each route individually"]
    }
  ],
  "resume_prompt": "Load context-handoff.json. Continue the auth middleware refactor. Next step: update SessionStore (src/auth/session-store.ts) to call TokenService instead of the legacy token helpers. Also fix the off-by-one on TokenService.validate() expiry check before proceeding."
}
```