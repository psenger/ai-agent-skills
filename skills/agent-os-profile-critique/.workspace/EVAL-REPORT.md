# Eval Report — agent-os-profile-critique

This document describes the eval suite for the `agent-os-profile-critique` skill, what each test
verifies, and where to record results after a run. Results sections are stubbed until
the suite is executed.

## Files under test

- `skills/agent-os-profile-critique/SKILL.md`
- `skills/agent-os-profile-critique/references/*.md` — 6 reference files
- `skills/agent-os-profile-critique/.workspace/evals/trigger-evals.json` — 15 queries
- `skills/agent-os-profile-critique/.workspace/evals/evals.json` — 1 functional case
- `skills/agent-os-profile-critique/.workspace/evals/files/v2-profile/` — fixture for case 1

## Trigger evals

Tests whether the skill description activates on the right prompts and stays quiet on
the wrong ones. Target: 95% (14/15).

Run (from repo root):
```bash
bash skills/agent-os-profile-critique/.workspace/run-trigger-eval.sh
```

### Should-trigger queries (3)

| # | Query | What it verifies |
|---|---|---|
| 1 | Here's a standard I wrote for my agent-os profile, is it any good? Always use descriptive variable names. | Standards critique with realistic pasted content and agent-os context |
| 2 | Can you review my agent-os profile and tell me what's wrong? | Profile review, natural phrasing with agent-os keyword |
| 3 | validate my agent-os profile setup | Profile validation, terse natural phrasing |

### Should-not-trigger queries (10)

These are tricky near-misses that distinguish this skill from generic project work.

| # | Query | Why it must NOT trigger |
|---|---|---|
| 1 | Set up a new Node.js project structure with Express and TypeScript | Generic scaffolding, no Agent OS context |
| 2 | Audit my package.json for outdated dependencies and security issues | "Audit" keyword present but unrelated to Agent OS |
| 3 | Help me write a coding standard document for our team's React work | "Standard" keyword but no Agent OS context |
| 4 | How do I configure my .eslintrc.yml for monorepo workspaces? | Config-file question for an unrelated tool |
| 5 | Review this REST API design and tell me where the security holes are | "Review" keyword but API-design domain |
| 6 | What's the best operating system for running coding agents locally? | Literal "operating system" near-miss for "agent os" |
| 7 | Create a config.yml for my GitHub Actions deployment workflow | `config.yml` in unrelated product context |
| 8 | Write me an OpenAPI spec for the /users endpoint | "Spec" keyword but OpenAPI, not Agent OS |
| 9 | How do I customize my GitHub profile README? | "Profile" keyword in unrelated context |
| 10 | Set up a CI/CD pipeline spec for our staging deployment | "Spec" plus "set up" but DevOps domain |

### Trigger eval results

**Run 2026-05-10 — isolated, no competing skills**

- **Score:** 10 / 15
- **Precision:** 100%
- **Recall:** 7%
- **Accuracy:** 69%
- **False negatives (should-trigger, did not fire):**
  - Here's a standard I wrote for my agent-os profile, is it any good?

Always use descriptive variable names.
  - audit my agent-os profile at ~/agent-os/profiles/my-company/ and give me a severity-tagged report
  - Can you review my agent-os profile and tell me what's wrong?
  - Is this agent-os standard any good?

# Error Handling

Always handle errors gracefully.
  - I think my agent-os profile has some v2 artifacts in it, can you check?
- **False positives:** none
- **Decision:** _update after review_

## Functional evals

Tests whether the skill produces correct output. One case.

### Case 1 — `audit-v2-profile-flags-artifacts`

**Prompt:** Audit the Agent OS profile at `.workspace/evals/files/v2-profile/` and give
me severity-tagged findings.

**Fixtures:**
- `.workspace/evals/files/v2-profile/profile-config.yml` — a v2 artifact
- `.workspace/evals/files/v2-profile/standards/python-style.md` — a deliberately weak
  standard (restates PEP 8, no code examples, no leading rule)

**What it verifies:**
- The skill reads the fixture before recommending changes.
- The skill flags `profile-config.yml` as a v2 artifact.
- The skill recommends moving inheritance to `~/agent-os/config.yml`.
- The skill critiques `python-style.md` for restating framework defaults, missing a
  leading rule, and missing code examples.
- Each finding includes a severity label, a specific file path, and a concrete fix.

### Functional eval results

_Pending first run._

## Acceptance criteria coverage

| Criterion | Verified by |
|---|---|
| Skill loads in Claude Code without validation errors | Manual: `ls`, frontmatter check |
| Description triggers reliably on critique/audit/review queries | Trigger evals (target 95%) |
| Skill does NOT trigger on getting-started, commands, or ticket-to-spec queries | Trigger evals (should-not-trigger) |
| Skill flags v2 artifacts | Functional case 1 |
| Skill reads fixtures before recommending changes | Functional case 1 |
| Each finding has severity, file path, and concrete fix | Functional case 1 |
| No em-dashes; imperative voice throughout | Manual: `grep -n '—'` |

## How to update this report

After each run, replace the corresponding "_Pending first run._" block with the
actual numbers and observations.
