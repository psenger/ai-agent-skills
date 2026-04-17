# README Template

A fillable skeleton. Delete sections that don't apply — don't leave empty ones.

---

```markdown
<div align="center">

# {Project Name}

**{One-sentence tagline: what it is + who it's for. 10–15 words.}**

{Badges — all on one line, only if meaningful:}
[![CI](https://github.com/USER/REPO/actions/workflows/ci.yml/badge.svg)](https://github.com/USER/REPO/actions)
[![npm](https://img.shields.io/npm/v/PKG.svg)](https://www.npmjs.com/package/PKG)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE)

[Features](#features) • [Quick Start](#quick-start) • [Installation](#installation) • [Usage](#usage) • [Configuration](#configuration)

</div>

---

{Hook paragraph — 2 to 4 sentences. Answer: what it does, who it's for, why it
exists. Concrete, not marketing. If the project has a screenshot or demo GIF,
place it right after this paragraph.}

## Installation

```bash
{single primary install command — the one most users will use}
```

{If there are alternative install methods — Homebrew, Docker, from source —
list them in a short sub-block. Otherwise skip.}

## Quickstart

{Minimum code needed to see the thing work. Aim for a block the reader can
copy-paste and get a real result from in under a minute.}

```{language}
{the code}
```

{One or two sentences explaining what just happened and pointing to the next
step — usually "see Usage below" or "see full docs at <link>".}

## Usage

{The 80%-case workflow. One good, realistic example. Show input and expected
output if the tool produces output.}

```{language}
{example}
```

{If there are a handful of common recipes, list them as subsections. If there
are many, link out to an examples directory or docs site.}

## Configuration

{Only if there's anything to configure. Document environment variables, config
file location and format, or CLI flags. Table format works well:}

| Option | Default | Description |
|---|---|---|
| `FOO_API_KEY` | _(required)_ | API key from https://... |
| `FOO_TIMEOUT` | `30s` | Request timeout |

## {Feature-specific sections}

{If the project has a couple of distinct capabilities worth separate
treatment — e.g. "Using the CLI" and "Using as a library" — give each its own
section. Don't force this structure if it doesn't fit.}

## Development

{Only if you want contributors. Keep it short; link to CONTRIBUTING.md for
detail.}

```bash
git clone https://github.com/USER/REPO.git
cd REPO
{install dev deps}
{run tests}
```

See [CONTRIBUTING.md](./CONTRIBUTING.md) for the full development guide.

## Roadmap

{Only include if you'll keep it current. Bullet list of concrete upcoming
items, or a link to a public project board / milestones page.}

## License

{License name} — see [LICENSE](./LICENSE) for details.

## Acknowledgments

{Only if you're standing on specific shoulders. Credit forked projects, papers
the work is based on, key contributors, sponsors.}

---

<div align="center">

**{One punchy closing line — what this project is for or who built it.}**

[Report Bug](https://github.com/USER/REPO/issues) • [Request Feature](https://github.com/USER/REPO/issues) • [Documentation](https://github.com/USER/REPO#readme)

</div>
```

---

## Notes on filling this in

- **Centered header**: use the `<div align="center">` block for the title, tagline, badges, and nav links. Close with `</div>` then a `---` separator before the hook paragraph. GitHub renders this cleanly; it gives the page a polished landing-page feel without any custom CSS.
- **Centered footer**: mirror the header with a closing `<div align="center">` block after the last content section. A bold one-liner ("Built for X" or "Made by Y") and 2–3 action links (Report Bug, Request Feature, Documentation). Bookends the page and gives skimmers a call to action.
- **Tagline**: goes bold (`**...**`) inside the centered block — not a blockquote. Try the format: "A {kind of thing} for {audience} that {distinctive benefit}." Then cut whatever feels like marketing.
- **Nav links**: list the 4–6 most important sections as anchor links separated by `•`. Omit sections that don't exist in this README.
- **Hook paragraph**: if you can't write it without using the words "powerful", "seamless", or "cutting-edge", you don't yet understand the project well enough. Go back to intake.
- **Quickstart vs. Usage**: Quickstart is the five-second win ("see it work"). Usage is the real thing ("here's how you'd actually use it"). Small projects can merge them; larger ones shouldn't.
- **Badges**: put them on one line, not stacked. Each badge should carry information a prospective user cares about. No "made with Python" badges.
- **Table of Contents**: skip for most READMEs. GitHub renders a heading outline on the right. Only add a manual TOC for very long documents (500+ rendered lines).
