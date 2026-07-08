"""Rewrite the template's cover page + front-matter tables from YAML front-matter.

Placeholders are matched by their Naisiti reference text (content-based, not by
index) so the mapping survives small template edits.
"""
from docx.oxml.ns import qn
from docx.table import Table
from .docx_helpers import set_para_wt, reset_cell, W


def _wt(el):
    return "".join(t.text or "" for t in el.iter(W("t")))


def _para_starting(body, doc, prefix):
    for ch in body.iterchildren():
        if ch.tag == W("p") and _wt(ch).strip().startswith(prefix):
            return ch
    return None


def _para_equals(body, prefix):
    for ch in body.iterchildren():
        if ch.tag == W("p") and _wt(ch).strip() == prefix:
            return ch
    return None


def _table_with_header(doc, first_header):
    for t in doc.tables:
        if t.rows and t.rows[0].cells[0].text.strip() == first_header:
            return t
    return None


def _fill_row(table, ridx, values, ensure=True):
    if ensure:
        while len(table.rows) <= ridx:
            table.add_row()
    for ci, val in enumerate(values):
        if ci < len(table.columns):
            reset_cell(table.cell(ridx, ci), str(val))


def apply_cover(doc, fm):
    body = doc.element.body

    def rep(old_text, new_text, starts=False):
        el = _para_starting(body, doc, old_text) if starts else _para_equals(body, old_text)
        if el is not None and new_text is not None:
            set_para_wt(el, new_text)

    rep("NAISITI", fm.get("project", "PROJECT"))
    rep("Presence & Connection Platform", fm.get("subtitle", ""))
    rep("Mobile Application", fm.get("tagline", ""), starts=True)
    rep("Version:", "Version: %s" % fm.get("version", "v1.0"), starts=True)
    rep("Authored by:", "Authored by: %s" % fm.get("author", ""), starts=True)
    rep("Approved by:", "Approved by: %s" % fm.get("approver", ""), starts=True)
    rep("Hanoi,", "%s, %s" % (fm.get("location", "Hanoi"), fm.get("date", "")), starts=True)

    # Presenter table
    pres = fm.get("presenter") or {}
    pt = _table_with_header(doc, "Presenter")
    if pt:
        _fill_row(pt, 1, [pres.get("name", ""), pres.get("position", ""),
                          pres.get("division", "")])

    # Edit history (list of {date,version,description,editor})
    eh = _table_with_header(doc, "Date")
    if eh:
        rows = fm.get("edit_history") or [{}]
        for i, e in enumerate(rows):
            _fill_row(eh, 1 + i, [e.get("date", ""), e.get("version", ""),
                                  e.get("description", ""), e.get("editor", "")])

    # Approval (list of {date,version,approver,position})
    ap = _table_with_header(doc, "Approved date")
    if ap:
        rows = fm.get("approval") or [{"version": fm.get("version", "1.0")}]
        for i, a in enumerate(rows):
            _fill_row(ap, 1 + i, [a.get("date", ""), a.get("version", ""),
                                  a.get("approver", ""), a.get("position", "")])
