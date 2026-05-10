# Profiles

A **profile** is a named folder under `~/agent-os/profiles/<name>/` containing a `standards/` subfolder of `.md` files.

## Rules

- Any directory under `~/agent-os/profiles/` containing `standards/` is a valid profile. No registration step.
- The `profiles:` section in `~/agent-os/config.yml` only declares **inheritance**. Omitting a profile from `config.yml` means it stands alone.
- When inheriting, child profiles override parents file-by-file: same filename in both → child wins.
- Profiles in v3 contain **only `standards/`**. No `agents/`, no `commands/`, no `workflows/`, no `profile-config.yml`.

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
3. **Dedicated standards repo.** Clone into `~/agent-os/profiles/<name>/` and treat the profile as a versioned artifact.

Pattern 3 scales best for organizations.

## Auditing a profile

When asked to review `~/agent-os/profiles/<name>/`:

1. Confirm `standards/` exists with `.md` files
2. Flag any v2 artifacts (`agents/`, `commands/`, `workflows/`, `profile-config.yml`)
3. Read `~/agent-os/config.yml`. Verify `version: 3.0.0`; if `inherits_from` is set, verify the parent folder exists.
4. Apply the standards quality rules (see `standards.md`)
5. Flag standards that document obvious framework behavior
