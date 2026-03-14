# Git Commit & PR Message Examples

Reference examples for the git-commit-pr-message skill. These demonstrate
the expected output format and quality bar.

## Table of Contents

- [Commit Message Examples](#commit-message-examples)
- [PR Title Examples](#pr-title-examples)
- [PR Description Examples](#pr-description-examples)
- [Ticket Reference Formats](#ticket-reference-formats)
- [Changelog Examples](#changelog-examples)
- [Sensitive Content Patterns to Scan For](#sensitive-content-patterns-to-scan-for)

---

## Commit Message Examples

### Feature — with GitHub issue

```
feat(bridge): add configurable timeout with exponential backoff

Implement retry logic for the HTTP bridge between Node.js and Python
services. Timeouts are configurable via BRIDGE_TIMEOUT_MS env var.
Backoff uses a 2x multiplier with jitter to avoid thundering herd.

Closes #42
```

### Feature — with Jira ticket

```
feat(sse): add content negotiation for multiple MIME types

Node.js layer now negotiates response format based on the client's
Accept header. Supported formats: text/event-stream (SSE),
application/json, text/markdown, and text/plain.

CHAT-1234
```

### Bug fix — with GitHub issue

```
fix(agent): prevent duplicate tool calls in concurrent SSE streams

LangGraph agent was invoking the same MCP tool twice when multiple
SSE connections shared a session. Root cause: missing lock on the
tool-call deduplication map. Added asyncio.Lock scoped per session.

Fixes #87
```

### Bug fix — with Jira ticket

```
fix(redis): handle connection timeout during cache warmup

Redis adapter was throwing unhandled ConnectionError when Redis
was still starting during cache warmup. Added retry with 3 attempts
and 500ms delay before falling back to cold cache.

CHAT-456
```

### Refactor — no ticket

```
refactor(ports): extract IObservability from inline Pino calls

Moved all direct Pino logger calls behind the IObservability port
interface. This allows swapping observability providers without
touching business logic. No functional change.
```

### Test

```
test(e2e): add token streaming validation across bridge

Validates that LLM tokens flow correctly through the full pipeline:
Python agent -> HTTP bridge -> Node.js -> SSE -> client. Asserts
token order, correlation ID propagation, and graceful timeout.

Closes #23
```

### Docs

```
docs(readme): update architecture diagrams for hex ports layout

Replaced ASCII diagrams with properly aligned box-drawing characters.
Added content negotiation MIME type fan-out to streaming diagram.
```

### Chore

```
chore(deps): upgrade LangChain to 0.3.x and pin Pydantic 2.x

LangChain 0.3 drops Pydantic v1 support. Updated all schemas to
Pydantic v2 field validators. No breaking API changes.

CHAT-789
```

### Multi-scope change

```
feat(bridge,agent): add correlation ID propagation across services

Correlation IDs now generate at the Node.js edge (Express middleware)
and propagate through the HTTP bridge into the Python agent layer.
Both Pino and structlog include the correlation ID in every log line.

Closes #15
```

---

## PR Title Examples

PR titles follow the same Conventional Commits format but are kept
under 70 characters.

```
feat(bridge): add circuit breaker with configurable thresholds
fix(sse): prevent connection leak on client disconnect
refactor(ports): split IObservability into logging and tracing
test(e2e): validate token streaming across bridge
docs(contributing): update project structure for mono-repo
chore(docker): add health checks to compose services
perf(redis): switch to pipeline mode for batch lookups
```

---

## PR Description Examples

### Feature PR

```markdown
## Summary

- Add configurable circuit breaker to the HTTP bridge between Node.js
  and Python services
- Breaker opens after 5 consecutive failures (configurable via
  BRIDGE_CIRCUIT_THRESHOLD env var)
- Half-open state allows one probe request every 30 seconds before
  closing the circuit

## Why

The bridge currently retries indefinitely on Python service failures,
which can cascade into Node.js event loop saturation under load. The
circuit breaker provides fast-fail semantics and gives the Python
service time to recover.

Closes #42

## Test Plan

- [x] Unit tests for circuit breaker state machine (open/closed/half-open)
- [x] Integration test: bridge correctly opens after N failures
- [x] Integration test: bridge closes after successful probe
- [x] Manual: killed Python service, verified SSE clients get 503 within
  50ms instead of hanging for 5s timeout
```

### Bug Fix PR

```markdown
## Summary

- Fix duplicate MCP tool invocations when multiple SSE clients share
  a session
- Root cause: tool-call deduplication map had no concurrency guard
- Added asyncio.Lock scoped per session ID

## Why

Production logs showed the same tool being called 2-3x per request
under concurrent load. This doubled LLM token costs and caused
inconsistent responses when tool results varied between calls.

Fixes #87

## Test Plan

- [x] Unit test: concurrent tool calls with same ID are deduplicated
- [x] Integration test: 10 concurrent SSE connections, single session
- [x] Verified in Docker Compose with simulated load (wrk)
```

### Refactor PR

```markdown
## Summary

- Extract all direct Pino calls behind the IObservability port interface
- No functional changes — all existing log output is preserved
- Adapter wiring updated in container.ts

## Why

Direct logger calls scattered across services made it impossible to
swap observability providers without a codebase-wide find-and-replace.
This was identified as a blocker for the LangFuse integration (Phase 2).

## Test Plan

- [x] Existing tests pass with no modifications
- [x] Log output diff: compared structured JSON before/after, identical
- [x] Verified Sentry error capture still works through the port
```

---

## Ticket Reference Formats

### GitHub Issues — Closing Keywords

GitHub recognizes these keywords (case-insensitive, optional colon after keyword):
`close`, `closes`, `closed`, `fix`, `fixes`, `fixed`, `resolve`, `resolves`, `resolved`

All closing keywords behave identically — they auto-close the issue when the commit
is merged into the **default branch**. They are ignored for PRs targeting other branches.

```
Closes #42          — Auto-closes the issue on merge (feature convention)
Fixes #42           — Auto-closes the issue on merge (bug fix convention)
Resolves #42        — Auto-closes the issue on merge (alternative)
CLOSES: #42         — Also valid (case-insensitive, colon optional)
```

Cross-repo references:
```
Fixes owner/repo#42 — Auto-closes issue in a different repository
```

### GitHub Issues — Non-Closing References

These are team conventions. GitHub still links from the `#42` mention but does
NOT auto-close the issue:

```
Ref #42             — Related context (not a GitHub keyword)
Part of #42         — Incremental work toward an issue
See #42             — Reference only
```

### Jira Tickets

Jira detects ticket keys by pattern-matching `PROJECT-NUMBER` (uppercase letters,
hyphen, digits) anywhere in commit messages, branch names, or PR titles.
No keyword prefix is needed — the key itself triggers the link.

```
PROJ-1234           — Jira auto-links from the key pattern
CHAT-456            — Any project key works
```

### Multiple References

```
Closes #42, closes #43
CHAT-1234, CHAT-1235
Closes #42, CHAT-1234
```

---

## Changelog Examples

This skill maintains a `CHANGELOG.md` following the
[Keep a Changelog v1.1.0](https://keepachangelog.com/en/1.1.0/) specification.

### Full Example (with releases and comparison links)

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Content negotiation across MIME types via Accept header routing
  (SSE, JSON, Markdown, plain text) ([#15](https://github.com/user/repo/issues/15))

## [0.2.0] - 2026-03-14

### Added

- Circuit breaker for HTTP bridge with configurable thresholds
  ([CHAT-1234](https://jira.example.com/browse/CHAT-1234))

### Changed

- Moved all Pino calls behind IObservability port interface

### Deprecated

- Direct Pino logger imports — use IObservability port instead

### Fixed

- Duplicate MCP tool invocations under concurrent SSE streams
  ([#87](https://github.com/user/repo/issues/87))
- Redis connection timeout during cache warmup
  ([CHAT-456](https://jira.example.com/browse/CHAT-456))

### Security

- Sanitize user input in SSE event data to prevent XSS injection

## [0.1.0] - 2026-03-10

### Added

- Initial project scaffold with multi-language mono-repo structure
- Product documentation (mission, roadmap, tech stack)
- README, CONTRIBUTING, GitHub templates
- CLAUDE.md project instructions

[unreleased]: https://github.com/user/repo/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/user/repo/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/user/repo/releases/tag/v0.1.0
```

### Comparison Links (Required by keepachangelog 1.1.0)

Every versioned changelog MUST include comparison links at the bottom of the file.
These make each version heading clickable, showing the diff between releases.

```markdown
[unreleased]: https://github.com/user/repo/compare/vLATEST...HEAD
[LATEST]: https://github.com/user/repo/compare/vPREVIOUS...vLATEST
[PREVIOUS]: https://github.com/user/repo/releases/tag/vPREVIOUS
```

Detect the repo URL from `git remote get-url origin` and convert SSH URLs to HTTPS.

### Changelog Sections (keepachangelog 1.1.0)

The spec defines exactly six section types. They should appear in this order:

| Section | Purpose |
|---|---|
| **Added** | New features |
| **Changed** | Changes in existing functionality |
| **Deprecated** | Soon-to-be removed features |
| **Removed** | Now removed features |
| **Fixed** | Bug fixes |
| **Security** | Vulnerability fixes |

### Mapping Commit Types to Changelog Sections

| Commit Type | Changelog Section |
|---|---|
| `feat` | **Added** |
| `fix` | **Fixed** |
| `refactor` | **Changed** |
| `perf` | **Changed** |
| Deprecation notices | **Deprecated** |
| Removed functionality | **Removed** |
| Vulnerability fixes | **Security** |
| `docs` | *(skip unless user-facing)* |
| `test` | *(skip)* |
| `chore` | *(skip unless dependency/breaking)* |
| `BREAKING CHANGE` | **Changed** (flag prominently) |

### Rules

- New entries always go under `## [Unreleased]`
- Each entry is a single line starting with `- ` (hyphen space)
- Include ticket/issue link in parentheses at end of line when available
- Keep entries concise — one sentence, focus on what changed for the user
- Group related changes under a single bullet when possible
- Dates use ISO 8601 format: `YYYY-MM-DD`
- Latest version comes first (reverse chronological order)

### Cutting a Release

When the user asks to cut a release:

1. Rename `## [Unreleased]` to `## [X.Y.Z] - YYYY-MM-DD`
2. Add a fresh empty `## [Unreleased]` section above it
3. Add or update comparison links at the bottom of the file
4. Commit: `chore(release): prepare changelog for vX.Y.Z`
5. Optionally create an annotated git tag: `git tag -a vX.Y.Z -m "Release vX.Y.Z"`

---

## Sensitive Content Patterns to Scan For

These patterns should be flagged before any commit or PR:

| Category | Patterns |
|---|---|
| API keys | `sk-`, `pk-`, `api_key=`, `apikey=`, `AKIA` (AWS) |
| Tokens | `ghp_`, `gho_`, `github_pat_`, `xoxb-`, `xoxp-` (Slack) |
| Passwords | `password=`, `passwd=`, `pwd=`, `secret=` |
| Connection strings | `postgresql://user:pass@`, `redis://:pass@`, `mongodb+srv://` |
| Private keys | `BEGIN RSA PRIVATE`, `BEGIN OPENSSH PRIVATE`, `BEGIN EC PRIVATE` |
| Certificates | `BEGIN CERTIFICATE` |
| Company/vendor names | Context-dependent — check project-specific deny list |
| Internal URLs | `*.internal.*`, `*.corp.*`, `*.local.*` (non-localhost) |
| Email addresses | Personal or corporate email patterns |
| IP addresses | Non-RFC1918 IPs that could identify infrastructure |
