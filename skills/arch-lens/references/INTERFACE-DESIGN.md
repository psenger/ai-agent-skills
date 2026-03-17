# Interface Design — Sub-Agent Briefs and Dependency Strategies

Used in Step 5. Each sub-agent receives an independent technical brief plus one
design constraint. Briefs are written for agents — technical, precise, independent
of any user-facing explanation.

---

## Technical brief template

Construct one brief per agent. Fill every field from the Step 4 framing:

```
MODULE: <name of the module / class / function being redesigned>
FILES: <file:startLine–endLine for each relevant file>
CURRENT INTERFACE:
  <paste the existing public API — method signatures, exported functions, constructor>
CALLERS: <list up to 5 representative call sites with file:line>
DEPENDENCIES: <what this module depends on — list concrete types, SDKs, singletons>
DEPENDENTS: <modules that import this one — fan-in count and representative list>
COUPLING DETAIL: <what is currently leaking through the interface that shouldn't>
HIDDEN TARGET: <what complexity should disappear behind the new interface>
DESIGN CONSTRAINT: <see constraints below — assign one per agent>
```

---

## Design constraints (assign one per agent)

**Agent 1 — Minimise**
> Aim for 1–3 entry points maximum. Every parameter must be essential.
> If the caller has to know more than the module's name and one primary concept
> to use it, the interface is still too wide.

**Agent 2 — Maximise flexibility**
> Support the full range of current and plausible future use cases without
> callers reaching into internals. Prefer extension points (callbacks, options
> objects, strategy injection) over a narrow fixed contract. The interface should
> rarely need to change when new use cases arrive.

**Agent 3 — Optimise for the common caller**
> Identify the single most frequent call pattern from the caller list.
> Make that pattern require zero configuration — one call, no setup.
> Edge cases go through overloads or optional parameters, not the primary path.

**Agent 4 — Ports & adapters (assign when dependencies cross a domain boundary)**
> Define the module as a port: a pure interface the domain owns.
> All infrastructure (DB, HTTP, queue, clock, filesystem) becomes an adapter
> injected at the boundary. The module's core must be testable with zero
> real infrastructure.

---

## Required output from each sub-agent

Each agent must produce all five sections. Incomplete output is invalid.

### 1. Interface signature
The complete proposed public API — types, method names, parameters, return types.
Use the target language's type notation. Be precise.

```ts
// example
interface PaymentProcessor {
  process(payment: Payment): Promise<Receipt>
}
```

### 2. Usage example
Show a real caller using the proposed interface. Must demonstrate the primary
use case end-to-end in < 15 lines. No setup boilerplate beyond construction.

### 3. What complexity is hidden
A bullet list: what does the implementation now own that callers no longer
need to know about? Be specific — name the types, SDKs, sequences, and error
conditions that disappear from the caller's view.

### 4. Dependency strategy
How are the module's dependencies handled? Choose one strategy and justify it:

| Strategy | When to use |
|----------|-------------|
| **Constructor injection** | Dependencies are stable, known at construction time, and vary by environment |
| **Method injection** | Dependency varies per call, not per instance |
| **Factory / builder** | Construction is complex; callers shouldn't own the graph |
| **Ports & adapters** | Dependency crosses a domain boundary; core must stay infrastructure-free |
| **Higher-order function** | Behaviour (not infrastructure) varies — pass a function, not an object |
| **Module-level config** | Single process, single configuration; dependency is truly global and stable |

### 5. Trade-offs
Two to four honest trade-offs of this design. What does it sacrifice? What
becomes harder? Where would this design strain under future requirements?

---

## Comparison format (after all agents complete)

Present designs in numbered order. Then compare:

| Dimension | Agent 1 (Minimise) | Agent 2 (Flexibility) | Agent 3 (Common caller) | Agent 4 (P&A) |
|-----------|--------------------|-----------------------|-------------------------|----------------|
| Entry points | | | | |
| Test boundary | | | | |
| Extension cost | | | | |
| Dep strategy | | | | |
| Caller simplicity | | | | |

Follow the table with 2–3 sentences of prose comparison.

---

## Recommendation format

After the comparison, give a single opinionated recommendation:

```
RECOMMENDATION: <Agent N design> [or: hybrid of Agent M and Agent N]

Why: <2–3 sentences — why this design wins on the most important dimensions
     for this specific module>

If hybrid: <name the exact elements taken from each design and why they combine well>

What to watch: <one honest risk or caveat in the recommended design>
```

Do not hedge. The user wants a strong read. If two designs are genuinely equal on
all dimensions, say so and explain exactly what would break the tie.
