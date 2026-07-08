---
name: sotatek-proposal
description: Generate a Sotatek-branded .docx proposal from a markdown quote/proposal file. Preserves the Sotatek template's cover, header/footer branding, styles, numbering and auto Table of Contents. Use when turning a markdown proposal/quote into the official Sotatek Word deliverable.
user-invocable: true
when_to_use: "Invoke when the user provides a markdown proposal/quote and wants the branded Sotatek .docx (e.g. 'gen docs theo template', 'xuất proposal ra Word')."
keywords: [proposal, docx, sotatek, template, quote, báo giá, word]
metadata:
  author: internal
  version: "1.0.0"
---

# Sotatek Proposal Generator

Turns a **markdown** proposal into the **branded Sotatek `.docx`** by pouring content
into the reference template (`template/Sotatek_Naisiti_Project_Proposal.docx`) while
keeping its cover, logo/watermark header, contact footer, heading styles, table look
and bullet numbering.

## When to use
User provides (or asks you to write) a markdown quote/proposal and wants the official
Word file. Typical trigger: "gen docs theo template này", "xuất báo giá ra Word".

## How to run

```bash
PY=~/.claude/skills/.venv/bin/python3
SK=".claude/skills/sotatek-proposal"
$PY $SK/build_proposal.py INPUT.md [OUTPUT.docx]
# default output: output/Sotatek_<input-name>.docx
```

Building needs **no rendering** — it is deterministic and fast (seconds).

## Markdown format (input)

YAML front-matter drives the cover + front-matter tables; the body is standard markdown.

```markdown
---
project: "YEDI + TIDAL"
subtitle: "Two-Sided Staffing Platform"
tagline: "From Admin Panel to Production Product"
version: "v1.0"
author: "Sotatek"
approver: ""
location: "Hanoi"
date: "July 6th 2026"
presenter: { name: "Sotatek", position: "Solutions / Delivery", division: "Global Delivery" }
edit_history:
  - { date: "Jul 6, 2026", version: "1.0", description: "Create", editor: "Sotatek" }
approval:
  - { date: "", version: "1.0", approver: "", position: "" }
---

# 1. Section Title          -> Heading 1 (navy, starts new page for first H1)
## Subsection               -> Heading 2 (blue)
### Sub-subsection          -> Heading 3 (orange)

A normal paragraph with **bold** and *italic* inline.

- bullet, supports **bold:** lead-in text
  - nested bullet (2-space indent)

> A line rendered as a small italic note.

| Col A | Num | Right |     -> styled table; alignment read from the separator row
|---|:-:|---:|            (:-:=center, ---:=right, ---=left); header row shaded navy
| x | 1 | 2 |
```

See `examples/proposal-yedi-tidal.md` for a full, working proposal.

## Table of Contents
- **Default (static):** the doc is rendered once to read real page numbers, then
  rebuilt with them, so the TOC is fully populated and correct in any viewer.
  The single render can be slow on some machines; raise the cap with
  `RENDER_TIMEOUT=1800` (seconds) if needed. On a very slow box, use `--fast`.
- **`--fast` (field):** inserts a real Word TOC field + `updateFields`; ~1s, no
  render. Page numbers fill in when the file is opened (and prompted to update) in
  Microsoft Word.

The build also strips the template's unused Naisiti architecture image so no stale
asset ships in the output.

## Optional QA render (visual check only)

```bash
.claude/skills/sotatek-proposal/render.sh output/Sotatek_<name>.docx [firstPage lastPage]
```
- Reuses one LibreOffice profile so re-runs are quicker; **never `kill -9` soffice**
  mid-run (it corrupts the profile and forces slow re-init).
- First render on a fresh machine can take a few minutes; verify content with text
  extraction (python-docx) and only render a couple of key pages when needed.

## Files
- `build_proposal.py` — CLI entry (md -> docx)
- `lib/md_parser.py` — markdown -> blocks + front-matter
- `lib/docx_helpers.py` — brand constants, headings, tables, bullets, TOC field
- `lib/cover.py` — front-matter -> cover + Presenter/Edit-History/Approval tables
- `render.sh` — optional LibreOffice PDF/JPEG render
- `examples/proposal-yedi-tidal.md` — reference input

## Notes / limits
- Cover placeholders are matched by the template's reference text; if the template
  file is replaced, keep the same cover labels (Version:, Authored by:, etc.).
- To change team size / pricing / scope: edit the markdown tables and re-run — no code
  changes needed.
- Third-party MCP round-trips (Notion / Google Docs) are **not** used: they lose the
  Sotatek branding on export. Draft content in markdown; this skill produces the
  branded file.
