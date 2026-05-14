# Profiles

A **profile** is a named folder under `~/agent-os/profiles/<name>/` (or inside an enterprise profiles repo) containing `.md` standards files.

## Rules

- Any directory under `~/agent-os/profiles/` containing standards content is a valid profile. No registration step.
- The `profiles:` section in `~/agent-os/config.yml` only declares **inheritance**. Omitting a profile from `config.yml` means it stands alone.
- When inheriting, child profiles override parents file-by-file: same filename in both → child wins.
- Profiles in v3 contain **standards content only**. No `agents/`, no `commands/`, no `workflows/`, no `profile-config.yml`.

## Two valid profile layouts

The audit accepts both layouts. See `file-structure.md` for full schemas.

- **Layout A1 — `standards/` wrapper.** Domain folders live under `<profile>/standards/<domain>/`. This is the canonical v3 layout and what `project-install.sh` reads from when building a project install.
- **Layout A2 — domain folders at profile root.** No `standards/` wrapper; domain folders sit directly under `<profile>/<domain>/`. This is the layout of the upstream `default` profile shipped with Agent OS.

A Layout-A2 profile cannot be installed by `project-install.sh` as-is (the script resolves `<profile>/standards/` and finds nothing). If the user intends to install a Layout-A2 profile, flag it.

## config.yml format

```yaml
version: 3.0.0
default_profile: my-rails-app
profiles:
  my-rails-app:
    inherits_from: rails-base
  rails-base:
    inherits_from: ruby-general
```

Three-level inheritance is fine; deeper chains start to be a smell.

### Inheritance coherence

A chain like `base → php → symfony` should flow **general to specific**. Configuration declares the chain; coherence is whether the content actually respects that direction. Common incoherence patterns:

- **Generality leak** — a root profile contains content specific to a single descendant's stack (e.g. `base` declares "PHP 5.4"). A future sibling Node.js child cannot inherit cleanly.
- **Override saturation** — a parent file is overridden by every descendant in the chain. The parent's version is dead weight; the file probably belongs in the children or in a deleted state.
- **Cross-level conflict** — a parent rule and a child rule are semantically incompatible. The override mechanism resolves it for the *known* child, but any future sibling that doesn't override inherits the wrong rule by default.

The audit reads the chain and surfaces these as findings in a dedicated `## Inheritance coherence` section. See `review-checklists.md` for the full procedure and contribution-map output format.

## Common naming patterns

- **By tech stack:** `rails`, `nextjs`, `django`, `go-services`
- **By client:** `client-acme`, `client-xyz`
- **By context:** `work`, `personal`, `consulting`

Pick one axis and stick with it. Mixing axes (`rails` next to `client-acme`) leads to confusion about which profile to pick for a new project.

## When to create a new profile vs. extend an existing one

Create a **new profile** when:
- The tech stack is materially different
- A client requires standards that conflict with your defaults
- You want a clean slate for experimentation

Extend (inherit from) an existing profile when:
- 70%+ of standards would be the same
- You only need to override a handful of conventions
- You want upstream changes to flow down

## Sharing profiles with a team

Three workable patterns:
1. **Commit `agent-os/standards/` per project.** Lowest setup cost, but duplication across repos.
2. **Shared profile name.** Every team member maintains the same profile name locally; sync via `sync-to-profile.sh`.
3. **Dedicated profiles repo (Target C).** A standalone git repo containing one or more profiles, cloned into `~/agent-os/profiles/`. See `file-structure.md` for the Target C schema.

Pattern 3 scales best for organizations.

## Auditing a profile

See `review-checklists.md` for the target-specific checklist. Profile source dirs are Target A; project installs are Target B; multi-profile enterprise repos are Target C.
