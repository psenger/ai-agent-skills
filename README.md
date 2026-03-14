<p align="center">
  <h1 align="center">ai-agent-skills</h1>
  <p align="center">
    A curated collection of production-ready AI agent skills<br/>
    for Claude Code, Codex, Cursor, and any tool that supports the<br/>
    <a href="https://agentskills.io/specification">Agent Skills Open Standard</a>.
  </p>
  <p align="center">
    <a href="https://github.com/psenger/ai-agent-skills/blob/main/LICENSE"><img src="https://img.shields.io/github/license/psenger/ai-agent-skills?style=flat-square" alt="License"></a>
    <a href="https://github.com/psenger/ai-agent-skills/issues"><img src="https://img.shields.io/github/issues/psenger/ai-agent-skills?style=flat-square" alt="Issues"></a>
    <a href="https://github.com/psenger/ai-agent-skills/stargazers"><img src="https://img.shields.io/github/stars/psenger/ai-agent-skills?style=flat-square" alt="Stars"></a>
  </p>
</p>

---

## What Is This?

**ai-agent-skills** is a library of reusable skills that teach AI coding agents _how_ to do specialised tasks — consistently, every time. Each skill is a self-contained folder with structured instructions, reference material, and examples that an agent loads on demand.

Think of it as a playbook: you define the process once, and the agent follows it whenever the task comes up.

---

## Skills

| Skill | Type | Description |
|---|---|---|
| **[vault-scribe](skills/vault-scribe/)** | `/vault-scribe` | Converts transcripts, meeting notes, brainstorming sessions, strategy docs, and rough notes into polished Obsidian vault Markdown — GitHub-compatible by default, with type-aware frontmatter schemas |

### vault-scribe

Your Obsidian vault assistant. Turns unstructured input into well-organised, searchable notes with proper YAML frontmatter, callout blocks, and consistent formatting.

**Supports five note types:**

| Note Type | Use Case |
|---|---|
| `article` | Knowledge base articles, guides, reference docs |
| `meeting` | Meeting notes, 1:1s, standups, retrospectives |
| `brainstorming` | Ideation sessions — solo with AI, one-on-one, or group |
| `strategy` | Versioned plans, OKRs, and living strategy documents |
| `deep-research` | In-depth investigations with multiple sources |

**Key features:**
- GitHub-Flavored Markdown first, Obsidian extensions when needed
- Type-aware YAML frontmatter with enforced schemas
- Automatic transcript appendix formatting
- GFM Alerts for cross-platform callout blocks
- Quality checklist validation before output
- Reference files for frontmatter schemas, callout types, embed syntax, and Markdown compatibility

```
vault-scribe/
├── SKILL.md                          Workflow + quality checklist
├── references/
│   ├── FRONT-MATTER.md               Frontmatter schemas for all note types
│   ├── CALLOUTS.md                   GFM Alerts + Obsidian callout reference
│   ├── EMBEDS.md                     Image + embed syntax (GFM + Obsidian)
│   └── MARKDOWN-SYNTAX.md           Links, tags, math, diagrams, footnotes
└── examples/
    ├── article-example.md            Article with callouts + code blocks
    ├── meeting-brainstorm-example.md  Brainstorming session
    └── transcript-example.md         Article with transcript appendix
```

---

## Installation

### Via npx (works with Claude Code, Codex, Cursor)

Install all skills:

```bash
npx skills add psenger/ai-agent-skills
```

Install a specific skill:

```bash
npx skills add psenger/ai-agent-skills --skill vault-scribe
```

Install locally for customisation:

```bash
npx skills add psenger/ai-agent-skills --skill vault-scribe --local
```

### Via Claude Code Marketplace

```bash
claude plugin marketplace add psenger/ai-agent-skills
claude plugin install vault-scribe@psenger-skills-marketplace
```

### Manual Installation

Clone the repo and copy the skill folder:

```bash
# Global (available in all projects)
cp -r skills/vault-scribe ~/.claude/skills/vault-scribe

# Local (project-specific)
cp -r skills/vault-scribe .claude/skills/vault-scribe
```

> **Global vs Local**
>
> **Global** (`~/.claude/skills/`) — skills that apply everywhere.
> **Local** (`.claude/skills/`) — project-specific customisations. Local skills override global skills of the same name.

---

## Usage

Once installed, skills activate automatically based on your request. You can also invoke them directly:

```
/vault-scribe article
/vault-scribe meeting
/vault-scribe brainstorming
/vault-scribe strategy
/vault-scribe deep-research
```

Or just describe what you need — the skill triggers on context:

```
"Turn this transcript into an Obsidian note"
"Write up meeting notes from today's standup"
"Help me brainstorm caching strategies"
"Create a strategy doc for the Q3 roadmap"
```

---

## Adding a New Skill

1. Create a folder under `skills/` with a lowercase-hyphenated name
2. Add a `SKILL.md` with YAML frontmatter and process instructions
3. Add reference files in `references/` if needed
4. Add examples in `examples/` for better activation rates
5. Add an entry to `.claude-plugin/marketplace.json`
6. Update this README table
7. Open a pull request

```
skills/<skill-name>/
├── SKILL.md              Required — metadata + instructions
├── references/            Optional — detailed reference material
└── examples/              Optional — example input/output pairs
```

---

## Author

**Philip A Senger**

- GitHub: [@psenger](https://github.com/psenger)

---

## License

This project is licensed under the [MIT License](LICENSE).

Copyright (c) 2026 Philip A Senger
