---
phase: 6
title: "Compliance-RightToWork"
status: pending
priority: P1
effort: "52d"
dependencies: []
---

# Phase 6: Compliance & Right-to-Work

## Overview
UK staffing legally requires right-to-work + evidence checks before a candidate can work.
The platform has **status fields and empty config tables** but **no compliance engine** —
nothing enforces that a "Compliant" candidate actually has the required evidence.

## Current State (verified — incl. black-box behavioral test)
- 🟡 **Evidence DATA exists, but no live capture surface** *(black-box + domain recon)*: candidate id=2's
  Identification tab shows **Photograph, Evidence of ID (image), Video verification (video player), ID number**;
  Contracts tab shows a **signed contract + file link** (`evidences/blackbox/t2-candidate-identification-tab.png`,
  `t2-candidate-contracts-tab.png`). So the **storage model for evidence is real**. BUT there is **no live
  candidate-facing capture flow** (no front-end exists — `app.` subdomain is an empty nginx placeholder), and
  all candidates are `@ne6.studio` dev accounts → this data is **most likely dev/test seed**, not proof of a
  working capture pipeline. Build the candidate upload/capture as **greenfield**; only the storage schema is reusable.
- ✅ **Required Evidence CRUD works** — create is a **modal/slide-over** (Title, Time-to-complete, Required), persists. (The earlier "empty `/create`" was just because it's modal-based.) (evidence: `t2-required-evidence-modal.png`, `t2-required-evidence-created.png`)
- ✅ **References workflow exists** — "Update references" modal: repeater of Name/Telephone/Email/Status (e.g. "Sent to Referee"). System policy **References required = 2**. (evidence: `t2-update-references-modal.png`)
- 🟡 Compliance status (Compliant / Non-compliant / Incomplete / Pending Approval) set manually via "Update status" — a **label, not a computed gate**.
- 🔴 **Declarations create is BROKEN (production bug)** — required Upload field fails server-side (Livewire temp-upload error `data.upload_id… failed to upload`); cannot create any declaration. (evidence: `t2-declaration-upload-error.png`)
- 🔴 **No enforcement** — no UI evidence that a non-compliant candidate is blocked from booking; compliance is declarative.
- 🔴 No rules engine (evidence catalog → checklist → computed status), no expiry tracking, no right-to-work integration.

## Production-Grade Target
- **Required Evidence catalog** per candidate type/role (passport, visa/share-code, DBS, proof of address, NI, etc.),
  each with: mandatory flag, expiry, accepted file types.
- **Document upload + verification** workflow (submitted → under review → approved/rejected/expired) with reviewer queue.
- **Declarations** issued to candidates, signed/acknowledged, tracked.
- **References** collection (target = 2): referee invite → response capture → status.
- **Right-to-work check** (manual reviewer workflow now; optional Yoti/identity provider later).
- **Compliance status auto-computed** from evidence completeness + validity + references + declarations.
- **Enforcement gate**: only Compliant candidates can be offered/booked (ties to P5).
- Expiry monitoring + re-request reminders.

## Feature Gap Matrix
| # | Feature | Current | Target | Gap |
|---|---------|---------|--------|-----|
| 6.1 | Compliance status field | 🟡 manual label | Auto-computed gate | Rules engine |
| 6.2 | Required Evidence catalog | 🟡 CRUD works (modal), unconfigured | Configurable per role/type | Seed + per-role/type + file types/expiry |
| 6.3 | Document upload | 🔴 no live capture (data=seed); storage schema exists | Candidate uploads per item | Build upload UI/flow greenfield (P3); reuse storage |
| 6.4 | Verification workflow | 🔴 | Reviewer queue + states | Workflow + admin UI |
| 6.5 | Expiry tracking | 🔴 | Track + re-request | Scheduled checks (P10) |
| 6.6 | Declarations issue/sign | 🔴 create BROKEN (upload bug) | Issue + capture acknowledgement | Fix upload bug + issue/sign flow |
| 6.7 | References collection | 🟡 workflow exists, policy=2 | Automated referee invites + capture | Automate invites/capture (base exists) |
| 6.8 | Right-to-work check | 🔴 | Manual workflow (+optional KYC) | Workflow now; integration later |
| 6.9 | Eligibility enforcement | 🔴 | Block non-compliant booking | Gate in P5 |
| 6.10 | Audit trail | 🔴 | Who verified what, when | Compliance audit log |

## Build Scope (the gap)
- Build the **compliance rules engine**: evidence catalog → per-candidate checklist → completeness
  computation → compliance status → booking eligibility.
- Reviewer queue + document verification states.
- References + declarations workflows.
- Manual right-to-work process now; keep an integration seam for Yoti/TrueLayer later (P9-adjacent).

## Risk Assessment
- **Legal/regulatory risk** if gating is wrong — a non-compliant candidate getting booked is a real
  liability. Enforcement must be hard, not advisory.
- "Compliant" today is a hand-set label on test data → the real rules are undefined; needs the client's
  actual evidence requirements as input.
