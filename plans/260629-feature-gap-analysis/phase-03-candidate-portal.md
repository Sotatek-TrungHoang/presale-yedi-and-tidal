---
phase: 3
title: "Candidate-Portal"
status: pending
priority: P1
effort: "70d (MVP 54d)"
dependencies: [1]
---

# Phase 3: Candidate-Facing Portal (responsive web)

## Overview
The whole candidate-side web surface. **Does not exist** — candidates are admin-managed.
This is where most candidates spend their time (find shifts, prove right-to-work, get paid),
so it is the highest-traffic surface and must be mobile-responsive.

## Current State (verified)
- 🟡 Candidate entity is the richest model: 4 tabs (Personal / Identification / Work / Contracts),
  status + compliance, references action, login account. (evidence: `03-candidate-detail.png`, `applicants/create`)
- 🟡 Candidate statuses exist (Incomplete / Pending Approval / Active) — implies an onboarding funnel
  that is currently completed *by admin*, not the candidate.
- 🔴 No candidate-facing app: no profile self-edit, no document upload, no job search, no apply,
  no booking accept, no timesheet, no payslip view.
- 🔴 **No live candidate front-end exists** *(domain recon verified 2026-06-29)*: `tidalagency.co.uk` =
  marketing site only (no login/register); `app.tidalagency.co.uk` = bare nginx 403 placeholder, nothing
  deployed (`/login`, `/api`, `/register` all 404); the Filament admin is the only running app.
  (evidence: `evidences/blackbox/t5-marketing-site-home.png`)
- Candidate records DO hold real video-verification + ID + signed-contract data
  (`evidences/blackbox/t2-candidate-identification-tab.png`, `t2-candidate-contracts-tab.png`), but with no
  live capture surface and all candidates/login `@ne6.studio` (the build agency), this is **most likely
  dev/test seed data** — NOT evidence of a working candidate pipeline. Treat this phase as **greenfield**.
  (Open: confirm whether an unreleased **mobile app** exists — marketing claims an "OnDemand App" but none found live.)

## Production-Grade Target
- **Onboarding wizard**: personal details, address, right-to-work evidence upload, qualifications,
  declarations, references → moves Incomplete → Pending → Compliant/Active.
- **Document upload** for each Required Evidence item (passport, visa, DBS, etc.) with status feedback.
- **Browse/search adverts**: filter by role, type, location, date; see pay rate (net of candidate charge).
- **Apply** to adverts; track application status.
- **Accept/decline bookings**; set availability/calendar.
- **Shift management**: view upcoming shifts, **clock-in/out or submit timesheet** (P7).
- **Payslips**: list + download PDF (P8).
- Notifications (offers, compliance reminders, shift reminders) (P10).
- Profile completeness meter + compliance status.

## Feature Gap Matrix
| # | Feature | Current | Target | Gap |
|---|---------|---------|--------|-----|
| 3.1 | Candidate dashboard | 🔴 | Status, next shift, action items | New responsive surface |
| 3.2 | Onboarding wizard | 🟡 admin-driven | Candidate self-serve funnel | Multi-step UI + state machine |
| 3.3 | Profile self-edit (4 sections) | 🟡 admin-only | Candidate edits Personal/Work | Scoped forms |
| 3.4 | Right-to-work doc upload | 🔴 (config empty) | Upload per Required Evidence | Depends on P6 |
| 3.5 | Declarations | 🔴 (config empty) | Sign required declarations | Depends on P6 |
| 3.6 | References | 🟡 admin action | Candidate submits referees, system collects | Reference workflow + emails |
| 3.7 | Job search/browse | 🔴 | Filterable advert list | Search + public advert view |
| 3.8 | Apply to advert | 🔴 | One-tap apply + track | Depends on P5 |
| 3.9 | Accept/decline booking | 🔴 | Respond to offers | Depends on P5 |
| 3.10 | Availability calendar | 🔴 | Set available dates | Availability model |
| 3.11 | Timesheet / clock | 🔴 | Submit hours per shift | Depends on P7 |
| 3.12 | Payslips | 🔴 | List + PDF | Depends on P8 |
| 3.13 | Notifications | 🔴 | Offers/reminders | Depends on P10 |

## Build Scope (the gap)
- New responsive candidate web app (mobile-first).
- Onboarding state machine driving the existing Incomplete→Pending→Active statuses self-service.
- Secure document upload tied to compliance rules (P6).
- Job search + apply + offer-response tied to P5.
- Availability model (new).

## Risk Assessment
- Mobile-responsive quality matters most here (candidates on phones) — design effort concentrated.
- Right-to-work UX is legally sensitive; must align with P6 compliance rules before shipping.
