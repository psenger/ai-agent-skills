# Getting Started

Pick the section that matches the user's situation. Each one is a self-contained walkthrough.

| Situation | Section |
|---|---|
| Brand new machine, no Agent OS yet | [1. Bootstrap from zero](#1-bootstrap-from-zero) |
| Just cloned a repo that already uses Agent OS | [2. Joining a repo that has Agent OS](#2-joining-a-repo-that-has-agent-os) |
| Have a Jira / GitHub / Linear ticket, want to plan and execute | [3. From ticket to executed spec](#3-from-ticket-to-executed-spec) |
| A spec was generated badly, or implementation drifted | [4. Recovering a spec that went wrong](#4-recovering-a-spec-that-went-wrong) |
| Long task, context window filling up | [5. Saving context with the LLM effectively](#5-saving-context-with-the-llm-effectively) |

---

## 1. Bootstrap from zero

The user has nothing installed.

**Step 1. Install the base.**

```bash
cd ~
git clone https://github.com/buildermethods/agent-os.git && rm -rf ~/agent-os/.git
```

**Step 2. Verify the base.**

```bash
cat ~/agent-os/config.yml          # confirm version: 3.0.0
ls ~/agent-os/profiles/            # see what profiles ship
ls ~/agent-os/commands/agent-os/   # confirm 5 .md files
```

**Step 3. Create a profile.**

If none of the shipped profiles fit, create one:

```bash
mkdir -p ~/agent-os/profiles/my-profile/standards
```

Edit `~/agent-os/config.yml`:
```yaml
version: 3.0.0
default_profile: my-profile
profiles:
  my-profile: {}
```

Drop 2 to 4 starter standards into `~/agent-os/profiles/my-profile/standards/`. Use the quality rules in `standards.md`.

**Step 4. Install into a project.**

```bash
cd /path/to/project
~/agent-os/scripts/project-install.sh --profile my-profile
```

**Step 5. First-time refinement.**

Run `/discover-standards` inside the project. It will surface tribal knowledge and prompt the user to confirm or skip each candidate. This is the fastest way to seed a useful profile.

If standards refined inside the project should propagate to the profile:
```bash
~/agent-os/scripts/sync-to-profile.sh
```

---

## 2. Joining a repo that has Agent OS

The user just cloned a repo that already has `agent-os/` and `.claude/commands/agent-os/`.

**Step 1. Confirm Agent OS is installed locally.**

```bash
test -d ~/agent-os && echo "ok" || echo "missing"
```

If missing, run the bootstrap from section 1 first. Without the base install, `sync-to-profile.sh` and `project-install.sh --commands-only` won't work.

**Step 2. Read the project's product context.**

If `agent-os/product/` exists, read `mission.md`, `roadmap.md`, and `tech-stack.md` before doing anything else. They frame every spec.

**Step 3. Read the standards index.**

```bash
cat agent-os/standards/index.yml
ls agent-os/standards/
```

Skim a handful of standards that look central to the work the user plans to do. Do not read all of them up front. Standards exist to be injected on demand.

**Step 4. Check command versions.**

If the slash commands look stale or behave oddly:
```bash
~/agent-os/scripts/project-install.sh --commands-only
```
This refreshes `.claude/commands/agent-os/` without touching standards.

**Step 5. Look at recent specs for tone.**

```bash
ls agent-os/specs/ | tail -5
```
Open one or two recent spec folders. Reading `shape.md` and `plan.md` from a recent feature shows the team's voice and depth of detail expected.

---

## 3. From ticket to executed spec

The user has a ticket in Jira, GitHub, Linear, or similar, and wants Agent OS to drive the work.

**Step 1. Pull the ticket content into context.**

Use the appropriate MCP or CLI to fetch the ticket. Examples:
- GitHub: `gh issue view <number>` or the GitHub MCP `issue_read`.
- Jira / Atlassian: the Atlassian Rovo MCP.
- Linear: the Linear MCP if available, otherwise paste the description.

Capture: title, description, acceptance criteria, linked tickets, attached visuals.

**Step 2. Confirm product alignment.**

If `agent-os/product/` exists, cross-check the ticket against `mission.md` and `roadmap.md`. Flag mismatches before planning. A ticket that conflicts with the roadmap is the user's call to escalate, not yours to silently reconcile.

**Step 3. Enter plan mode.**

```
/plan
```

**Step 4. Run /shape-spec.**

```
/shape-spec
```

Answer the shaping questions:
- What are we building? (paste ticket summary plus any clarifications)
- Visuals? (attach mockups, link Figma, paste screenshots)
- Reference code? (point at similar features already in the repo)
- Product alignment? (cite which roadmap item this serves)
- Which standards apply? (let auto-suggest run, then refine)

**Step 5. Review the plan.**

Task 1 of the plan saves the spec folder. Read the full plan before approving. If the plan misreads the ticket, fix it now: it is cheaper to revise the plan than to revise the implementation.

**Step 6. Approve and execute.**

After approval, the spec folder lands at `agent-os/specs/YYYY-MM-DD-HHMM-<slug>/` with `plan.md`, `shape.md`, `references.md`, `standards.md`. Implementation proceeds against this folder. The spec persists, so future sessions can pick up mid-implementation.

**Step 7. Link back to the ticket.**

Comment on the ticket with the spec folder path, or include it in the PR description. This closes the loop between the tracking system and Agent OS.

---

## 4. Recovering a spec that went wrong

Symptoms: the plan is wrong, the implementation drifted from the spec, scope crept, or the standards section is missing pieces.

**Step 1. Diagnose where it broke.**

Open the spec folder. Read in this order:
1. `shape.md`. Was the scope captured correctly? If not, the shaping conversation went wrong; everything downstream inherits that error.
2. `plan.md`. Does the plan match the shape? If shape is fine but the plan misreads it, the issue is at planning time.
3. `standards.md`. Are the right standards present? Missing standards explain "why does the code violate convention X" type drift.
4. The actual code changes vs. the plan. If shape and plan are sound but the code drifted, the failure is at implementation.

**Step 2. Choose a recovery path.**

| Where it broke | Recovery |
|---|---|
| Shape wrong | Re-enter plan mode, run `/shape-spec` again, save into a new dated folder. Mark the old folder superseded in its `shape.md`. Do not edit the old folder in place; preserve history. |
| Plan wrong, shape fine | Re-enter plan mode, paste the existing `shape.md`, ask for a new plan. Replace `plan.md` in the same folder. Note the revision at the top. |
| Missing standards | Run `/inject-standards <domain>` in plan mode, then re-run `/shape-spec` to refresh `standards.md`. |
| Code drifted from a sound plan | Treat as a normal code review. Compare diff to `plan.md`, list each deviation, decide each one as "accept and update plan" or "revert to match plan". |

**Step 3. Update the index if standards changed.**

If the recovery surfaced a missing or stale standard, run `/index-standards` so future auto-suggest works.

**Step 4. Capture the lesson.**

If the failure mode is likely to recur (e.g., shaping kept missing a constraint), add or refine a standard so the next spec catches it. This is how the system gets stronger over time.

---

## 5. Saving context with the LLM effectively

Agent OS is built around the idea that context is precious. These practices keep sessions productive across long tasks.

**Inject only what is needed.**

`/inject-standards` loads full standards content into context. Pull only the domains relevant to the current work. Resist `/inject-standards api/* db/* naming` when the task is one API endpoint.

**Prefer file references over embedded content for Skills.**

When `/inject-standards` is called inside Skill creation or plan mode, it offers two output formats:
- Embed the content (snapshot, self-contained, drifts as standards evolve).
- `@`-reference the files (always fresh, requires the project to have those standards).

For long-lived Skills used inside repos that have Agent OS, prefer references. Snapshots are appropriate when the Skill must work in repos without Agent OS installed.

**Persist decisions to specs, not to chat.**

Anything decided in a `/shape-spec` conversation lives in `shape.md` and survives session boundaries. Decisions made in regular chat evaporate when the context is compacted. If a discussion produces a real decision, capture it in the spec folder.

**Use the spec folder as the resume point.**

When returning to a feature mid-flight, do not re-explain it. Read `shape.md`, `plan.md`, and recent diffs. The spec is the handoff document.

**Compact when the conversation drifts.**

Long meandering threads bloat the context window with dead ends. When the path forward is clear, summarize the conclusions, save them to the spec folder if relevant, and start a fresh session pointed at the spec folder.

**Keep `index.yml` descriptions specific.**

Auto-suggest matching is only as good as the descriptions. A description like `"API stuff"` will either over-trigger (wasting context) or under-trigger (missing the standards that matter). Specific descriptions reduce wasted injection cycles.

**Treat the product folder as load-bearing.**

`mission.md`, `roadmap.md`, and `tech-stack.md` are short on purpose. They give every future spec a frame without burning context. Keep them current. Stale product docs poison every spec that reads them.
