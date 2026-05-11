# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.3.0] - 2026-05-12

### Changed

- **agent-os-profile-critique** — Add confidence attribution report: each audit finding is now source-tagged (`[ref]`, `[corpus]`, `[both]`) and a Skill Effectiveness Report with model bias disclaimer is appended after every audit. Adds `README.md` documenting all skill capabilities. ([#23](https://github.com/psenger/ai-agent-skills/issues/23))

## [1.2.0] - 2026-05-10

### Added

- **agent-os-assist** — New skill for Agent OS v3 installation, slash commands, profiles, and ticket-to-spec workflows; includes trigger evals and workspace infrastructure. ([#21](https://github.com/psenger/ai-agent-skills/issues/21))
- **agent-os-profile-critique** — New skill that audits and critiques Agent OS v3 profiles and standards with severity-tagged findings (blocking, warning, suggestion); includes review checklists and trigger evals. ([#21](https://github.com/psenger/ai-agent-skills/issues/21))

## [1.1.2] - 2026-04-25

### Fixed

- **marketplace** — Replace ineffective `publish: false` frontmatter with `metadata.internal: true` on workflow skills (`start`, `release`, `conventions`) — the only field the `skills` CLI (v1.5.1) actually checks to suppress discovery. ([#19](https://github.com/psenger/ai-agent-skills/issues/19))

## [1.1.1] - 2026-04-25

### Fixed

- **marketplace** — Add `publish: false` frontmatter to project-local workflow skills (`start`, `release`, `conventions`) and a root `.skillignore` excluding `.claude/` so `npx skills add` no longer surfaces them. ([#17](https://github.com/psenger/ai-agent-skills/issues/17))

## [1.1.0] - 2026-04-25

### Added

- **handoff** — New skill that saves or loads a structured JSON snapshot of session state (schema v2.0.0) so work can resume cleanly in a new session or be handed to a sub-agent. Supports CREATE (default timestamped path or explicit filename) and RESUME (load most-recent or named file) workflows. Proactively suggests a handoff after 5+ file edits or a major decision. ([#14](https://github.com/psenger/ai-agent-skills/issues/14))

## [1.0.0] - 2026-04-17

### Added

- **readme-writer** — New skill that generates polished `README.md` files for software projects. Four-step workflow: intake (auto-detect repo metadata, classify project type), structure (section menu), write (centered header/footer, code before prose, no marketing), output. Includes reference template, good-vs-bad examples, and evaluation workspace ([#11](https://github.com/psenger/ai-agent-skills/issues/11))
- **vault-scribe** — Two new note types: `how-to` (step-by-step instructional guides) and `technical` (architecture docs, RFCs, ADRs, system specs). Promotes `version` to a core field on all note types. Adds reusable Review & Governance fields (`reviewers`, `signoff`, `revision_notes`, `published`). Expands `strategy` type with `prepared_for` and `quarter`. Adds Finance, How-To, Legal & Compliance, and Operations categories. Includes worked examples for both new note types ([#10](https://github.com/psenger/ai-agent-skills/issues/10))

### Changed

- **review-api-design** — Evaluation outputs moved to `.workspace/` directory; `.skillignore` consolidated to exclude `.workspace/` alongside `evals/`

## [0.6.0] - 2026-03-22

### Added

- **review-api-design** — Planning-phase REST API design review skill with 10 domain-specific reference checklists, structured output format, severity-rated findings, source citations, and 3 eval test cases ([#7](https://github.com/psenger/ai-agent-skills/issues/7))
- CHANGELOG.md with retroactive project history
- `.skillignore` for review-api-design to exclude evals from packaging

## [0.5.0] - 2026-03-22

### Added

- **create-a-skill** — Skill authoring assistant covering full lifecycle: interview, draft, eval, iterate, description optimization, and packaging
- Updated README with marketplace installation instructions

## [0.4.0] - 2026-03-22

### Added

- **arch-lens** — Seven-step interactive architectural review using Ousterhout's deep-module principle with parallel sub-agent interface design and RFC generation ([#5](https://github.com/psenger/ai-agent-skills/issues/5))

## [0.3.0] - 2026-03-22

### Added

- **design-critique** — Structured design critique and plan stress-testing using pre-mortem, red teaming, and ATAM techniques ([#3](https://github.com/psenger/ai-agent-skills/issues/3))

## [0.2.0] - 2026-03-22

### Fixed

- **vault-scribe** — Prohibit incompatible TOC directives, document correct approach ([#1](https://github.com/psenger/ai-agent-skills/issues/1))

## [0.1.0] - 2026-03-22

### Added

- **vault-scribe** — Obsidian vault Markdown conversion skill
- **agentic-skeleton-dir-structure** — Project scaffolding skill for Agent-OS v3
- **git-commit-pr-message** — Git commit, PR, and changelog workflow skill
- Initial project structure and README

[Unreleased]: https://github.com/psenger/ai-agent-skills/compare/v1.3.0...HEAD
[1.3.0]: https://github.com/psenger/ai-agent-skills/compare/v1.2.0...v1.3.0
[1.2.0]: https://github.com/psenger/ai-agent-skills/compare/v1.1.2...v1.2.0
[1.1.2]: https://github.com/psenger/ai-agent-skills/compare/v1.1.1...v1.1.2
[1.1.1]: https://github.com/psenger/ai-agent-skills/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/psenger/ai-agent-skills/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/psenger/ai-agent-skills/compare/v0.6.0...v1.0.0
[0.6.0]: https://github.com/psenger/ai-agent-skills/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/psenger/ai-agent-skills/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/psenger/ai-agent-skills/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/psenger/ai-agent-skills/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/psenger/ai-agent-skills/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/psenger/ai-agent-skills/releases/tag/v0.1.0
