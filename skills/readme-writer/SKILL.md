---
name: readme-writer
description: Generate polished, well-structured README.md files for software projects. Use this skill whenever the user wants to write, create, draft, generate, update, improve, or rewrite a README — including phrasings like "write a readme", "document this project", "make a readme for my repo", "the readme is terrible, fix it", or "I need docs for this package". Also triggers when a user shares a repo or codebase and asks for documentation, a project description, a GitHub landing page, or a "getting started" doc. Do NOT use for general markdown writing unrelated to project READMEs (e.g. blog posts, changelogs, design docs).
allowed-tools: Read, Grep, Write, Edit
---

# README Writer

Produce README.md files that help a reader decide, in under thirty seconds, whether the project is worth their time — and then help them use it successfully.

A good README is a conversion funnel: **headline → understand → install → first success → deeper docs.** Every section either moves the reader along that funnel or earns its keep in some other way (badges signal trust, license reassures lawyers). Sections that don't serve the reader get cut.

## Workflow

Follow these steps in order. Don't skip the intake — a README written without knowing the project is a Mad Libs page of plausible nonsense.

### 1. Intake — learn the project before writing anything

Gather three kinds of information: **what can be auto-detected**, **what must be asked**, and **what lives in the code**.

**Auto-detect by inspecting the repo.** If you have filesystem access, look for:

- `package.json` — Node project. Read `name`, `description`, `version`, `scripts`, `dependencies`, `bin`, `main`/`exports`, `engines`, `repository`, `license`, `keywords`.
- `pyproject.toml` / `setup.py` / `setup.cfg` — Python project. Read project name, deps, entry points, Python version constraints.
- `Cargo.toml` — Rust crate. Read `[package]` metadata.
- `go.mod` — Go module. Read module path and Go version.
- `Gemfile` / `*.gemspec` — Ruby.
- `composer.json` — PHP.
- `pubspec.yaml` — Dart/Flutter.
- `Dockerfile`, `docker-compose.yml` — containerized service.
- `.github/workflows/*` — CI signals (test, build, deploy).
- `LICENSE` / `LICENCE` — license file.
- `CHANGELOG.md`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md` — existing docs to link to rather than duplicate.
- `src/`, `lib/`, `cmd/`, `app/` layout — informs project shape.
- An existing `README.md` — always read it first. If it exists, you're rewriting, not replacing; preserve anything still accurate (correct install commands, working examples, the project's actual voice).

**Classify the project.** The shape of the README depends on what kind of thing this is:

| Project type | Signals | README emphasis |
|---|---|---|
| **Library / SDK** | exports modules, published to a registry | Install → import → 1-line "hello world" → API reference link |
| **CLI tool** | `bin` field, shebang scripts, `cmd/` | Install → `tool --help` output → common recipes |
| **Web app / service** | Dockerfile, server framework, `app/` | What it does → run locally → deploy → configure |
| **Framework / starter** | template structure, generator scripts | Create a project → file layout → extend it |
| **Dev tool / plugin** | plugs into another tool (ESLint, VSCode, Webpack) | Requirements → install → configure in host → what it changes |
| **Dataset / model** | data files, model weights, notebooks | What it is → schema/format → load it → cite it |
| **Educational / demo** | tutorial structure, step folders | What you'll learn → prerequisites → run each step |

If you're unsure, ask the user directly — one question ("Is this a library people import, a CLI they run, or a service they deploy?") beats guessing.

**Ask the user for what only they know.** Batch the questions so the user answers once, not five times:

- One-sentence tagline (the "what it is, for whom" line under the title)
- Why it exists / what problem it solves (only if not obvious from code)
- Target audience (beginners? experienced X developers? internal team?)
- Current status (alpha / beta / stable / maintenance / archived)
- Anything unusual (non-obvious dependencies, required accounts, paid APIs, platform restrictions)

Skip questions you can answer from the code. If `package.json` says `"description": "A CLI for managing dotfiles"`, don't ask what the project does.

### 2. Structure — pick sections from the menu, don't use all of them

A README is not a checklist to complete. **Include only sections that earn their place.** Default skeleton:

```markdown
<div align="center">

# Project Name

**One-line tagline — bold, not a blockquote.**

[![CI](...)](#) [![version](...)](#) [![License](...)](#)

[Features](#features) • [Quick Start](#quick-start) • [Installation](#installation) • [Usage](#usage)

</div>

---

Brief paragraph: what it does, who it's for, why it's different. 2–4 sentences.

## Installation
## Quickstart  (or: Usage)
## [Feature-specific sections as needed]
## Configuration  (if there's anything to configure)
## Development  (if contributors are welcome)
## License
```

The `<div align="center">` block is the standard header pattern. It centers the title, tagline, badges, and nav links on GitHub without any custom CSS. Always close `</div>` before the `---` separator. Leave a blank line between each element inside the div. Nav links should cover the 4–6 most important sections, separated by ` • `.

Mirror it with a **closing footer block** after the last content section:

```markdown
---

<div align="center">

**One punchy closing line — what the project is for.**

[Report Bug](#) • [Request Feature](#) • [Documentation](#)

</div>
```

The footer bookends the page and gives skimmers a call to action. Keep it to one bold line and 2–3 links.

**Conditional sections** — include only when they apply:

- **Table of Contents** — only if the README is long enough that scrolling is painful (roughly 500+ lines rendered). GitHub auto-generates one from headings; don't duplicate it for shorter READMEs.
- **Features** — only if the feature list tells the reader something the tagline and quickstart don't already. Three features that hint at scope are better than ten bullet points of marketing.
- **Screenshots / demo GIF** — mandatory for anything visual (UI, CLI with pretty output, visualization library). Place near the top, right after the tagline.
- **Prerequisites** — only if non-obvious. "Requires Node 18+" is worth mentioning; "requires a computer" is not.
- **API Reference** — link to hosted docs rather than dumping it inline. If there are no hosted docs and the API is small, a compact reference section is fine.
- **Examples** — one great example inline; link out for more. A separate `/examples` directory in the repo is often better than a wall of code in the README.
- **FAQ** — only if there are actually questions people keep asking. Don't invent them.
- **Roadmap** — only if there's a public one you intend to keep current. A stale roadmap is worse than no roadmap.
- **Contributing** — link to `CONTRIBUTING.md` if it exists; otherwise a short section is fine. Don't copy-paste a generic contributor boilerplate that says nothing.
- **Acknowledgments / Credits** — include if you're standing on specific shoulders (a paper, a forked project, key contributors).

For the full skeleton with recommended phrasings, see `references/template.md`. For section-by-section good/bad examples, see `references/examples.md`.

### 3. Write — follow these principles

**Lead with the hook.** The first three lines decide whether the reader keeps going. After the title, the tagline and opening paragraph need to answer: *what is this, who is it for, why should I care?* Do not start with "Welcome to the XYZ repository." Do not start with a history lesson.

**Code before prose.** For any install/usage/example section, show the code first, explain second. Readers scan for code blocks; prose above them often goes unread. Compare:

> Bad: "In order to install this package, you can use npm by running the following command in your terminal:"
> Good: just the code block, then a one-line caption if needed.

**Examples must actually run.** Every code block a reader might copy should work if pasted verbatim. Use realistic (not placeholder) values where possible. If you're inventing an example because you don't know the real API, **ask** — don't fabricate.

**Be specific.** "Fast" is not a feature. "Processes 10k rows/sec on a MacBook Air M1" is. If you don't have numbers, cut the adjective.

**One good example beats three mediocre ones.** Pick the 80% case and nail it.

**Cut marketing.** "Revolutionary", "powerful", "seamless", "cutting-edge", "next-generation" — these words appear in every bad README and signal nothing. Describe what the thing does.

**Link out for depth.** The README is a landing page, not a manual. Link to: full API docs, deployment guides, architecture notes, design decisions, security policy, changelog.

**Use relative links for in-repo files.** `[See CONTRIBUTING](./CONTRIBUTING.md)`, not an absolute URL that'll break on forks.

**Badges are signals, not decorations.** Include them only when they carry information: build status, version, coverage, license, package downloads. Skip badges for "made with love" or the tenth social link. Place them on a single line under the tagline.

**Headings are a table of contents.** A reader should understand the shape of the document from headings alone. Use sentence case, keep them short, don't repeat the project name in every heading.

### 4. Output

Write the file to the project root as `README.md` — or to wherever the user indicated. If rewriting an existing README, **show the diff or the new full version and ask before overwriting**; an unannounced overwrite of someone's README is a bad surprise.

If the user is in a chat context without filesystem access, return the README as a single markdown code block they can copy.

## Style notes

- Use sentence case in headings: "Getting started", not "Getting Started".
- Prefer active voice: "Install with npm" over "The package can be installed using npm".
- Second person ("you") is fine and usually better than passive voice.
- Keep line lengths reasonable in the source (80–100 chars) — it reads better in diff views.
- Use fenced code blocks with language tags (```` ```bash ````, ```` ```python ````) for syntax highlighting.
- For shell commands, don't include the `$` prompt character — it breaks copy-paste.
- Emoji in headings: use at most one decorative emoji in the title line; after that, let it go. Sprinkling 🚀✨🎉 through a README looks dated and obscures scanning.

## Common failure modes to avoid

- **Template residue.** Leaving "TODO: add description" or "Project Name" unfilled. Scan the final file for any placeholder before declaring it done.
- **Fabricated APIs.** Writing `import { doTheThing } from 'my-package'` without checking what the package actually exports. If the code isn't in front of you, ask; don't invent.
- **Out-of-date install commands.** If the repo ships as an npm package, the install command is whatever's in `package.json`'s `name`, not a guess.
- **License mismatch.** If `LICENSE` says MIT, don't write "Apache-2.0" in the README. Read the file.
- **Broken relative links.** Double-check every `./foo.md` link points to a file that exists.
- **Walls of ASCII art / logos.** A tasteful banner image is fine; six screens of figlet output is not.

## Reference files

- `references/template.md` — a fillable skeleton with commentary on each section. Read when you need a starting structure or want to check section wording.
- `references/examples.md` — side-by-side good-vs-bad examples for the hook, features list, install section, and usage section. Read when a draft feels generic and you need a pattern to pattern-match against.
