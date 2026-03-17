# Detection Patterns

This file serves two purposes:

1. **Friction vocabulary** — a shared language for naming what the Explore agent
   experienced. Used in Step 2 to describe *why* a cluster is a problem.
2. **Dependency categories** — a fixed taxonomy used in every candidate cluster and
   RFC to determine the correct testing strategy.

The Explore agent does NOT use this as a checklist. It navigates organically.
These definitions are applied *after* friction is observed, to name and classify it.

---

## Friction vocabulary

Use these terms when describing what the Explore agent encountered. Do not force
findings into categories — use the term only if it accurately describes the experience.

**Shallow module**
The interface surface is nearly as large as the implementation. Understanding the
module requires understanding its internals. Callers must orchestrate what the module
should own. Test boundary cannot be placed at the interface — you have to go inside.

**Interface leak**
Internal types, infrastructure names, or implementation details appear in the public
API. Callers import types they should never need to know about. Every internal change
ripples outward.

**Temporal coupling**
Callers must invoke methods in a specific sequence to get correct behaviour. The
sequence is undocumented and only discoverable by reading the implementation. One
wrong order produces a silent failure.

**Hidden orchestration**
A module appears simple from the outside but secretly coordinates multiple
collaborators in ways callers are expected to know about. The real contract is
implicit — it lives in comments, READMEs, or tribal knowledge.

**Test reach-in**
Tests cannot exercise behaviour through the module's public interface. They must
reach into internals — mock private collaborators, access protected state, or
call private methods — to set up or assert. A sign that the test boundary is in
the wrong place.

**Seam risk**
Two modules are so tightly coupled that changes to one reliably break the other.
The integration point is the source of bugs, but neither module owns it.

**Concept scatter**
Understanding one concept requires reading across many files. No single module
owns the idea. The Explore agent had to bounce before forming a mental model.

**Orphaned extraction**
A pure function or utility was extracted for testability alone, but the complexity
it was pulled from remains in how it is called. The extraction created the appearance
of testability without the reality.

---

## Dependency categories

Classify every candidate cluster into one of these four categories. The category
determines the recommended testing strategy and the shape of the deepened interface.

### 1. In-process

Pure computation, in-memory state, no I/O. No network calls, no filesystem, no clock,
no randomness. Everything the module does is deterministic given its inputs.

**Deepening approach:** merge the modules and test directly. No adapters, no fakes,
no infrastructure. The boundary test is a plain function or method call.

**Signal:** the Explore agent could trace all behaviour without encountering any
import of an infrastructure library, SDK, or I/O primitive.

---

### 2. Local-substitutable

The module depends on infrastructure that has a high-fidelity local stand-in usable
in the test suite. The stand-in behaves like the real thing — it is not a mock.

Examples: PGLite for PostgreSQL, an in-memory filesystem for disk I/O, a local
Redis-compatible server, an in-process SQLite for any relational store.

**Deepening approach:** the deepened module is tested with the local stand-in running
in the test process. No mocks. The boundary test exercises real persistence or I/O
behaviour through a substitute that is fast and portable.

**Signal:** infrastructure is involved, but a known stand-in exists and can be
imported and started within the test suite without network access.

---

### 3. Remote but owned (Ports & Adapters)

The module depends on services you control that run across a network boundary —
your own microservices, internal APIs, queues, or event buses.

**Deepening approach:** define a port (interface) at the module boundary. The deep
module owns the logic; transport is injected. Tests use an in-memory adapter.
Production uses a real HTTP, gRPC, or queue adapter.

**Recommendation shape for RFCs:**
> "Define a shared interface (port) that the domain owns. Implement an HTTP adapter
> for production and an in-memory adapter for testing, so the logic can be tested
> as one deep module even though it is deployed across a network boundary."

**Signal:** the Explore agent found imports of an internal SDK, a generated client,
or a service URL that routes to infrastructure you own and deploy.

---

### 4. True external (Mock)

The module depends on third-party services you do not control — payment processors,
SMS providers, email platforms, external analytics, third-party OAuth providers.

**Deepening approach:** mock at the boundary. The deepened module takes the external
dependency as an injected port. Tests provide a mock implementation that simulates
the external service's observable behaviour (success, failure, rate-limit, etc.).

**Signal:** the Explore agent found imports of a third-party SDK or API client for
a service whose behaviour and uptime you do not control.

---

## Testing strategy (applies to all categories)

**Core principle: replace, don't layer.**

- Old unit tests written against shallow modules become waste once boundary tests
  exist at the deepened interface — **delete them**
- Write new tests at the deepened module's interface boundary only
- Tests assert on observable outcomes through the public interface, not internal state
- Tests must survive internal refactors — they describe behaviour, not implementation
- If a test requires knowledge of how the module works internally to be meaningful,
  the test boundary is in the wrong place
