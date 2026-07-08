"""Render a .docx to PDF with LibreOffice and map heading text -> body page number.

Used only for the default (static, populated) TOC mode: one render measures real
page numbers, then the doc is rebuilt with them. Layout is identical between the
placeholder build and the final build (same number of TOC lines), so one render
suffices.
"""
import os
import subprocess
import time

SOFFICE = "/Applications/LibreOffice.app/Contents/MacOS/soffice"
PROFILE = os.environ.get("SOFFICE_PROFILE", "/tmp/lo_sotatek_profile")


def render_pdf(docx_path, timeout=None):
    if timeout is None:
        timeout = int(os.environ.get("RENDER_TIMEOUT", "1200"))
    """Convert docx -> pdf (same dir). Reuse one profile; never kill soffice."""
    outdir = os.path.dirname(os.path.abspath(docx_path))
    pdf = os.path.join(outdir, os.path.splitext(os.path.basename(docx_path))[0] + ".pdf")
    if os.path.exists(pdf):
        os.remove(pdf)
    env = dict(os.environ, HOME=outdir)
    # fire-and-forget; poll for the file (headless convert is a fresh process each call)
    subprocess.Popen(
        [SOFFICE, "--headless", "-env:UserInstallation=file://%s" % PROFILE,
         "--convert-to", "pdf", "--outdir", outdir, docx_path],
        env=env, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    waited = 0
    while waited < timeout:
        if os.path.exists(pdf) and os.path.getsize(pdf) > 10000:
            time.sleep(1)
            return pdf
        time.sleep(5)
        waited += 5
    raise TimeoutError("LibreOffice render timed out after %ss" % timeout)


def map_heading_pages(pdf_path, headings):
    """headings: list of (level, text). Return {text: 1-based body page}.
    Matches on exact rendered lines, so TOC lines (which carry dot leaders +
    number) never match — only real body headings do."""
    import fitz
    want = {t.strip() for _, t in headings}
    found = {}
    doc = fitz.open(pdf_path)
    for pi in range(len(doc)):
        for line in doc[pi].get_text("text").split("\n"):
            s = line.strip()
            if s in want and s not in found:
                found[s] = pi + 1
    return found
