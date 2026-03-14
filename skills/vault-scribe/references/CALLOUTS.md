# Callouts & Alerts Reference

> See also: `MARKDOWN-SYNTAX.md` for general syntax, `EMBEDS.md` for embed syntax.

---

## GFM Alerts (Default — use these for GitHub + Obsidian compatibility)

GitHub renders these with coloured icons. Obsidian displays them as styled callouts with matching types.

```markdown
> [!NOTE]
> Highlights information users should notice.

> [!TIP]
> Optional advice for success.

> [!IMPORTANT]
> Crucial information for the user.

> [!WARNING]
> Critical content requiring attention.

> [!CAUTION]
> Negative potential consequences.
```

| GFM Alert | GitHub | Obsidian | Obsidian Equivalent |
|---|---|---|---|
| `[!NOTE]` | ✅ Blue info icon | ✅ Maps to `note` | `[!note]` |
| `[!TIP]` | ✅ Green bulb icon | ✅ Maps to `tip` | `[!tip]` |
| `[!IMPORTANT]` | ✅ Purple icon | ✅ Maps to `tip`/`important` | `[!important]` |
| `[!WARNING]` | ✅ Yellow icon | ✅ Maps to `warning` | `[!warning]` |
| `[!CAUTION]` | ✅ Red icon | ✅ Maps to `caution` | `[!caution]` |

---

## Obsidian Callouts (Obsidian-only)

> Only use these if the file will never be viewed on GitHub. On GitHub, these render as plain blockquotes with the type tag visible.

### Basic Callout

```markdown
> [!note]
> This is a note callout.

> [!info] Custom Title
> This callout has a custom title.

> [!tip] Title Only
```

### Foldable Callouts

```markdown
> [!faq]- Collapsed by default
> This content is hidden until expanded.

> [!faq]+ Expanded by default
> This content is visible but can be collapsed.
```

### Nested Callouts

```markdown
> [!question] Outer callout
> > [!note] Inner callout
> > Nested content
```

---

## Supported Obsidian Callout Types

| Type | Aliases | Colour / Icon |
|---|---|---|
| `note` | — | Blue, pencil |
| `abstract` | `summary`, `tldr` | Teal, clipboard |
| `info` | — | Blue, info |
| `todo` | — | Blue, checkbox |
| `tip` | `hint`, `important` | Cyan, flame |
| `success` | `check`, `done` | Green, checkmark |
| `question` | `help`, `faq` | Yellow, question mark |
| `warning` | `caution`, `attention` | Orange, warning |
| `failure` | `fail`, `missing` | Red, X |
| `danger` | `error` | Red, zap |
| `bug` | — | Red, bug |
| `example` | — | Purple, list |
| `quote` | `cite` | Grey, quote |

> [!TIP]
> **`[!abstract]` is the recommended TL;DR callout.** Its aliases `summary` and `tldr` also work. Use `[!abstract]` at the end of documents to provide a recap. In Obsidian, `[!summary]` and `[!tldr]` render identically to `[!abstract]`.

---

## Custom Callouts (CSS)

```css
.callout[data-callout="custom-type"] {
  --callout-color: 255, 0, 0;
  --callout-icon: lucide-alert-circle;
}
```
