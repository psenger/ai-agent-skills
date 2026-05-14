# Review Checklists

Three target checklists, plus a per-file standards quality lens that applies inside any target.

For each finding, report: **severity** (blocking / warning / suggestion), **location** (file path or line), a **concrete fix**, and a **source tag** (`[ref]`, `[corpus]`, `[both]`).

**Always identify the target first.** See `file-structure.md` for the detection table and per-target schemas. Open every findings report with `## Audit target: <A | B | C> — <path>`.

---

## Target A — Profile source directory audit

Path shape: `~/agent-os/profiles/<name>/` or a checked-out single-profile dir.

1. **Detect the layout.** Layout A1 has a `standards/` wrapper; Layout A2 has domain folders at profile root. Both are valid.
2. **Confirm standards content exists.** At least one `.md` standards file under the profile (under `standards/` for A1, or in domain folders for A2).
3. **Flag v2 artifacts** (see `v2-vs-v3.md`): `agents/`, `commands/`, `workflows/`, `profile-config.yml`.
4. **Flag `index.yml` if present.** Indexes are generated at project-install time, not hand-authored in profiles. An `index.yml` in a profile source is almost always a copy-paste from a project install. Fix: delete it.
5. **Flag `specs/` or `product/` if present.** Those belong to Target B (project installs), not Target A.
6. **If Layout A2 and the profile is meant to be installed via `project-install.sh`:** flag a warning — the script resolves `<profile>/standards/` and will install nothing. Fix: move domain folders under `standards/`, or install manually.
7. **Read `~/agent-os/config.yml`:**
   - `version: 3.0.0`?
   - If this profile is referenced under `profiles:` and has `inherits_from`, does the parent folder exist?
   - If this profile is set as `default_profile`, does it exist? (Trivially yes when auditing it, but check spelling.)
8. **For each standard `.md` file:** apply the standards quality lens below.

### Target A findings that are STRUCTURALLY WRONG to produce

- Missing `index.yml` — not expected in Target A.
- Missing `.claude/commands/agent-os/` — not part of Target A.
- Missing `product/` or `specs/` — not part of Target A.
- "Domain folders aren't under `standards/`" — only valid as a warning, not blocking, and only if Layout A2 is going to be installed by the script.

---

## Target B — Project install audit

Path shape: a repo root containing `agent-os/standards/index.yml`.

1. **Confirm `agent-os/standards/` exists** with `.md` files.
2. **Confirm `agent-os/standards/index.yml` exists.** Its absence is blocking — the install script generates it; absence indicates a broken or partial install. Fix: re-run `~/agent-os/scripts/project-install.sh`.
3. **Cross-check `index.yml` against the filesystem:**
   - Every entry maps to an existing file (flag orphans).
   - Every standards file has an entry (flag unindexed files).
   - Fix in both cases: run `/index-standards`.
4. **Confirm `.claude/commands/agent-os/` has all 5 files:**
   - `discover-standards.md`, `index-standards.md`, `inject-standards.md`, `plan-product.md`, `shape-spec.md`.
   - Missing any → blocking. Fix: `~/agent-os/scripts/project-install.sh --commands-only`.
5. **Flag `.claude/agents/agent-os/` if present** — v2 artifact.
6. **Remember `standards/` is a merged artifact.** Two unrelated-looking domain folders (e.g. `symfony/` next to `php/`) is **expected** if the inheritance chain contributed both. Do **not** flag this as inconsistency.
7. **If `agent-os/product/` exists**, verify all three: `mission.md`, `roadmap.md`, `tech-stack.md`. Missing files → warning.
8. **If `agent-os/specs/` has entries**, verify each spec folder contains at minimum `plan.md` and `shape.md`.
9. **For each standard `.md` file:** apply the standards quality lens below.

### Target B findings that are STRUCTURALLY WRONG to produce

- "`index.yml` is hand-authored / shouldn't be here" — it is required and generated.
- "Domain folders from multiple profiles shouldn't sit at the same level" — that is the expected merged shape.
- "Profile-name nesting is missing inside `standards/`" — profile name does not appear in the merged artifact.

---

## Target C — Enterprise profiles repository audit

Path shape: a repo root containing multiple profile-shaped dirs (Layout C1 with a `profiles/` wrapper, or Layout C2 with profile dirs directly at repo root).

1. **Detect the layout.** Presence of `<repo>/profiles/<name>/` → C1. Multiple `<repo>/<name>/` siblings each containing standards content → C2.
2. **For each profile dir in the repo:** apply the Target A checklist (steps 1–6 and 8).
3. **Flag any `index.yml` anywhere in the repo.** Indexes belong to Target B only. Fix: delete.
4. **Flag `.claude/commands/agent-os/` if present.** Target C is a profiles source, not a project install.
5. **Flag `agent-os/product/` or `agent-os/specs/` if present.** Those belong to Target B.
6. **If a `config.yml` exists at repo root:** validate the same way as `~/agent-os/config.yml` — version, inheritance targets exist among the profiles in this repo.
7. **Validate that profile names follow one naming axis** (tech stack OR client OR context), not mixed. See `profiles.md`.

### Target C findings that are STRUCTURALLY WRONG to produce

- Missing `index.yml` — does not belong here.
- Missing `.claude/commands/agent-os/` — does not belong here.
- Missing `product/` or `specs/` — does not belong here.
- "There are too many profile dirs" — multiple profiles is the defining feature of Target C.

---

## Inheritance coherence audit (applies when a chain exists)

A profile chain like `base → php → symfony` should flow **general to specific**. The audit verifies this is true and surfaces hidden problems that the file-by-file override mechanism papers over. Coherence is a separate concern from structure — a profile can pass the Target A checklist and still be incoherent.

### When to run

- **Target A:** if the audited profile is listed in `~/agent-os/config.yml` under `profiles:` with `inherits_from`, walk the chain from this profile up to the root.
- **Target B:** the merged `standards/` hides which profile contributed each file. Read `~/agent-os/config.yml` to recover the chain that produced this install, then walk each profile dir in `~/agent-os/profiles/` along that chain.
- **Target C:** if the repo has its own `config.yml` declaring inheritance among bundled profiles, walk those chains the same way.
- Skip if no inheritance is declared. A standalone profile has nothing to be coherent with.

### Process

1. **Resolve the chain.** Read `inherits_from` from `config.yml`, walking until a profile has none. Order: child → parent → grandparent. Cap chain depth at 5; flag deeper chains as a smell (see `profiles.md`).
2. **For each profile in the chain, list its standards files.** Normalize paths relative to the profile root (so `standards/api/auth.md` and `api/auth.md` compare as the same logical file across A1/A2 layouts).
3. **Build the contribution map.** A table with one row per logical file path. Columns:
   - `File` — the normalized path
   - `Contributed by` — the most-general profile in the chain that defines this file
   - `Overridden in` — every later profile in the chain that also defines this file (comma-separated, in chain order)
   - `Notes` — flags raised in step 4
4. **Surface findings.** For each file, check:
   - **Generality leak.** The file's *content* mentions tokens specific to a stack the profile is not named for. Examples: `base/standards/lang/version.md` contains "PHP 5.4"; `php/standards/orm.md` is full of Doctrine syntax. Suggest renaming the profile or pushing the file down the chain.
   - **Override saturation.** A file in a parent is overridden in every descendant in the chain. The parent's version may not earn its keep — surface as a suggestion to move the file down or delete it from the parent.
   - **Cross-level conflict.** A parent rule and a child rule are *semantically incompatible* (not merely different — the override hides the contradiction from `/inject-standards`, but a future sibling child that doesn't override inherits the wrong rule). Flag as a warning.
   - **Naming/positioning mismatch.** The profile name implies broad applicability but content is narrow, or vice versa.

### Output format

After the structural findings, append:

```
## Inheritance coherence

**Chain:** symfony → php → base

### Contribution map

| File | Contributed by | Overridden in | Notes |
|---|---|---|---|
| api/auth.md | base | php, symfony | generality leak in `base` |
| naming.md | base | — | — |
| orm/entities.md | php | symfony | override saturation |
| http/error-format.md | php | symfony | cross-level conflict |

### Findings

- **[generality-leak]** `~/agent-os/profiles/base/standards/lang/version.md` [ref]
  Declares "PHP 5.4". `base` sits at the chain root and should be language-agnostic. A future sibling Node.js or Python child cannot inherit cleanly.
  Fix: rename `base` to `php-base` to reflect actual scope, OR move this file down to `php` and keep `base` generic.

- **[override-saturation]** `orm/entities.md` defined in `php`, overridden by `symfony` [ref]
  Every descendant overrides the parent's version. The `php` copy may be dead weight.
  Fix: delete from `php` and let `symfony` (and any future framework child) own it, OR rewrite the `php` version to be framework-agnostic so children can extend rather than replace.

- **[cross-level-conflict]** `http/error-format.md` [ref]
  `php` mandates a flat error envelope; `symfony` mandates RFC 7807. The override resolves it for `symfony`, but any new child of `php` (e.g. `slim`, `lumen`) inherits the wrong rule by default.
  Fix: either push the RFC 7807 rule up to `php` so all PHP descendants get it, OR document in `php` that the error format is intentionally left to child profiles to specify.
```

### Findings that are STRUCTURALLY WRONG to produce

- "The chain is too short" — single-level inheritance is fine.
- "Child overrides parent" — that is the override mechanism working as designed. Only flag *saturation* (every descendant overrides) or *conflict* (semantically incompatible), not the existence of overrides.
- Cross-level conflicts when the override is by design and the parent file documents that intent.

---

## Standards quality lens (applies inside any target)

For each `.md` standards file encountered during a Target A, B, or C audit:

1. Read the file end-to-end.
2. Apply quality rules from `standards.md`. Flag:
   - Paragraph-heavy content with no code example.
   - Documents framework defaults (delete-worthy).
   - Multiple unrelated concepts in one file → split.
   - Vague filename (e.g. `general.md`, `misc.md`).
   - File over ~100 lines → likely combining concepts.
3. For Target B only: also check the `index.yml` description for this file. Vague descriptions break `/inject-standards` matching.
4. **Provide concrete rewrite suggestions, not generic advice.** When you flag a paragraph, supply the rewritten version inline.

---

## Output format for findings

Open with the target header, then group findings by severity. Tag each finding with its source.

```
## Audit target: B (project install) — /Users/me/work/my-project

## Blocking
- `agent-os/standards/index.yml:14`: entry `api/legacy` references deleted file. [ref]
  Fix: run `/index-standards`.

## Warning
- `agent-os/standards/error-handling.md`: 3 paragraphs of philosophy, no code example. [ref]
  Fix: rewrite leading with the rule plus a JSON example. Suggested draft: <inline>.

## Suggestion
- `agent-os/standards/naming.md` (180 lines): combines file naming, class naming, env vars. [ref]
  Fix: split into 3 files.
```
