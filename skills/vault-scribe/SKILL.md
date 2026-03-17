---
name: vault-scribe
description: >
  Converts transcripts, video summaries, meeting notes, brainstorming sessions, strategy
  documents, and rough notes into polished Obsidian-flavored Markdown. Activates when
  creating or editing notes in an Obsidian vault, generating front matter, applying callout
  blocks, structuring knowledge base articles, or producing developer-facing guides.
  Also triggers on mentions of Obsidian, front matter, callout blocks, vault organisation,
  or requests for GitHub-compatible Markdown documents.
user-invocable: true
allowed-tools: Read, Grep, Edit, Write
argument-hint: "[note-type: article|meeting|brainstorming|strategy|deep-research]"
---

# Vault Scribe — Obsidian + GitHub Markdown Skill

Creates and edits Markdown that is **GitHub-Flavored Markdown (GFM) first**, with optional Obsidian-specific extensions when needed. Standard Markdown (headings, bold, italic, lists, quotes, code blocks, tables) is assumed knowledge.

> **Default rule:** Use standard GFM syntax unless the user explicitly requests Obsidian-specific features or is working in an Obsidian-only context. Obsidian wikilinks (`[[Note]]`) break on GitHub — always prefer standard Markdown links for cross-platform compatibility.

When invoked with an argument (e.g. `/vault-scribe meeting`), use `$ARGUMENTS` to determine the note type. If no argument is provided, infer the type from the source material or ask the user.

---

## Workflow: Creating a Note

### 1. Analyse the Source Material

- Read the full transcript, notes, or brief carefully
- Identify the **core topic**, intended **audience**, and **key concepts**
- Note any implicit structure (e.g., problem → solution → examples)
- Extract any explicit examples, warnings, tips, or quotes worth preserving

### 2. Generate YAML Front Matter

> **Reference:** See `references/FRONT-MATTER.md` for the complete schema definitions, all enum values, and type-specific required fields.

**First, determine the note `type`** based on what the user is creating:

| If the user wants… | Set `type` to |
|---|---|
| A guide, reference doc, or knowledge article | `article` |
| An investigation with multiple sources | `deep-research` |
| A versioned plan or strategy document | `strategy` |
| Meeting notes, 1:1s, standups, retrospectives | `meeting` |
| Brainstorming, ideation, or exploratory thinking (solo or group) | `brainstorming` |

> [!TIP]
> **Brainstorming** is its own note type. It works for group sessions (add `attendees` and `meeting_date`) and solo AI ideation (omit them). Add `sources` when the brainstorm draws on external references.

Then apply the corresponding frontmatter schema from `references/FRONT-MATTER.md`. Every note type uses the **core fields** plus any **type-specific required fields**.

**Tag guidelines:**
- Use lowercase, hyphenated slugs only (e.g. `distributed-systems`, not `Distributed Systems`)
- Include 4–8 tags: topic-specific first, then broader domain tags
- Always include at least one technology tag and one domain/concept tag

### 3. Structure the Document Body

Use this hierarchy:

```
# Title (H1) — matches front matter title
## Section (H2) — major topic areas
### Subsection (H3) — specific concepts within a section
```

**Target sections** (adapt names to the topic):
1. **Overview / What is X?** — define the subject clearly
2. **How It Works** — mechanics, process, or architecture
3. **Practical Examples** — concrete code blocks or walkthroughs
4. **Common Mistakes / Warnings** — callout blocks
5. **Quick-Start / Checklist** — actionable summary
6. **Further Reading & References** — links table

> [!NOTE]
> **Minimum 4 sections** (Overview, How It Works, Examples, References) for all notes. The full 6 sections are the target for comprehensive articles and guides. Simpler note types (meetings) naturally use fewer sections.

### 4. Apply Callout Blocks

Use GFM Alerts by default (renders on both GitHub and Obsidian). See `references/CALLOUTS.md` for the full list of callout types including Obsidian-only variants.

| Callout Type | Use For |
|---|---|
| `[!NOTE]` | Neutral supplementary info |
| `[!TIP]` | Actionable best practice |
| `[!IMPORTANT]` | Key concept the reader must not miss |
| `[!WARNING]` | Common mistake or gotcha |
| `[!CAUTION]` | Risk of data loss, security issue, or breaking change |

> [!TIP]
> Every Warning, Tip, and TL;DR should be a callout block — not plain prose. This makes the document scannable.

### 5. Code Blocks

Always use fenced code blocks with a language identifier:

````markdown
```yaml
key: value
```

```bash
mkdir -p ~/.claude/skills/my-skill
```
````

For directory trees, use plain `text` or no language tag.

### 6. Table of Contents

**Never use `[TOC]`, `[[_TOC_]]`, or any other TOC directive** — neither GitHub nor Obsidian supports them natively. They render as broken plain text.

- GitHub auto-generates a TOC in the sidebar — no directive needed.
- Obsidian generates one via its built-in plugin — no directive needed.
- Only add a **manual** TOC (using standard anchor links) when the document has 6+ sections and will be read outside a browser. See `references/MARKDOWN-SYNTAX.md` for anchor rules and an example.

### 7. Tables & Links

Use Markdown tables for comparisons, option lists, and reference links. Always include a reference links table at the end:

```markdown
| Resource | Link |
|---|---|
| Official Docs | [docs.example.com](https://docs.example.com) |
| Source Video  | [youtube.com/watch?v=...](https://youtube.com/watch?v=...) |
```

### 8. Inline Formatting Rules

| Element | Usage |
|---|---|
| `**bold**` | Key terms on first use, critical values |
| `*italic*` | Titles of external resources, emphasis |
| `` `code` `` | All file paths, commands, config keys, code symbols |
| `[[wikilink]]` | Internal Obsidian links (only if Obsidian-only context) |

### 9. Transcript Appendix

When the source material includes a transcript (video, podcast, meeting recording, article), **always** append the raw transcript at the very end of the document, after all other content, using this exact format:

```markdown
---

## Transcript

Transcript from: [<name of video or article or meeting>](<link to source>)
Date of material: <YYYY-MM-DD>

\```
<raw transcript>
\```
```

- The transcript section is separated from the rest of the document by a horizontal rule (`---`)
- The source name must be a clickable Markdown link when a URL is available
- If no URL exists, use plain text for the name
- Date should be in `YYYY-MM-DD` format when known; leave blank if unknown
- The raw transcript goes inside a fenced code block with no language tag, preserving the original text exactly as provided

---

## Output Requirements

- File extension: `.md`
- Encoding: UTF-8
- Front matter: Always present, always first
- Minimum sections: 4 (Overview, How It Works, Examples, References). Target 6 for comprehensive articles.
- All external URLs must be real and formatted as `[label](url)`
- No bare URLs — always wrapped in Markdown link syntax
- End the document with an `[!abstract]` callout containing the TL;DR (before the Transcript appendix, if present)

---

## Quality Checklist

Before finalising the output, verify:

- [ ] Front matter is complete and valid YAML
- [ ] `type` field is set and matches the correct note type schema
- [ ] All type-specific required fields are present (per `references/FRONT-MATTER.md`)
- [ ] Title in front matter matches H1 heading
- [ ] `category` is a valid enum value
- [ ] Tags are lowercase and hyphenated
- [ ] All warnings/tips are callout blocks, not plain paragraphs
- [ ] At least one code block example is present (for articles/guides)
- [ ] A reference links table exists at the end
- [ ] Document closes with an `[!abstract]` callout (before Transcript appendix if present)
- [ ] No bare URLs (all links use `[label](url)` format)
- [ ] `date_created` and `date_updated` are set (use today's date if unknown)
- [ ] If source material includes a transcript, it is appended in the Transcript Appendix format

---

## Reference Files

- `references/FRONT-MATTER.md` — Complete frontmatter schemas for all note types, enum values for `type`, `category`, and `status`, and type-specific required/optional fields. **Always consult this file** when generating front matter.
- `references/CALLOUTS.md` — GFM Alerts (default) and Obsidian callout types, foldable/nested syntax, aliases, and custom CSS callouts.
- `references/EMBEDS.md` — Standard GFM image syntax (default) and Obsidian-specific embed syntax for notes, images, audio, and PDFs.
- `references/MARKDOWN-SYNTAX.md` — Detailed GFM + Obsidian syntax reference for links, tags, comments, highlighting, math, diagrams, footnotes, and the compatibility matrix.
- `examples/` — Example output files showing correctly formatted notes for different note types.

---

## References

- [GitHub Flavored Markdown Spec](https://github.github.com/gfm/)
- [GitHub Alerts](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax#alerts)
- [Obsidian Flavored Markdown](https://help.obsidian.md/obsidian-flavored-markdown)
- [Obsidian Internal Links](https://help.obsidian.md/links)
- [Obsidian Callouts](https://help.obsidian.md/callouts)
- [Obsidian Properties](https://help.obsidian.md/properties)
