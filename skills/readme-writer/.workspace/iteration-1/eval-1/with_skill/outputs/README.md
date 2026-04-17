<div align="center">

# squash-cli

**An interactive CLI for squashing, reordering, and rewording git commits before you push.**

[![CI](https://github.com/psenger/squash-cli/actions/workflows/ci.yml/badge.svg)](https://github.com/psenger/squash-cli/actions)
[![npm](https://img.shields.io/npm/v/squash-cli.svg)](https://www.npmjs.com/package/squash-cli)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE)

[Quick start](#quick-start) • [Installation](#installation) • [Usage](#usage) • [Development](#development)

</div>

---

`squash-cli` gives you an interactive terminal UI for cleaning up your local commit history
before a push. Select the commits you want to collapse, reorder them with arrow keys, and
edit their messages — all without writing a `git rebase -i` script by hand. It reads your
real git log via `simple-git`, so what you see is what git has.

## Installation

```bash
npm install -g squash-cli
```

Requires Node.js 18 or later.

## Quick start

Inside any git repository, run:

```bash
squash
```

`squash` reads the commits on your current branch that haven't been pushed yet, presents
them in an interactive list, and walks you through squashing or rewording before anything
is written to git. Exit at any prompt with `Ctrl-C` to abort with no changes made.

## Usage

Run `squash` at the root of a git repository. The interactive prompts guide you through
three steps:

1. **Select commits** — use the spacebar to mark the commits you want to squash together.
2. **Reorder** — drag commits into the order you want with the arrow keys.
3. **Edit messages** — type a new commit message for the resulting squashed commit.

When you confirm, `squash-cli` rewrites the selected range using git's rebase machinery.
Only commits that haven't been pushed to the remote are eligible; already-pushed commits
are shown but not selectable.

### Common recipes

```bash
# Squash the last three commits
squash

# Run in a specific repository directory
squash --cwd /path/to/repo
```

Check the full flag list with:

```bash
squash --help
```

## Development

```bash
git clone https://github.com/psenger/squash-cli.git
cd squash-cli
npm install
npm test
```

The source is TypeScript under `src/`. Build with `npm run build` (outputs to `dist/`).
Run linting with `npm run lint`. CI tests on Node 18 and 20 via GitHub Actions.

## License

MIT — see [LICENSE](./LICENSE) for details.

---

<div align="center">

**Clean commit history, every push.**

[Report Bug](https://github.com/psenger/squash-cli/issues) • [Request Feature](https://github.com/psenger/squash-cli/issues) • [npm package](https://www.npmjs.com/package/squash-cli)

</div>