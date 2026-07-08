"""Parse a proposal markdown file into (front_matter, blocks).

Supported markdown:
  ---  yaml front-matter  ---   (cover metadata; see README)
  # / ## / ###   -> heading level 1/2/3
  - item / * item                -> bullet (2-space indent = nested level 1)
  | a | b |  + |---|:--:|        -> table (alignment read from separator row)
  > note                          -> italic note line (small)
  blank line                      -> paragraph break
  everything else                 -> paragraph (consecutive lines joined)
Inline **bold** and *italic* are handled later at render time.
"""
import re
import yaml


def _split_front_matter(text):
    if text.startswith("---"):
        end = text.find("\n---", 3)
        if end != -1:
            fm = yaml.safe_load(text[3:end]) or {}
            body = text[end + 4:]
            return fm, body.lstrip("\n")
    return {}, text


def _is_table_sep(line):
    return bool(re.match(r"^\s*\|?[\s:|-]+\|?\s*$", line)) and "-" in line


def _row_cells(line):
    line = line.strip()
    if line.startswith("|"):
        line = line[1:]
    if line.endswith("|"):
        line = line[:-1]
    return [c.strip() for c in line.split("|")]


def _aligns(sep_cells):
    out = []
    for c in sep_cells:
        c = c.strip()
        left, right = c.startswith(":"), c.endswith(":")
        out.append("c" if left and right else "r" if right else "l")
    return out


def parse(text):
    fm, body = _split_front_matter(text)
    lines = body.split("\n")
    blocks = []
    para = []
    i, n = 0, len(lines)

    def flush_para():
        if para:
            blocks.append({"type": "para", "text": " ".join(para).strip()})
            para.clear()

    while i < n:
        line = lines[i]
        stripped = line.strip()

        # table: a pipe line followed by a separator line
        if stripped.startswith("|") and i + 1 < n and _is_table_sep(lines[i + 1]):
            flush_para()
            header = _row_cells(line)
            align = _aligns(_row_cells(lines[i + 1]))
            rows = [header]
            i += 2
            while i < n and lines[i].strip().startswith("|"):
                rows.append(_row_cells(lines[i]))
                i += 1
            blocks.append({"type": "table", "rows": rows, "align": align})
            continue

        if not stripped:
            flush_para()
            i += 1
            continue

        m = re.match(r"^(#{1,3})\s+(.*)$", stripped)
        if m:
            flush_para()
            blocks.append({"type": "heading", "level": len(m.group(1)),
                           "text": m.group(2).strip()})
            i += 1
            continue

        mb = re.match(r"^(\s*)[-*]\s+(.*)$", line)
        if mb:
            flush_para()
            level = 1 if len(mb.group(1)) >= 2 else 0
            blocks.append({"type": "bullet", "level": level,
                           "text": mb.group(2).strip()})
            i += 1
            continue

        if stripped.startswith(">"):
            flush_para()
            blocks.append({"type": "note", "text": stripped[1:].strip()})
            i += 1
            continue

        if stripped in ("---", "***", "___"):  # horizontal rule -> skip
            flush_para()
            i += 1
            continue

        para.append(stripped)
        i += 1

    flush_para()
    return fm, blocks
