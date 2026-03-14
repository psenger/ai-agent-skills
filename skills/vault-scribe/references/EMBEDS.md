# Embeds & Images Reference

> See also: `MARKDOWN-SYNTAX.md` for general syntax, `CALLOUTS.md` for alert/callout syntax.

---

## Standard GFM Images (Default — works on GitHub and Obsidian)

Use standard Markdown image syntax for cross-platform compatibility:

```markdown
![Alt text](image.png)                     Embed image
![Alt text](image.png "Optional title")    With title tooltip
```

Control image width using HTML (supported by GitHub):

```markdown
<img src="image.png" width="300">          Width in pixels
<img src="image.png" width="300" alt="Alt text">  With alt text
```

---

## Obsidian Embeds (Obsidian-only)

> Only use these if the file will never be viewed on GitHub. On GitHub, `![[...]]` syntax does not render.

### Embed Notes

```markdown
![[Note Name]]                             Embed full note
![[Note Name#Heading]]                     Embed section
![[Note Name#^block-id]]                   Embed block
```

### Embed Images

```markdown
![[image.png]]                             Embed image
![[image.png|640x480]]                     Width x Height
![[image.png|300]]                         Width only (maintains aspect ratio)
```

### External Images (Obsidian syntax)

```markdown
![Alt text](https://example.com/image.png)       Standard syntax (works everywhere)
![Alt text|300](https://example.com/image.png)   Obsidian-only width syntax
```

> [!NOTE]
> The `|300` width syntax inside alt text is Obsidian-specific. GitHub interprets `|300` as part of the alt text. For cross-platform width control, use HTML `<img>` tags instead.

### Embed Audio

```markdown
![[audio.mp3]]
![[audio.ogg]]
```

### Embed PDF

```markdown
![[document.pdf]]
![[document.pdf#page=3]]
![[document.pdf#height=400]]
```

### Embed Lists

```markdown
![[Note#^list-id]]
```

Where the list has a block ID:

```markdown
- Item 1
- Item 2
- Item 3

^list-id
```

### Embed Search Results

````markdown
```query
tag:#project status:done
```
````
