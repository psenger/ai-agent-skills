# File Structure

Agent OS lives in two places: a **base installation** on the machine and a **project installation** in each repo.

## Base installation `~/agent-os/`

```
~/agent-os/
  commands/
    agent-os/                   # 5 slash command .md files (source)
      discover-standards.md
      index-standards.md
      inject-standards.md
      plan-product.md
      shape-spec.md
  profiles/
    <profile-name>/
      standards/                # .md standards files only. No profile-config.yml in v3.
  scripts/
    project-install.sh
    sync-to-profile.sh
    common-functions.sh
  config.yml                    # version, default_profile, profiles: (inheritance)
```

## Project installation `your-project/`

```
your-project/
  agent-os/
    standards/
      <domain>/
        <standard>.md
      index.yml                 # Index for matching
    specs/
      YYYY-MM-DD-HHMM-<slug>/
        plan.md
        shape.md
        standards.md
        references.md
        visuals/
    product/
      mission.md
      roadmap.md
      tech-stack.md
  .claude/
    commands/
      agent-os/                 # 5 slash command .md files (copied from base)
        discover-standards.md
        index-standards.md
        inject-standards.md
        plan-product.md
        shape-spec.md
```

## What to commit

| Path | Commit? | Reason |
|---|---|---|
| `agent-os/standards/` | Yes | Share conventions with the team |
| `agent-os/product/` | Yes | Share product context |
| `agent-os/specs/` | Yes | Preserve project history |
| `.claude/commands/agent-os/` | Optional | Team can regenerate from base install with `--commands-only` |

`.claude/commands/agent-os/` is a copy of the source commands; some teams prefer to commit it for reproducibility, others gitignore it.

## Things that should NOT exist in v3

If you see any of these, flag them as v2 leftovers:

- `.claude/agents/agent-os/` (subagents, retired)
- `~/agent-os/profiles/<name>/profile-config.yml` (inheritance moved to `config.yml`)
- `~/agent-os/profiles/<name>/agents/`
- `~/agent-os/profiles/<name>/commands/`
- `~/agent-os/profiles/<name>/workflows/`
