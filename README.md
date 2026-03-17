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
| **[agentic-skeleton-dir-structure](skills/agentic-skeleton-dir-structure/)** | `/agentic-skeleton-dir-structure` | Scaffolds production-ready directory structures for agentic AI projects using Agent-OS v3 (Builder Methods) — supports single repos, mono-repos, multi-language repos, any platform, any language |
| **[git-commit-pr-message](skills/git-commit-pr-message/)** | `/git-commit-pr-message` | Generates Conventional Commits messages, PR titles/descriptions, and Keep a Changelog v1.1.0 entries — with sensitive content scanning, GitHub/Jira ticket linking, and release workflow |
| **[design-critique](skills/design-critique/)** | `/design-critique` | Structured design critique and plan stress-testing — acts as a relentless interviewer using pre-mortem, red teaming, and ATAM techniques to challenge technical architectures, product plans, and feature designs exhaustively |

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

### agentic-skeleton-dir-structure

Your project scaffolding assistant. Interactively builds production-ready directory structures for agentic AI projects, with [Agent-OS v3](https://github.com/buildermethods/agent-os) by Builder Methods and [Spec-Driven Development (SDD)](https://buildermethods.com/library/spec-driven-development-claude-code) baked in.

**How it works:**

1. **Detects context** — checks if the current directory already has files and warns you before overwriting anything
2. **Asks 6 questions** (one at a time) — repo pattern, platform type, languages, IaC tool, target platform, agent tooling
3. **Shows a summary table** and waits for your confirmation before creating anything
4. **Scaffolds everything** — directories, `CLAUDE.md`, `.claude/` config, `agent-os/` structure, IaC layout, seed files
5. **Guides next steps** — Agent-OS installation, `/plan-product`, and the SDD workflow loop

**Supports any combination of:**

| Dimension | Options |
|---|---|
| Repo pattern | Single Repo, Mono-Repo, Multi-Language Mono-Repo |
| Platform | Frontend, Backend, Full-Stack, Middleware, Agents/AI |
| Language | TypeScript, Python, Go, Java, Rust, Ruby, C#, and more |
| IaC | Terraform, Pulumi, CDK, Bicep, CloudFormation, Helm, Ansible |

**What gets created:**

- `CLAUDE.md` — project instructions loaded every Claude Code session
- `.claude/` — agents, skills, commands, hooks directories
- `agent-os/` — standards, specs, product context (mission, roadmap, tech stack)
- `src/` or `apps/` + `packages/` — language-specific source layout
- `iac/` — IaC structure matching your chosen tool
- `deploy/` — CI/CD pipelines, Docker, deploy scripts
- `docs/` — architecture decision records, API docs, runbooks

```
agentic-skeleton-dir-structure/
├── SKILL.md                          Interactive workflow + quality checklist
├── references/
│   ├── repo-patterns.md              Language + platform source layouts (7 languages)
│   ├── iac-patterns.md               IaC by tool (7 tools) + CI/CD + env promotion
│   └── agent-os-guide.md             Agent-OS install, SDD methodology, commands
└── examples/
    ├── single-repo-typescript.md     Completed single repo TypeScript API scaffold
    └── mono-repo-fullstack.md        Completed mono-repo full-stack scaffold
```

### git-commit-pr-message

Your commit and PR workflow assistant. Generates professional git commit messages, pull request titles and descriptions, changelog entries, and handles releases — all following industry-standard conventions.

**What it does:**

1. **Scans for sensitive content** (API keys, tokens, passwords, private keys) — mandatory gate before any commit
2. **Asks for ticket references** — supports GitHub Issues (all 9 closing keywords) and Jira (pattern-matched ticket keys)
3. **Generates commit messages** — Conventional Commits format with type, scope, subject, body, and footer
4. **Updates CHANGELOG.md** — Keep a Changelog v1.1.0 with all six section types (Added, Changed, Deprecated, Removed, Fixed, Security)
5. **Creates pull requests** — via `gh` CLI or GitHub MCP, with summary, ticket links, changes, and test plan
6. **Cuts releases** — renames Unreleased to versioned section, adds comparison links, optionally creates git tags

**Key features:**
- Conventional Commits with type, scope, and imperative mood enforcement
- All 9 GitHub closing keywords (`close/closes/closed`, `fix/fixes/fixed`, `resolve/resolves/resolved`)
- Jira ticket key detection by pattern (`PROJ-1234`) — no prefix needed
- Keep a Changelog v1.1.0 with comparison links at bottom of file
- Sensitive content scanning with line-level reporting
- User confirmation gates — never commits, pushes, or creates PRs without asking
- Skills v2.0 compliant with `disable-model-invocation`, `allowed-tools`, `argument-hint`

```
git-commit-pr-message/
├── SKILL.md                          Workflow (9 steps) + behavioural rules
└── references/
    └── examples.md                   Commit, PR, changelog, ticket, and scan examples
```

### design-critique

Your design review sparring partner. Stress-tests technical architectures, product plans, and feature designs using structured interviewing techniques drawn from pre-mortem analysis, red teaming, and ATAM (Architecture Tradeoff Analysis Method).

**What it does:**

1. **Orients silently** — explores the codebase or relevant files before asking anything
2. **Anchors the session** — establishes scope with a single opening question
3. **Drills relentlessly** — one question at a time, following the highest-risk thread first
4. **Surfaces hidden assumptions** — names what's unstated and forces trade-off articulation
5. **Closes with a summary** — what held up, what didn't, and what needs resolution before proceeding

**Question patterns it uses:**

| Pattern | Purpose |
|---|---|
| What happens when X fails? | Failure modes |
| What does the alternative look like? | Trade-off articulation |
| How would you know if this is wrong? | Falsifiability |
| What's the cost of reversing this? | Reversibility |
| Walk me through the worst case | Pre-mortem |
| What quality attribute does this sacrifice? | ATAM tradeoff probe |

**Skills 2.0:** `allowed-tools: Read Grep Glob` — `argument-hint: [topic, file, or artifact to critique]` — auto-invokes on trigger phrases; no external tools required

```
design-critique/
└── SKILL.md                          Interviewing principles, question patterns, session flow
```

---

## Installation

### Via npx (works with Claude Code, Codex, Cursor)

Install all skills:

```bash
npx skills add psenger/ai-agent-skills
```

List all available skills:

```bash
npx skills list psenger/ai-agent-skills
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

### vault-scribe

```
/vault-scribe article
/vault-scribe meeting
/vault-scribe brainstorming
/vault-scribe strategy
/vault-scribe deep-research
```

Or describe what you need — the skill triggers on context:

```
"Turn this transcript into an Obsidian note"
"Write up meeting notes from today's standup"
"Create a strategy doc for the Q3 roadmap"
```

### agentic-skeleton-dir-structure

```
/agentic-skeleton-dir-structure
/agentic-skeleton-dir-structure single
/agentic-skeleton-dir-structure mono
/agentic-skeleton-dir-structure multi-lang
```

Or describe what you need — the skill triggers on context:

```
"Set up a new project for an agentic AI service"
"Scaffold a mono-repo for my full-stack TypeScript app"
"Create a directory structure for this project"
"Initialize an Agent-OS project layout"
```

Pass a repo pattern as an argument to skip the first question. Without arguments, the skill walks you through all six questions interactively.

### git-commit-pr-message

```
/git-commit-pr-message commit
/git-commit-pr-message pr
/git-commit-pr-message changelog
/git-commit-pr-message release
```

Or describe what you need — the skill triggers on context:

```
"Commit these changes"
"Create a PR for this branch"
"Update the changelog"
"Cut a release for v1.2.0"
```

Note: This skill has `disable-model-invocation: true`, so it will only activate when you explicitly invoke it — it will never auto-trigger during normal conversation.

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
