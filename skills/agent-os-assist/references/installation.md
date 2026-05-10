# Agent OS Installation

Agent OS is a two-part install: a base at `~/agent-os/` and a per-project install under `<repo>/agent-os/`.

## Step 1 — Install the base

Clone the repo into your home directory:

```bash
git clone https://github.com/buildermethods/agent-os.git ~/agent-os
```

The base provides profiles, scripts, and the slash commands that get copied into projects.

## Step 2 — Install into a project

From inside any git repo, run:

```bash
bash ~/agent-os/scripts/project-install.sh
```

This creates two things in your repo:
- `agent-os/` — copied standards from your active profile
- `.claude/commands/agent-os/` — the five slash commands

### Options

| Flag | What it does |
|---|---|
| `--profile <name>` | Use a named profile instead of the default |
| `--commands-only` | Refresh commands only; leave existing standards untouched |
| `--verbose` | Show detailed output |

Example with a profile:
```bash
bash ~/agent-os/scripts/project-install.sh --profile node-express
```

## Verifying the install

After running the script, confirm these paths exist:

```
<repo>/agent-os/standards/        # your profile's standards
<repo>/.claude/commands/agent-os/ # the five slash commands
```

Check the active profile in `~/agent-os/config.yml`:

```yaml
version: 3.0.0
default_profile: default
```

## What gets committed

Commit both `agent-os/` and `.claude/commands/agent-os/` to version control. This keeps the team on the same standards and commands. See `references/file-structure.md` for the full layout.
