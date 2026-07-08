# Sotatek Proposal Generator

Markdown → branded Sotatek `.docx`. Preserves the template's cover, logo/watermark
header, contact footer, heading styles, table look, bullet numbering, and produces a
correct Table of Contents.

## Quick start

```bash
PY=~/.claude/skills/.venv/bin/python3
SK=.claude/skills/sotatek-proposal

# Default: fully-populated static TOC (one LibreOffice render, correct everywhere)
$PY $SK/build_proposal.py my-quote.md output/Sotatek_MyQuote.docx

# Fast draft: field TOC, ZERO render (~1s). TOC page numbers fill in on open in Word.
$PY $SK/build_proposal.py my-quote.md output/Sotatek_MyQuote.docx --fast
```

## Two TOC modes

| Mode | Speed | TOC in the delivered file | Use when |
|---|---|---|---|
| default (static) | one render (~seconds–minutes) | fully populated, correct in any viewer | sending the final file / a PDF |
| `--fast` (field) | ~1s, no render | shows a placeholder until opened + updated in **Word** | quick drafts, or you'll finish in Word |

Both builds are otherwise identical; the static mode just renders once to read real
page numbers, then rebuilds with them (layout is unchanged, so one render is enough).

## Markdown format
See `SKILL.md` and `examples/proposal-yedi-tidal.md`. Front-matter → cover; `#/##/###`
→ headings; `-` → bullets; markdown tables → styled tables (alignment from the
separator row); `>` → small italic note; `**bold**` / `*italic*` inline.

To change **team size / pricing / scope**: edit the markdown tables and re-run. No code.

## Why not Notion / Google Docs round-trips
Exporting from Notion or Google Docs loses the Sotatek branding (cover watermark,
header/footer, custom table styles). Draft content wherever you like, but generate the
final branded file with this skill editing the real `.docx` template.

## Speed notes (LibreOffice)
- Each `soffice --convert-to` is a cold-start process; the first on a fresh machine can
  take minutes. Reuse one profile (`SOFFICE_PROFILE`, default `/tmp/lo_sotatek_profile`).
- **Never `kill -9` soffice mid-run** — it corrupts the profile and forces slow re-init.
- For frequent renders, run LibreOffice as a persistent listener + `unoconv`/UNO client
  to cut conversions to seconds (optional; not required for this skill).

## Files
```
build_proposal.py         CLI entry (md -> docx)
render.sh                 optional standalone QA render (docx -> pdf/jpeg)
lib/md_parser.py          markdown -> blocks + front-matter
lib/docx_helpers.py       brand constants, headings, tables, bullets, TOC field/entries
lib/cover.py              front-matter -> cover + front-matter tables
lib/render_map.py         render + heading->page mapping (static TOC mode)
examples/proposal-yedi-tidal.md   reference input
```
