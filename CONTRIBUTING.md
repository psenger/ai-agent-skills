# Contributing

Thanks for your interest in contributing to **ai-agent-skills**. This guide covers the basics.

---

## How to Contribute

1. Fork the repository
2. Create a branch from `main` (`git checkout -b my-skill`)
3. Make your changes
4. Test locally (see below)
5. Open a pull request against `main`

Keep PRs focused — one skill or one change per PR.

---

## Adding a New Skill

Create a folder under `skills/` following this structure:

```
skills/<skill-name>/
├── SKILL.md              Required — YAML frontmatter + instructions
├── references/            Optional — detailed reference material
└── examples/              Optional — example input/output pairs
```

### Requirements

- **Directory name:** lowercase-hyphenated, max 64 characters (e.g. `vault-scribe`, `pr-review`)
- **SKILL.md frontmatter:** must include `name`, `description`, and `allowed-tools`
- **Description:** written in third person with trigger words ("Converts transcripts into..." not "Use this to convert...")
- **SKILL.md body:** under 500 lines — move detailed content to `references/`
- **Reference files:** one level deep from SKILL.md, no nested chains
- **No secrets:** never commit API keys, passwords, tokens, or PII

### After Creating the Skill

1. Add an entry to `.claude-plugin/marketplace.json`
2. Add a row to the skills table in `README.md`

---

## Modifying an Existing Skill

Before making changes, identify whether the issue is:

- **A process problem** — fix `SKILL.md` (wrong steps, missing steps, ambiguous instructions)
- **A knowledge problem** — fix reference files (outdated info, missing context, incorrect examples)
- **An activation problem** — fix the `description` field (too vague, too broad, missing trigger words)

---

## Testing Locally

Copy the skill to your local Claude Code skills directory:

```bash
# Project-level (overrides global)
cp -r skills/<skill-name> .claude/skills/<skill-name>

# Or global
cp -r skills/<skill-name> ~/.claude/skills/<skill-name>
```

Then invoke it with a realistic prompt and verify:

- The skill activates (not confused with another skill)
- Output follows the documented structure
- Frontmatter is valid YAML
- No bare URLs, proper callout blocks, etc.

---

## Reporting Issues

Open a [GitHub issue](https://github.com/psenger/ai-agent-skills/issues) with:

- The skill name
- The prompt you used
- What you expected
- What actually happened

---

## License

By contributing, you agree that your contributions will be licensed under the project's [MIT License](LICENSE).
