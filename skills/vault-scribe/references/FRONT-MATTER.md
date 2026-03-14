# Properties (Frontmatter) Reference

Properties use YAML frontmatter at the start of a note. The `type` field is the **discriminator** — it determines which schema applies and makes notes discoverable.

> See also: `CALLOUTS.md` for alert/callout syntax, `EMBEDS.md` for embed syntax, `MARKDOWN-SYNTAX.md` for general syntax.

---

## Property Types

| Type | Example |
|------|---------|
| Text | `title: "My Title"` |
| Enum | `status: published` |
| Date | `date_created: 2026-03-14` |
| List | `tags: [one, two]` or YAML list |
| List of Strings | `attendees:` followed by `- "Full Name"` items |
| Links | `related: "[[Other Note]]"` |
| Semver | `version: "1.0.0"` |
| URL | `source: "https://example.com"` |

---

## Note Types

| `type` value | Purpose | Extra required fields |
|---|---|---|
| `article` | Knowledge base articles, guides, reference docs | *(core only)* |
| `deep-research` | In-depth investigation with sources | `sources` |
| `strategy` | Living strategy/planning docs with versions | `version`, `related` |
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
date_created: 2026-03-14
date_updated: 2026-03-14
---
```

### Field Rules

| Field | Type | Rules |
|---|---|---|
| `type` | enum | Required. See note types above |
| `title` | text | Title Case. Must match the H1 heading |
| `author` | text | Full name. Default: `"Philip A Senger"` |
| `category` | enum | Exactly ONE value from the category list below |
| `tags` | list | 4-12 lowercase-hyphenated slugs |
| `description` | text | One sentence. Plain text, no Markdown |
| `summary` | text | 2-3 sentences. Use YAML multiline `>` |
| `status` | enum | `published`, `draft`, or `in-progress` |
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
- Leadership
- Marketing
- Mental Health
- Methodology
- Mobile Development
- Monitoring
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

### `deep-research`

In-depth investigations, literature reviews, or research notes with sources.

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
related: "[[north-star-workbook-2026]]"
---
```

**Required additional fields:**

| Field | Type | Rules |
|---|---|---|
| `version` | semver | `"X.Y.Z"` format. Increment on meaningful revisions |
| `related` | wikilink or list | Obsidian `"[[wikilink]]"` to companion docs |

**Optional additional fields:**

| Field | Type | When to use |
|---|---|---|
| `backup` | text | Filename of backup archive, e.g. `"Archive-v1.0.0.zip"` |
| `date_revised` | date | Formal revision date if different from `date_updated` |
| `next_review` | text | Who and when for the next review |
| `reviewers` | list of strings | People who review this document |
| `revision_notes` | text | Use multiline `>` for notes about what changed |
| `tracking` | text | External tracking system reference, e.g. `"Jira (Epics & Stories)"` |

---

### `meeting`

Meeting notes, 1:1s, standups, retrospectives, and any note tied to a specific calendar event or collaborative session.

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

Ideation and exploratory thinking — solo with AI, one-on-one, or group sessions. Use for iterating on ideas, evaluating options, or converging on a decision. Core fields only; all additional fields are optional to support both solo and group contexts.

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
date_created: 2026-03-14
date_updated: 2026-03-14
---
```

**Optional additional fields:**

| Field | Type | When to use |
|---|---|---|
| `attendees` | list of strings | When brainstorming in a group or meeting setting |
| `meeting_date` | date | When tied to a specific session date |
| `sources` | list of links | When the brainstorm draws on external references or research |
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
- 4-12 tags per note
- No `#` prefix in frontmatter

Tags can contain: letters (any language), numbers (not first character), underscores `_`, hyphens `-`, forward slashes `/` (for nesting).

**Common tag patterns:**

| Pattern | Examples |
|---|---|
| Technology/tool | `claude`, `docker`, `kubernetes`, `terraform`, `github` |
| Domain | `software-development`, `project-management`, `devops` |
| Concept | `design-patterns`, `architecture`, `testing`, `security` |
| Methodology | `agile`, `lean-startup`, `spec-driven` |
| Content type | `deep-research`, `meeting-notes`, `retrospective`, `brainstorming` |

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

These fields can appear on any note type when relevant:

| Field | Type | When to use |
|---|---|---|
| `aliases` | list of strings | 3-5 alternative names for Obsidian search and linking |
| `subtitle` | text | Secondary title or tagline |
| `read_time` | text | Estimated reading time, e.g. `"10 min"` |
| `source` | URL | Single external source reference |
| `sources` | list of links | Multiple source references as `"[Label](URL)"` |
