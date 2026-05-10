# Eval Report — agent-os-assist

This document describes the eval suite for the `agent-os-assist` skill, what each test
verifies, and where to record results after a run. Results sections are stubbed until
the suite is executed.

## Files under test

- `skills/agent-os-assist/SKILL.md`
- `skills/agent-os-assist/references/*.md` — 8 reference files
- `skills/agent-os-assist/.workspace/evals/trigger-evals.json` — 20 queries
- `skills/agent-os-assist/.workspace/evals/evals.json` — 2 functional cases

## Trigger evals

Tests whether the skill description activates on the right prompts and stays quiet on
the wrong ones. Target: 95% (19/20).

Run (from repo root):
```bash
bash skills/agent-os-assist/.workspace/run-trigger-eval.sh
```

### Should-trigger queries (10)

| # | Query | What it verifies |
|---|---|---|
| 1 | How do I turn JIRA-1234 ticket into an Agent OS spec | Ticket-to-spec, ticket key reference |
| 2 | How do I turn this ticket https://mycompany.atlassian.net/browse/PROJ-1234 into an Agent OS spec | Ticket-to-spec, Jira URL reference |
| 3 | How do I turn GitHub issue #42 into an Agent OS spec | Ticket-to-spec, GitHub issue number reference |
| 4 | How do I turn this issue https://github.com/myorg/myrepo/issues/42 into a spec | Ticket-to-spec, GitHub issue URL reference |
| 5 | Should I commit the agent-os directory in my project to git? | Version control question about agent-os project directory |
| 6 | I dont know what to do now that I installed agent-os | Post-install onboarding, user-supplied phrasing |
| 7 | I just installed agent-os and need to write my first standard. Where do I start? | Post-install onboarding plus first standard authoring |
| 8 | How do I make a new corporate or enterprise standard? | Authoring a new standard at org scope |
| 9 | What should be in ~/agent-os/config.yml for inheritance to work? | config.yml plus ~/agent-os/ path activates |
| 10 | My Agent OS spec for the auth feature is wrong. How do I recover without losing history? | Spec recovery use case activates |

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
| 7 | Create a config.yml for my GitHub Actions deployment workflow | config.yml in unrelated product context |
| 8 | Write me an OpenAPI spec for the /users endpoint | "Spec" keyword but OpenAPI, not /shape-spec |
| 9 | How do I customize my GitHub profile README? | "Profile" keyword in unrelated context |
| 10 | Set up a CI/CD pipeline spec for our staging deployment | "Spec" plus "set up" but DevOps domain |

### Trigger eval results

**Run 2026-05-10 — isolated, no competing skills**

- **Score:** 10 / 20
- **Precision:** 100%
- **Recall:** 7%
- **Accuracy:** 53%
- **False negatives (should-trigger, did not fire):**
  - How do I turn jira ticket into an Agent OS spec
  - How do I turn this issue https://github.com/myorg/myrepo/issues/42 into a spec
  - How do I turn this ticket https://mycompany.atlassian.net/browse/PROJ-1234 into an Agent OS spec
  - How do I turn GitHub issue #42 into an Agent OS spec
  - Should I commit the agent-os directory in my project to git?
  - I dont know what to do now that I installed agent-os
  - I just installed agent-os and need to write my first standard. Where do I start?
  - How do I make a new corporate or enterprise standard?
  - What should be in ~/agent-os/config.yml for inheritance to work?
  - My Agent OS spec for the auth feature is wrong. How do I recover without losing history?
- **False positives:** none
- **Decision:** _update after review_

## Functional evals

Tests whether the skill produces correct output. Two cases.

### Case 1 — `explain-inheritance-uses-correct-file`

**Prompt:** How does profile inheritance work in Agent OS? Where do I configure that
one profile inherits from another?

**What it verifies:**
- The answer names `~/agent-os/config.yml` as the inheritance file.
- The answer references the `inherits_from` field.
- The answer states that child overrides parent on filename collision.
- The answer does NOT recommend `profile-config.yml`.
- The answer flags `profile-config.yml` as a v2 artifact if it surfaces.

### Case 2 — `recover-broken-spec-without-losing-history`

**Prompt:** I ran `/shape-spec` on a feature an hour ago and the spec it produced is
wrong. I don't want to throw away the conversation history. How do I recover?

**What it verifies:**
- The answer distinguishes shape, plan, standards, and drift as failure layers.
- The answer recommends preserving history rather than starting over.
- The answer suggests editing the spec file directly or re-running `/shape-spec`
  with refined inputs.
- The answer does not invent commands or flags that are not in
  `references/commands.md`.

### Functional eval results

_Pending first run._

## Acceptance criteria coverage

| Criterion | Verified by |
|---|---|
| Skill loads in Claude Code without validation errors | Manual: `ls`, frontmatter check |
| Description triggers reliably on assist/help/install/ticket queries | Trigger evals (target 95%) |
| Skill does NOT trigger on profile-critique or generic queries | Trigger evals (should-not-trigger) |
| Skill names ~/agent-os/config.yml for inheritance | Functional case 1 |
| Skill does not invent commands or flags | Functional case 2 |
| No em-dashes; imperative voice throughout | Manual: `grep -n '—'` |

## How to update this report

After each run, replace the corresponding "_Pending first run._" block with the
actual numbers and observations.
