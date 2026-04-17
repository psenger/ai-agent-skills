---
type: how-to
title: "How to Configure a GitHub Actions CI Pipeline"
author: "Philip A Senger"
category: "How-To"
tags:
  - how-to
  - github-actions
  - ci-cd
  - devops
description: "Step-by-step guide to setting up a GitHub Actions workflow for CI on a Node.js project"
summary: >
  Walks through creating a GitHub Actions workflow file, configuring Node.js
  matrix testing, and adding a status badge to the project README.
status: published
version: "1.0.0"
date_created: 2026-03-14
date_updated: 2026-03-14
prerequisites:
  - "GitHub repository with a Node.js project"
  - "package.json with a `test` script defined"
reviewers:
  - "Alice Johnson"
next_review_date: 2026-09-14
revision_notes:
  - "1.0.0 - Initial publication"
---

# How to Configure a GitHub Actions CI Pipeline

This guide sets up a GitHub Actions workflow that runs tests on every push and pull request.

## Prerequisites

Before you begin:

- A GitHub repository with a Node.js project
- `package.json` with a `test` script (e.g. `jest`, `mocha`, `vitest`)
- Write access to the repository

## Steps

### 1. Create the Workflow Directory

```bash
mkdir -p .github/workflows
```

### 2. Create the Workflow File

Create `.github/workflows/ci.yml`:

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest

    strategy:
      matrix:
        node-version: [18.x, 20.x]

    steps:
      - uses: actions/checkout@v4

      - name: Use Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: "npm"

      - run: npm ci
      - run: npm test
```

### 3. Commit and Push

```bash
git add .github/workflows/ci.yml
git commit -m "ci: add GitHub Actions CI workflow"
git push
```

### 4. Verify the Workflow Ran

Navigate to **Actions** tab in your GitHub repository. You should see the workflow trigger within seconds of the push.

### 5. Add a Status Badge (Optional)

Add to your `README.md`:

```markdown
![CI](https://github.com/<owner>/<repo>/actions/workflows/ci.yml/badge.svg)
```

Replace `<owner>` and `<repo>` with your GitHub username and repository name.

> [!TIP]
> Use `npm ci` instead of `npm install` in CI — it installs exactly what is in `package-lock.json` and fails if the lock file is out of sync.

> [!WARNING]
> Do not cache `node_modules` directly. Use `cache: "npm"` on the `setup-node` action — it caches the npm cache directory, which is safer and more portable across Node versions.

## Troubleshooting

| Problem | Likely Cause | Fix |
|---|---|---|
| Workflow does not trigger | Branch name mismatch | Confirm `branches` list matches your default branch |
| `npm ci` fails | Missing or outdated `package-lock.json` | Run `npm install` locally and commit the lock file |
| Tests pass locally but fail in CI | Environment variable missing | Add secrets via **Settings → Secrets and variables → Actions** |

## Further Reading & References

| Resource | Link |
|---|---|
| GitHub Actions Docs | [docs.github.com/actions](https://docs.github.com/en/actions) |
| `setup-node` Action | [github.com/actions/setup-node](https://github.com/actions/setup-node) |
| Workflow syntax reference | [docs.github.com/actions/writing-workflows](https://docs.github.com/en/actions/writing-workflows/workflow-syntax-for-github-actions) |

> [!abstract] TL;DR
> Create `.github/workflows/ci.yml`, define an `on: push / pull_request` trigger, use `actions/setup-node` with a Node version matrix, then run `npm ci && npm test`. Push and verify in the Actions tab.