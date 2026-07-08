#!/usr/bin/env bash
# Optional QA render: convert a .docx to PDF (+ optional page JPEGs) with LibreOffice.
#
# Building the .docx needs NO render. Use this only for a final visual check.
#
# Key rules to keep it fast/stable:
#   * reuse ONE initialised profile ($PROFILE) so first-run font caching happens once
#   * NEVER `kill -9` soffice mid-run (that corrupts the profile and forces slow re-init)
#   * the first conversion on a fresh machine can take a few minutes; later ones are quicker
#
# Usage:  ./render.sh path/to/file.docx [firstPage lastPage]
set -euo pipefail

DOCX="${1:?usage: render.sh file.docx [firstPage lastPage]}"
FIRST="${2:-}"; LAST="${3:-}"
SOFFICE="/Applications/LibreOffice.app/Contents/MacOS/soffice"
OUTDIR="$(cd "$(dirname "$DOCX")" && pwd)"
BASE="$(basename "${DOCX%.*}")"
PROFILE="${SOFFICE_PROFILE:-/tmp/lo_sotatek_profile}"
PDF="$OUTDIR/$BASE.pdf"

[ -x "$SOFFICE" ] || { echo "LibreOffice not found at $SOFFICE"; exit 1; }

rm -f "$PDF"
HOME="$OUTDIR" "$SOFFICE" --headless \
  -env:UserInstallation="file://$PROFILE" \
  --convert-to pdf --outdir "$OUTDIR" "$DOCX" >/dev/null 2>&1 || true

# wait for the PDF (first run may take minutes; never kill soffice here)
for _ in $(seq 1 120); do
  [ -f "$PDF" ] && [ "$(stat -f%z "$PDF" 2>/dev/null || echo 0)" -gt 10000 ] && break
  sleep 5
done
[ -f "$PDF" ] || { echo "render failed"; exit 1; }
echo "PDF: $PDF"

# optional page images via PyMuPDF (no poppler needed)
if [ -n "$FIRST" ]; then
  PY="$HOME/.claude/skills/.venv/bin/python3"
  [ -x "$PY" ] || PY="python3"
  "$PY" - "$PDF" "$OUTDIR/$BASE" "$FIRST" "${LAST:-$FIRST}" <<'PYEOF'
import sys, fitz
pdf, base, first, last = sys.argv[1], sys.argv[2], int(sys.argv[3]), int(sys.argv[4])
doc = fitz.open(pdf)
for i in range(first-1, min(last, len(doc))):
    doc[i].get_pixmap(dpi=105).save(f"{base}-p{i+1:02d}.jpg")
    print("page", i+1)
PYEOF
fi
