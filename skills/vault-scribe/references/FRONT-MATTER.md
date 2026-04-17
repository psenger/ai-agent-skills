# Properties (Frontmatter) Reference

Properties use YAML frontmatter at the start of a note. The `type` field is the **discriminator** — it determines which schema applies and makes notes discoverable.

> See also: `CALLOUTS.md` for alert/callout syntax, `EMBEDS.md` for embed syntax, `MARKDOWN-SYNTAX.md` for general syntax.

---

## Property Types

| Type | Example |
|---|---|
| Text | `title: "My Title"` |
| Enum | `status: published` |
| Date | `date_created: 2026-03-14` |
| List of strings | `tags: [one, two]` or YAML block list |
| List of objects | `signoff:` followed by `- name:` / `date:` pairs |
| Wikilink | `related: "[[Other Note]]"` |
| Semver | `version: "1.0.0"` |
| URL | `source: "https://example.com"` |

---

## Note Types

| `type` | Purpose | Extra required fields |
|---|---|---|
| `article` | Knowledge base articles, guides, reference docs | *(core only)* |
| `how-to` | Step-by-step instructional guides and procedures | *(core only)* |
| `technical` | In-depth technical documentation: architecture, RFCs, design docs, system specs | `system`, `component` |
| `deep-research` | In-depth investigation with cited sources | `sources` |
| `strategy` | Living strategy/planning docs | `version`, `related`, `prepared_for`, `quarter` |
| `meeting` | Meeting notes, 1:1s, standups, retrospectives | `attendees`, `meeting_date` |
| `brainstorming` | Ideation, exploratory thinking, solo or group | *(core only)* |

---

## Core Fields (ALL note types)

```yaml
---
type: article
title: "Descriptive Title in Title Case"
author: "Philip A Senger"
category: "Artificial Intelligence"
tags:
  - lowercase-hyphenated-tag
  - another-tag
description: "One sentence — what is this document about"
summary: >
  Two to three sentences — what does the reader learn.
status: published
version: "1.0.0"
date_created: 2026-03-14
date_updated: 2026-03-14
---
```

### Core Field Rules

| Field | Type | Rules |
|---|---|---|
| `type` | enum | Required. See note types table above |
| `title` | text | Title Case. Must match the H1 heading |
| `author` | text | Full name. Default: `"Philip A Senger"` |
| `category` | enum | Exactly one value from the category list below |
| `tags` | list of strings | 4–12 lowercase-hyphenated slugs |
| `description` | text | One sentence. Plain text, no Markdown |
| `summary` | text | 2–3 sentences. Use YAML multiline `>` |
| `status` | enum | `published`, `draft`, or `in-progress` |
| `version` | semver | `"X.Y.Z"`. Increment on meaningful revisions |
| `date_created` | date | `YYYY-MM-DD`. Set once at creation |
| `date_updated` | date | `YYYY-MM-DD`. Update on every edit |

---

## `status` Enum

| Value | Meaning |
|---|---|
| `published` | Complete, production-ready |
| `draft` | Work in progress, not yet reviewed |
| `in-progress` | Actively being written or revised |

---

## `category` Enum

Use exactly one (Title Case):

- Artificial Intelligence
- Business Management
- Cloud Computing
- Critical Thinking
- Database
- Decision Making
- DevOps
- Documentation
- Education
- Entrepreneurship
- Finance
- How-To
- Leadership
- Legal & Compliance
- Marketing
- Mental Health
- Methodology
- Mobile Development
- Monitoring
- Operations
- Personal Development
- Product Management
- Productivity
- Project Management
- Security
- Software Architecture
- Software Development
- Software Engineering
- Strategy
- Web Development

> When none fit, pick the closest match. Do not invent new categories without the user's approval.

---

## Review & Governance Fields (any note type)

These fields track the review lifecycle and sign-off history of a document. All are optional unless the note type specifies otherwise.

| Field | Type | Description |
|---|---|---|
| `reviewers` | list of strings | Full names of everyone who reviews this document |
| `next_reviewer` | list of strings | Full names of who should review next |
| `next_review_date` | date | `YYYY-MM-DD` — scheduled date for the next review |
| `signoff` | list of objects | Sign-off records. Each entry: `name: "Full Name"`, `date: "YYYY-MM-DD"` |
| `revision_notes` | list of strings | Change log entries. Each prefixed with version: `"1.1.0 - Updated security section"` |
| `published` | list of objects | Publication records. Each entry: `when: "YYYY-MM-DD"`, `where: "https://..."`, `version: "1.0.0"` |
| `backup` | string | Optional. Filename of a backup archive, e.g. `"archive-v1.0.0.zip"` |

**Example:**

```yaml
reviewers:
  - "Alice Johnson"
  - "Bob Chen"
next_reviewer:
  - "Carol Williams"
next_review_date: 2026-06-01
signoff:
  - name: "Alice Johnson"
    date: "2026-03-15"
  - name: "Bob Chen"
    date: "2026-03-16"
revision_notes:
  - "1.0.0 - Initial publication"
  - "1.1.0 - Added deployment checklist"
  - "1.2.0 - Revised security section based on audit"
published:
  - when: "2026-03-15"
    where: "https://internal.example.com/docs/guide"
    version: "1.0.0"
backup: "archive-v1.1.0.zip"
```

---

## Type-Specific Schemas

### `article`

Standard knowledge base note. Core fields only.

```yaml
---
type: article
title: "Understanding Claude Skills"
author: "Philip A Senger"
category: "Artificial Intelligence"
tags:
  - claude
  - skills
  - developer-tools
description: "A developer guide to writing and using Claude Skills"
summary: >
  Explains what Claude Skills are, how they are discovered and loaded,
  and how to write effective skill descriptions.
status: published
version: "1.0.0"
date_created: 2026-03-04
date_updated: 2026-03-04
---
```

**Optional fields:**

| Field | Type | When to use |
|---|---|---|
| `aliases` | list of strings | When the topic has multiple common names |
| `subtitle` | text | For major guides or long-form pieces |
| `read_time` | text | For long-form content, e.g. `"10 min"` |
| `source` | URL | When based on a single external source |
| `sources` | list of links | When referencing multiple external sources |

---

### `how-to`

Step-by-step instructional guides and procedures. Focused on a specific task outcome. Core fields only.

```yaml
---
type: how-to
title: "How to Set Up a Pre-Commit Hook with Husky"
author: "Philip A Senger"
category: "How-To"
tags:
  - how-to
  - husky
  - pre-commit
  - git
description: "Step-by-step guide to configuring Husky pre-commit hooks in a Node.js project"
summary: >
  Walks through installing Husky, configuring lint-staged,
  and wiring up formatting and type-check scripts to run on every commit.
status: published
version: "1.0.0"
date_created: 2026-03-14
date_updated: 2026-03-14
---
```

**Optional fields:**

| Field | Type | When to use |
|---|---|---|
| `prerequisites` | list of strings | Tools or knowledge required before following the guide |
| `aliases` | list of strings | Alternative names for the procedure |
| `read_time` | text | Estimated time to complete, e.g. `"15 min"` |
| `source` | URL | When based on an official source or doc |

---

### `technical`

In-depth technical documentation for systems, components, APIs, and architecture. Use for RFCs, design docs, architecture decision records (ADRs), and internal system specifications.

```yaml
---
type: technical
title: "Authentication Service Architecture"
author: "Philip A Senger"
category: "Software Architecture"
tags:
  - authentication
  - architecture
  - jwt
  - security
description: "Architecture and design specification for the authentication service"
summary: >
  Documents the design, component breakdown, and data flow of the authentication
  service, including token lifecycle and failure handling.
status: published
version: "1.2.0"
date_created: 2026-01-10
date_updated: 2026-03-14
system: "Identity Platform"
component: "Authentication Service"
reviewers:
  - "Alice Johnson"
  - "Bob Chen"
next_review_date: 2026-06-01
signoff:
  - name: "Alice Johnson"
    date: "2026-03-15"
revision_notes:
  - "1.0.0 - Initial design doc"
  - "1.1.0 - Added token refresh flow"
  - "1.2.0 - Revised failure handling after incident review"
---
```

**Required additional fields:**

| Field | Type | Rules |
|---|---|---|
| `system` | text | The broader system or platform this document belongs to |
| `component` | text | The specific component, service, or subsystem being documented |

**Optional additional fields:**

| Field | Type | When to use |
|---|---|---|
| `sources` | list of links | RFCs, papers, or external specs referenced |
| `related` | wikilink or list | Links to companion ADRs, runbooks, or design docs |
| `aliases` | list of strings | Alternative names (e.g. abbreviated service name) |

---

### `deep-research`

In-depth investigations, literature reviews, or research notes with cited sources.

```yaml
---
type: deep-research
title: "Comparing Agent Orchestration Frameworks"
author: "Philip A Senger"
category: "Artificial Intelligence"
tags:
  - agents
  - orchestration
  - deep-research
description: "A comparative analysis of agent orchestration approaches"
summary: >
  Reviews five major agent orchestration frameworks, comparing their
  architecture, scalability, and developer experience.
status: draft
version: "1.0.0"
date_created: 2026-03-10
date_updated: 2026-03-12
sources:
  - "[LangGraph Docs](https://langchain-ai.github.io/langgraph/)"
  - "[CrewAI Paper](https://arxiv.org/abs/example)"
---
```

**Required additional fields:**

| Field | Type | Rules |
|---|---|---|
| `sources` | list of links | At least one. Format: `"[Label](URL)"` |

**Optional additional fields:**

| Field | Type | When to use |
|---|---|---|
| `aliases` | list of strings | Alternative names for the research topic |

---

### `strategy`

Living strategy documents, workbooks, and planning docs that evolve through versions.

```yaml
---
type: strategy
title: "North Star Plan 2026"
author: "Philip A Senger"
category: "Strategy"
tags:
  - north-star
  - planning
  - okr
description: "Annual strategic plan and OKR framework for 2026"
summary: >
  Defines the vision, mission, and quarterly OKRs for 2026.
  Includes tracking references and review schedule.
status: published
version: "2.0.0"
date_created: 2025-12-01
date_updated: 2026-02-15
prepared_for: "Leadership Team"
quarter: "Q1 2026"
related: "[[north-star-workbook-2026]]"
reviewers:
  - "Alice Johnson"
  - "Bob Chen"
next_reviewer:
  - "Carol Williams"
next_review_date: 2026-04-01
signoff:
  - name: "Alice Johnson"
    date: "2026-01-10"
revision_notes:
  - "1.0.0 - Initial draft"
  - "2.0.0 - Full rewrite for 2026 planning cycle"
---
```

**Required additional fields:**

| Field | Type | Rules |
|---|---|---|
| `version` | semver | `"X.Y.Z"`. Increment on every meaningful revision |
| `related` | wikilink or list | `"[[wikilink]]"` to companion docs |
| `prepared_for` | text | Name or role of intended audience, e.g. `"Leadership Team"`, `"Engineering All-Hands"` |
| `quarter` | text | Fiscal or calendar quarter covered, e.g. `"Q2 2026"` |

**Optional additional fields:**

| Field | Type | When to use |
|---|---|---|
| `backup` | string | Filename of backup archive, e.g. `"archive-v1.0.0.zip"` |
| `date_revised` | date | Formal revision date if different from `date_updated` |
| `tracking` | text | External tracking reference, e.g. `"Jira (Epics & Stories)"` |

---

### `meeting`

Meeting notes, 1:1s, standups, retrospectives, and notes tied to a specific calendar event.

```yaml
---
type: meeting
title: "Sprint 12 Retrospective"
author: "Philip A Senger"
category: "Project Management"
tags:
  - retrospective
  - sprint-12
  - team-sync
description: "Retrospective notes for Sprint 12"
summary: >
  Covers what went well, what did not, and action items
  from the Sprint 12 retrospective.
status: published
version: "1.0.0"
date_created: 2026-03-14
date_updated: 2026-03-14
meeting_date: 2026-03-14
attendees:
  - "Alice Johnson"
  - "Bob Chen"
  - "Carol Williams"
---
```

**Required additional fields:**

| Field | Type | Rules |
|---|---|---|
| `meeting_date` | date | `YYYY-MM-DD` — the date the meeting occurred |
| `attendees` | list of strings | Full names of all attendees, quoted |

**Optional additional fields:**

| Field | Type | When to use |
|---|---|---|
| `meeting_type` | text | e.g. `"standup"`, `"retrospective"`, `"1:1"`, `"planning"`, `"review"` |
| `location` | text | Room name, video link, or `"remote"` |
| `action_items` | list of strings | Key action items from the meeting |

---

### `brainstorming`

Ideation and exploratory thinking — solo with AI, one-on-one, or group sessions. Core fields only; all additional fields are optional to support both solo and group contexts.

```yaml
---
type: brainstorming
title: "API Architecture Options"
author: "Philip A Senger"
category: "Software Architecture"
tags:
  - brainstorming
  - api-design
  - architecture
description: "Exploring API architecture approaches for the v2 platform"
summary: >
  Evaluated REST, GraphQL, and gRPC. Converged on a hybrid
  REST + GraphQL strategy based on client needs.
status: published
version: "1.0.0"
date_created: 2026-03-14
date_updated: 2026-03-14
---
```

**Optional additional fields:**

| Field | Type | When to use |
|---|---|---|
| `attendees` | list of strings | When brainstorming in a group or meeting setting |
| `meeting_date` | date | When tied to a specific session date |
| `sources` | list of links | When the brainstorm draws on external references |
| `action_items` | list of strings | Decisions or next steps from the session |

**Group brainstorming example:**

```yaml
---
type: brainstorming
title: "Q3 Feature Prioritisation"
author: "Philip A Senger"
category: "Product Management"
tags:
  - brainstorming
  - prioritisation
  - product-roadmap
description: "Team brainstorm to prioritise Q3 feature candidates"
summary: >
  Ranked 12 feature proposals using weighted scoring.
  Top 3 selected for Q3 development.
status: published
version: "1.0.0"
date_created: 2026-03-14
date_updated: 2026-03-14
meeting_date: 2026-03-14
attendees:
  - "Alice Johnson"
  - "Bob Chen"
action_items:
  - "Write specs for top 3 features"
  - "Schedule design review for next week"
---
```

---

## Tags

Tags are always placed in frontmatter as a YAML list:

```yaml
tags:
  - lowercase-hyphenated-tag
  - nested/sub-tag
```

**Rules:**
- Lowercase and hyphenated only: `software-development`, not `Software Development`
- Topic-specific tags first, broader domain tags after
- Include at least one technology tag and one domain tag
- 4–12 tags per note
- No `#` prefix in frontmatter

Tags can contain: letters (any language), numbers (not first character), underscores `_`, hyphens `-`, forward slashes `/` (for nesting).

**Common tag patterns:**

| Pattern | Examples |
|---|---|
| Technology/tool | `claude`, `docker`, `kubernetes`, `terraform`, `github` |
| Domain | `software-development`, `project-management`, `devops` |
| Concept | `design-patterns`, `architecture`, `testing`, `security` |
| Methodology | `agile`, `lean-startup`, `spec-driven` |
| Content type | `deep-research`, `meeting-notes`, `retrospective`, `brainstorming`, `how-to` |

---

## Default Obsidian Properties

These Obsidian-native properties work across all note types when needed:

- `tags` — Note tags (searchable, shown in graph view)
- `aliases` — Alternative names for the note (used in link suggestions)

```yaml
aliases:
  - "Alternative Title"
  - "Another Common Name"
  - "Abbreviation or Acronym"
```

---

## Optional Fields (any note type)

| Field | Type | When to use |
|---|---|---|
| `aliases` | list of strings | 3–5 alternative names for Obsidian search and linking |
| `subtitle` | text | Secondary title or tagline |
| `read_time` | text | Estimated reading time, e.g. `"10 min"` |
| `source` | URL | Single external source reference |
| `sources` | list of links | Multiple sources as `"[Label](URL)"` |