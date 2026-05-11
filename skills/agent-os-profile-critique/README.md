# agent-os-profile-critique

Audits Agent OS v3 profiles and standards. Produces severity-tagged findings with concrete fixes.

> Agent OS is a project by CasJam Media LLC (Builder Methods): https://github.com/buildermethods/agent-os

---

## What this skill does

When you invoke this skill, it loads structured audit checklists and quality criteria into the model's context that it does not have natively. Without the skill, the model gives generic feedback. With it, the model produces findings that are:

- Severity-tagged: `blocking`, `warning`, or `suggestion`
- Anchored to specific file paths and line numbers
- Accompanied by concrete, actionable fixes rather than advice

The skill covers three audit targets:

**Profile review** (`~/agent-os/profiles/<name>/`) — validates that the profile folder is a clean v3 layout, checks `config.yml` for version and inheritance integrity, and audits each standard file for quality.

**Project setup review** (`<repo>/`) — verifies that `agent-os/standards/` and `index.yml` are present and consistent, confirms that all five `.claude/commands/agent-os/` slash command files exist, and checks that `product/` and `specs/` subdirectories are complete if present.

**Standards quality audit** — line-by-line review of individual standard files against a quality bar: does the standard lead with the rule, include a code example, and document something non-obvious? Or does it restate framework defaults and waste context-window tokens?

---

## What the skill teaches

The model's pre-trained knowledge of Agent OS is limited and may be outdated. The skill loads six reference files on demand:

| Reference | Covers |
|---|---|
| `review-checklists.md` | Step-by-step checklists for each audit type and the output format for findings |
| `standards.md` | What qualifies as a good standard, what disqualifies one, quality rules, and common audit findings |
| `file-structure.md` | The canonical v3 directory layout for both the base installation and a project installation |
| `profiles.md` | Profile rules, inheritance via `config.yml`, naming conventions, and when to create vs. extend |
| `v2-vs-v3.md` | The differences between v2 and v3, how to spot v2 artifacts, and migration steps |
| `standards-vs-skills.md` | When to use a standard vs. a skill, and how to compose them |

References are loaded on demand, not preloaded. The model reads only the reference relevant to the question at hand.

---

## Do standards actually do anything?

A common objection from developers unfamiliar with how LLM context works: "this standard won't do anything, the model already knows how to write APIs." This is almost always wrong, and the reasoning matters.

A standard occupies the context window before the model reads any code or answers any question. Because of how transformer attention works, what appears earlier in context shapes what the model weighs later. A standard stating "all API responses use this envelope structure with `success`, `data`, and `error` keys" absolutely influences generated code, even if the model has seen envelope patterns before. The standard replaces a distribution of possible outputs with a specific one that matches your team's convention.

The objection is only correct in one narrow case: **the standard restates something the model already handles well AND the codebase already demonstrates clearly.** In that case the standard adds no signal and wastes tokens.

So the right question is not "does it do anything" but "does it earn its context-window cost." Those are different questions, and this skill answers the second one. A standard earns its place when it:

- Leads with the rule on line 1
- Includes a code example
- Documents a pattern that is opinionated, tribal, or frequently gotten wrong
- Fits on one screen

If a developer wants to remove a standard, run the standards quality audit on it first. The findings will tell you whether the standard is genuinely redundant or whether it is carrying weight the developer cannot see.

---

## Confidence attribution and model bias

This skill produces a **confidence attribution report** at the end of every audit. Each finding is tagged with its source:

- `[ref]` — derived from a skill reference file loaded during the session
- `[corpus]` — derived from the model's pre-trained knowledge
- `[both]` — corroborated by both

### Why this matters

**Model bias is real.** The model's corpus reflects Agent OS as it existed up to the model's training cutoff, which may predate Agent OS v3 (released January 2026) or include inaccurate community discussions. When a finding is tagged `[corpus]`, it should be treated as informed but unverified against the current Agent OS specification.

**Corpus knowledge favors popular patterns.** The model has seen far more generic coding advice than Agent OS-specific guidance. A finding about "leads with the rule" quality is likely correct regardless of source. A finding about a specific v3 config key or path convention should be verified against the official Agent OS documentation if tagged `[corpus]`.

**The skill is calibrated to v3.** If `~/agent-os/config.yml` reports `version: 4.x` or higher, the model will say so and ask whether to proceed. Any v3-specific claims made while auditing a v4 install carry an implicit caveat.

### What the report looks like

At the end of an audit the model appends a section like this:

```
## Skill Effectiveness Report

Model: claude-sonnet-4-6 (knowledge cutoff: August 2025)
Agent OS version detected: 3.0.0
References loaded this session: review-checklists.md, standards.md

Finding attribution:
- 4 findings from [ref] — high confidence, grounded in loaded references
- 2 findings from [corpus] — treat as informed but verify against current docs
- 1 finding from [both] — corroborated

Model bias disclaimer: The model's corpus knowledge of Agent OS is sparse relative
to mainstream frameworks. Findings tagged [corpus] are particularly likely to reflect
generic best-practice reasoning rather than Agent OS-specific rules. When in doubt,
check the Agent OS GitHub repository or run the skill again after loading the relevant
reference explicitly.
```

This report does not change the findings. It tells you how much to trust each one.

---

## Trigger phrases

The skill activates when:

- The user pastes a standard and asks if it is good or what is wrong with it
- The user asks to review, audit, validate, or critique an Agent OS profile or standard
- The user mentions "agent-os profile", "agent-os standard", or "my agent-os setup" in a review or validation context

It requires explicit invocation. It does not activate on general Agent OS questions.

---

## Version handling

Before giving substantive guidance the skill reads `~/agent-os/config.yml` and checks the `version:` field.

- `3.x`: proceeds normally.
- `4.x` or higher: tells the user once that the skill is calibrated to v3 and may be out of date, then asks whether to proceed. If yes, any v3-specific claim is caveated.
- Missing or below `3.0.0`: treats as a v2 install, surfaces the migration steps from `v2-vs-v3.md`, and recommends migration before any other audit work.

The skill does not refuse to help on a version mismatch.

---

## v2 artifacts

The skill flags v2 leftovers on sight regardless of which audit is running:

| Artifact | Why it's wrong |
|---|---|
| `.claude/agents/agent-os/` in a project | Subagents were retired in v3; frontier models handle it |
| `~/agent-os/profiles/<name>/profile-config.yml` | Inheritance moved to `~/agent-os/config.yml` root |
| `agents/`, `commands/`, or `workflows/` inside a profile folder | Profiles contain `standards/` only in v3 |
| `~/agent-os/config.yml` missing or `version` below `3.0.0` | Baseline v3 requirement |

When v2 artifacts are found, the skill surfaces migration steps before continuing with other findings. Most other findings assume a clean v3 baseline.

---

## License

MIT. See `LICENSE` for full text.