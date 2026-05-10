# Review Checklists

Use the relevant checklist below. For each finding, report: **severity** (blocking / warning / suggestion), **location** (file path or line), and a **concrete fix**.

## Profile review: `~/agent-os/profiles/<name>/`

1. Confirm `standards/` exists with `.md` files.
2. Flag v2 artifacts: `agents/`, `commands/`, `workflows/`, `profile-config.yml` (see `v2-vs-v3.md`).
3. Read `~/agent-os/config.yml`:
   - `version: 3.0.0`?
   - If `inherits_from` is declared, does the parent profile folder exist?
   - Is `default_profile` set to a profile that exists?
4. For each standard:
   - Does it lead with the rule on line 1?
   - Is it concise (bullets, not paragraphs)?
   - Are there code examples where useful?
   - Does it document something non-obvious / tribal / opinionated?
5. Flag standards that describe obvious framework behavior or restate what the code already shows.

## Project setup review: `<repo>/`

1. Confirm `agent-os/standards/` exists with `.md` files.
2. Confirm `agent-os/standards/index.yml` exists. Cross-check:
   - Every entry maps to an existing file (flag orphans)
   - Every standards file has an entry (flag unindexed files)
3. Confirm `.claude/commands/agent-os/` has all 5 files:
   - `discover-standards.md`
   - `index-standards.md`
   - `inject-standards.md`
   - `plan-product.md`
   - `shape-spec.md`
4. Flag `.claude/agents/agent-os/` if present (v2 artifact).
5. If `agent-os/product/` exists, verify all three: `mission.md`, `roadmap.md`, `tech-stack.md`.
6. If `agent-os/specs/` has entries, verify each spec folder contains at minimum `plan.md` and `shape.md`.

## Standards quality audit

For each `.md` file in `agent-os/standards/`:

1. Read the file end-to-end.
2. Apply quality rules from `standards.md`. Flag:
   - Paragraph-heavy content with no code
   - Missing code examples
   - Single-concept violations (multiple unrelated patterns)
   - Documents framework defaults
   - Vague filename (e.g. `general.md`, `misc.md`)
3. Check `index.yml`:
   - Descriptions specific enough to drive `/inject-standards` matching?
   - Any orphan entries?
   - Any unindexed files?
4. Provide concrete rewrite suggestions, not generic advice. When you flag a paragraph, supply the rewritten version.

## Output format for findings

Group by severity:

```
## Blocking
- `agent-os/standards/index.yml:14`: entry `api/legacy` references deleted file.
  Fix: run `/index-standards`.

## Warning
- `agent-os/standards/error-handling.md`: 3 paragraphs of philosophy, no code example.
  Fix: rewrite leading with the rule plus a JSON example. Suggested draft: <inline>.

## Suggestion
- `agent-os/standards/naming.md` (180 lines): combines file naming, class naming, env vars.
  Fix: split into 3 files.
```
