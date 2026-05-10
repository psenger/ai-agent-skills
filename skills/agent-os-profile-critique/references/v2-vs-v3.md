# v2 vs v3

Agent OS v3 was released January 2026. The differences below matter for migration and for spotting v2 artifacts during a review.

## Key differences

| Area | v2 | v3 |
|---|---|---|
| Subagents | `.claude/agents/agent-os/` installed | Retired. Frontier models handle it |
| Spec writing | Dedicated implementation commands | Plan mode + `/shape-spec` |
| Profile inheritance | `profile-config.yml` inside each profile | `config.yml` at `~/agent-os/` root |
| Standards discovery | Manual | `/discover-standards` |
| Index maintenance | Manual | `/index-standards` |
| Profile sync | Manual copy | `~/agent-os/scripts/sync-to-profile.sh` |
| Profile contents | `standards/`, `agents/`, `commands/`, `workflows/` | `standards/` only |

## Migrating from v2

1. Remove v2 artifacts:
   ```bash
   rm -rf .claude/agents/agent-os/
   rm -rf .claude/commands/agent-os/
   ```
2. Reinstall v3 commands without disturbing standards:
   ```bash
   ~/agent-os/scripts/project-install.sh --commands-only
   ```
3. Move inheritance config from per-profile `profile-config.yml` files into the root `~/agent-os/config.yml`:
   ```yaml
   version: 3.0.0
   default_profile: my-app
   profiles:
     my-app:
       inherits_from: rails-base
   ```
4. Delete the `profile-config.yml` files and any `agents/` / `commands/` / `workflows/` subdirs inside each profile.
5. Standards files, specs, and product docs transfer **without modification**.

## How to spot a v2 install during a review

Any of these is a v2 leftover:

- A `profile-config.yml` anywhere under `~/agent-os/profiles/`
- `agents/`, `commands/`, or `workflows/` subdirs inside a profile
- `.claude/agents/agent-os/` in a project
- `~/agent-os/config.yml` missing or with `version` below `3.0.0`

When you see these, recommend the migration steps above before doing any other audit work. Most other findings depend on a clean v3 baseline.
