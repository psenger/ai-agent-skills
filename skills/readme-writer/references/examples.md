# README Examples — good vs bad

Side-by-side patterns. Read this when a draft feels generic and you need a
target to pattern-match against.

---

## Centered header block

### ❌ Bad

```markdown
# my-cli-tool

[![CI](https://img.shields.io/badge/build-passing-brightgreen)]()
[![License](https://img.shields.io/badge/license-MIT-blue)]()
[![npm](https://img.shields.io/npm/v/my-cli-tool)]()

A CLI tool for developers.
```

Why it's bad: badges are stacked (renders as a wall); the tagline is a
non-sentence ("A CLI tool for developers" — what does it do?); no nav
links; nothing draws the eye. It looks like boilerplate.

### ✅ Good

```markdown
<div align="center">

# my-cli-tool

**Scaffold, lint, and release Node.js projects from a single command.**

[![CI](https://github.com/USER/my-cli-tool/actions/workflows/ci.yml/badge.svg)](https://github.com/USER/my-cli-tool/actions)
[![npm](https://img.shields.io/npm/v/my-cli-tool.svg)](https://www.npmjs.com/package/my-cli-tool)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE)

[Features](#features) • [Quick Start](#quick-start) • [Installation](#installation) • [Configuration](#configuration)

</div>

---
```

Why it works: the `<div align="center">` block creates a clean landing-page
header on GitHub. The tagline is bold and answers "what does it do" in one
line. Badges are on a single line (not stacked). Nav links let skimmers jump
directly to the section they care about. The `---` separator provides a clean
visual break before the prose begins.

**Rules for the centered block:**
- Close `</div>` before the `---` separator, not after it
- Keep badges on one line — GitHub renders inline `img` tags side-by-side
- Nav links: 4–6 sections max, separated by ` • ` (space-bullet-space)
- Leave a blank line between each element inside the div so GitHub's Markdown
  parser renders them correctly

---

## The hook (title + tagline + opening paragraph)

### ❌ Bad

```markdown
# MyProject

Welcome to MyProject! This is a powerful, cutting-edge, next-generation
solution for handling your needs. Built with love using modern technologies,
MyProject aims to revolutionize the way you work.
```

Why it's bad: tells you nothing. Every empty word ("powerful", "cutting-edge",
"revolutionize") could apply to any project. After reading it you still don't
know what MyProject *does*.

### ✅ Good

```markdown
# ripgrep

> Recursively search directories for a regex pattern. Faster than grep, ag,
> and git grep.

ripgrep is a line-oriented search tool that respects your .gitignore by
default and skips binary files and hidden files. It's written in Rust on top
of the regex crate, and in most benchmarks it's the fastest general-purpose
search tool available.
```

Why it works: you know what it is (search tool), what's distinctive (fast,
respects .gitignore), and who the comparison group is (grep, ag, git grep),
all in three lines.

---

## Installation

### ❌ Bad

```markdown
## Installation

To get started with installing MyProject, you'll first need to make sure you
have all the prerequisites installed on your system. Then, you can proceed to
install MyProject using your preferred package manager. Below are the
instructions for different package managers:

### Using npm

If you're using npm as your package manager, you can install MyProject by
running the following command in your terminal:

```bash
$ npm install my-project
```
```

Why it's bad: three paragraphs of filler before the one command that matters.
The `$` prompt breaks copy-paste. "Your preferred package manager" is
bureaucratic padding.

### ✅ Good

```markdown
## Installation

```bash
npm install my-project
```

Also available via Homebrew (`brew install my-project`) and as a
[standalone binary](./releases).
```

Why it works: command first, alternatives in one compressed line, zero filler.

---

## Features list

### ❌ Bad

```markdown
## Features

- 🚀 Fast
- 💪 Powerful
- 🎨 Beautiful
- 🔒 Secure
- 📦 Easy to install
- ⚡ Lightning-quick
- ✨ Magical
- 🌈 Flexible
- 🎯 Accurate
- 💎 Reliable
```

Why it's bad: every bullet is an adjective, not a capability. "Fast" and
"lightning-quick" are the same claim twice. "Easy to install" is implied —
nobody advertises "hard to install". Emoji-per-bullet obscures scanning.

### ✅ Good

```markdown
## Features

- **Incremental compilation.** Only rebuilds the files that changed.
- **Plugin system.** Extend with JavaScript or WebAssembly plugins.
- **Source maps.** Debug your transformed code in the browser with original
  file names and line numbers.
- **Zero config.** Works out of the box for TypeScript, JSX, and CSS modules.
```

Why it works: each bullet is a specific capability the reader can evaluate.
You could decide from this list whether the tool fits your project.

---

## Quickstart / usage

### ❌ Bad

```markdown
## Usage

Using MyProject is simple and intuitive. First, you'll want to import the
library into your project. Then, you can begin to leverage its powerful API
to accomplish your goals. Here's a basic example to get you started:

```js
// First, require the library
const myProject = require('my-project');

// Then, use it
// ...your code here...
```

For more detailed usage, please refer to our comprehensive documentation.
```

Why it's bad: the code example is a non-example — it literally says `...your
code here...`. The prose adds nothing. "Please refer to our comprehensive
documentation" is what you write when you don't want to write documentation.

### ✅ Good

```markdown
## Quickstart

```js
import { parse } from 'my-project';

const result = parse('2026-04-17T10:30:00Z');
console.log(result.toLocaleString());
// → "April 17, 2026, 10:30:00 AM UTC"
```

See [the API reference](./docs/api.md) for all options.
```

Why it works: real values, real output shown as a comment, one link for
readers who want more.

---

## Configuration

### ❌ Bad

```markdown
## Configuration

MyProject can be configured using environment variables. Please consult the
source code for a full list of available configuration options.
```

Why it's bad: "consult the source code" is an abdication. If configuration
matters enough to have a section, it matters enough to document.

### ✅ Good

```markdown
## Configuration

Set these environment variables (or put them in a `.env` file):

| Variable | Default | Description |
|---|---|---|
| `API_KEY` | _(required)_ | Get one at https://example.com/signup |
| `API_URL` | `https://api.example.com` | Override for self-hosted instances |
| `TIMEOUT_MS` | `30000` | HTTP request timeout |
| `LOG_LEVEL` | `info` | One of: `debug`, `info`, `warn`, `error` |
```

Why it works: the reader can actually configure the thing. Defaults are
shown. Required values are marked. Valid enum values are enumerated.

---

## Status / stability

### ❌ Bad

```markdown
MyProject is currently in active development.
```

Why it's bad: every project is "in active development". Tells the reader
nothing about whether they can rely on it.

### ✅ Good

```markdown
> **Status:** beta. The public API is stable, but internals may change
> between 0.x releases. Safe for side projects; pin your version for
> production.
```

Why it works: concrete claims. The reader can make a decision.

---

## Centered footer block

The footer mirrors the header — a `<div align="center">` block that bookends
the page and gives skimmers a call to action.

### ❌ Bad

```markdown
---
Made with ❤️ by the team
```

Why it's bad: tells the reader nothing actionable. Where do they go if
something is broken? Where are the docs? "Made with love" is filler.

### ✅ Good

```markdown
---

<div align="center">

**Built for developers who ship on Fridays.**

[Report Bug](https://github.com/USER/REPO/issues) • [Request Feature](https://github.com/USER/REPO/issues) • [Documentation](https://github.com/USER/REPO#readme)

</div>
```

Why it works: one punchy line says what the project is for. The three links
cover the three things a reader at the bottom of the page most likely wants
to do: file a bug, suggest something, or go deeper into docs.

**Rules for the footer block:**
- One bold closing line, not a heading — keep the visual weight low
- 2–3 links max; more than three dilutes the call to action
- Use the same ` • ` separator as the header nav links for visual consistency
- Place it after the final content section, preceded by a `---` separator

---

## The "cut this" list

Things that almost always make a README worse, not better:

- A "Table of Contents" in a short README (GitHub renders one for you).
- "Welcome to the X repository!" opening line.
- The word "simply" — if it were simple, you wouldn't need to document it.
- Long histories of the project. Put these in a blog post or a `HISTORY.md`.
- Contributor walls-of-text copied from another project. Link to
  CONTRIBUTING.md instead.
- Boilerplate "Made with ❤️ by X" footers.
- Multiple heading-level banners of the project name.
- ASCII art headers (almost always).
- "This project follows semver" as a standalone sentence — if you follow
  semver, the version number says so. If you don't, saying it doesn't make it
  true.
