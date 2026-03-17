# Workflow — Step-by-Step Detail

Full instructions for each of the seven steps. Load this file at the start of
every arch-lens session.

---

## Step 1 — Explore (organic)

Spawn a sub-agent using the Agent tool with `subagent_type=Explore`. Give it this
prompt (substituting the actual scope path):

> Navigate this codebase naturally — as a developer trying to understand it would.
> Do NOT apply rigid rules or checklists. Explore organically and record where you
> experience friction:
>
> - Where does understanding one concept require bouncing between many small files?
> - Where are modules so shallow that the interface is nearly as complex as the implementation?
> - Where have pure functions been extracted just for testability, but the real bugs
>   hide in how they're called?
> - Where do tightly-coupled modules create integration risk in the seams between them?
> - Which parts of the codebase are untested, or structurally hard to test?
>
> The friction you encounter IS the signal. Return a list of friction observations:
> what you were trying to understand, what made it hard, which files were involved,
> and what you couldn't find (e.g. a clean test boundary, a single entry point,
> a coherent concept in one place). Include file paths and line ranges.

Wait for the Explore agent to complete. Use its friction observations — not your own
static analysis — as the raw material for Step 2.

---

## Step 2 — Present candidate clusters

Synthesise the Explore agent's friction notes into candidate clusters. Cap at 8.
Each cluster groups the modules or concepts involved in one piece of friction.

For each cluster, present:

```
### Cluster N: <conceptual name — not a file name>

Modules involved:     <file paths or package names>
Coupling reason:      <one sentence — why are these things coupled that shouldn't be>
Co-owners:            <which layer/package owns each module>
Call patterns:        <how they call each other; number of call sites>
Shared types:         <data types that cross the boundary>
Dependency category:  <In-process | Local-substitutable | Remote but owned | True external>
                      (see DETECTION-PATTERNS.md for definitions)
Existing tests        <list specific test names or describe test patterns that become
replaced:             redundant once a boundary test exists at the deepened interface>
Navigation friction:  <quote or paraphrase what the Explore agent experienced>
```

After presenting all clusters, ask:

> **Which of these would you like to explore?**

Do not propose any interface designs yet.

---

## Step 3 — User picks and directs

Once the user identifies a cluster, ask a single open question:

> **What would you like to explore about [cluster name]?**

Wait for their answer before proceeding. Let their response shape the depth and
angle of the problem framing in Step 4.

---

## Step 4 — Frame the problem space

Using the cluster data and the user's direction from Step 3, write a structured
problem statement:

- **Principle violated** — name it explicitly
- **Current interface** — show the existing API surface (signatures, not implementation)
- **Coupling details** — what it depends on; what depends on it; blast radius
- **Dependency category** — confirm the category and what it means for testing strategy
- **Consequence** — what gets harder, breaks, or accumulates if left unchanged
- **Test boundary today** — where tests currently have to reach; what they must mock

This framing is also the input to sub-agent technical briefs in Step 5.

---

## Step 5 — Design multiple interfaces

Spawn 3–4 sub-agents in parallel using the Agent tool. Each receives an independent
technical brief and a distinct design constraint. See `INTERFACE-DESIGN.md` for the
brief template, constraints, required output format, and dependency strategies.

Wait for all agents to complete, then:

1. Present each design sequentially (signature → usage → hidden complexity → dep strategy → trade-offs)
2. Compare in a table and a short prose paragraph
3. Give a strong, opinionated recommendation — name a winner or a hybrid and say why

---

## Step 6 — User picks interface

Ask: *"Which interface design do you want to use for this RFC — or accept my recommendation?"*

Lock in the chosen design before proceeding.

---

## Step 7 — Write the RFC action file

Write a single markdown file to the project root:

```
arch-rfcs-YYYY-MM-DD.md
```

One RFC section per confirmed finding, using the format in `RFC-FILE-FORMAT.md`.
Do **not** open any GitHub or Jira issues — the file is the deliverable.
Confirm the file path to the user when done.
