---
phase: 5
title: "Applications-Matching-Booking"
status: pending
priority: P1
effort: "58d"
dependencies: [4, 6]
---

# Phase 5: Applications, Matching & Booking (CORE LOOP)

## Overview
**The heart of the marketplace** — candidate applies → agency/brand matches → booking is
confirmed → shift happens. This is **empty scaffolding today** and is the single biggest gap:
without it there is no income, no invoice, no payslip.

## Current State (verified — incl. black-box behavioral test)
- ✅ **Application CRUD + aggregation WORKS** *(black-box: created an Accepted application, observed effects, then deleted)*:
  setting status=Accepted updated **advert.accepted_application** (= the candidate) and incremented the
  **candidate's Accepted count**. So the entity + relationships + aggregation logic are real, not a bare scaffold.
  (evidence: `evidences/blackbox/t1-application-create.png`, `t1-advert-1.png`, `t1-candidates-list.png`)
- 🔴 **No Booking/Allocation entity** — the relationship is application↔advert↔candidate only; no separate confirmed-assignment object.
- 🔴 **No state side-effects** — advert status did **not** auto-move to "Filled" on an Accepted application.
- 🔴 **No downstream trigger** — no "Allocate / Confirm booking / Generate invoice/payslip" action anywhere; Invoices/Payslips stayed empty. (evidence: `t1-invoices-after.png`, `t1-payslips-after.png`)
- 🔴 No matching/eligibility, no offer/accept handshake, no availability, no clash detection.

## Production-Grade Target
- **Application**: candidate→advert with status lifecycle (applied → shortlisted → offered →
  accepted/declined → withdrawn → rejected), timestamps, audit.
- **Matching**: filter eligible candidates (compliant, right role/type, available, in range);
  optional ranking/suggestions; bulk invite.
- **Offer/accept handshake** between brand/agency and candidate (with expiry).
- **Booking/Assignment** entity = confirmed candidate↔advert(/slot)↔date(s): the object timesheets,
  invoices, payslips all hang off.
- **Availability & clash detection** (no double-booking a candidate across overlapping shifts).
- Cancellation/no-show handling with policy (affects charges).
- Allocation against advert headcount/slots (P4).

## Feature Gap Matrix
| # | Feature | Current | Target | Gap |
|---|---------|---------|--------|-----|
| 5.1 | Application entity | 🟡 CRUD+aggregation works | Full status lifecycle + audit | Extend status lifecycle, events (base exists) |
| 5.2 | Candidate apply | 🔴 | From candidate portal | Depends on P3 |
| 5.3 | Matching/eligibility | 🔴 | Compliance+role+availability filter | Eligibility engine |
| 5.4 | Suggestions/ranking | 🔴 | Suggest best-fit candidates | Scoring (optional) |
| 5.5 | Offer/accept handshake | 🔴 | Two-sided confirm + expiry | Offer model + flow |
| 5.6 | Booking/Assignment entity | 🔴 | Confirmed assignment object | **New core entity** |
| 5.7 | Multi-slot allocation | 🔴 | Fill N of N | Depends on P4.5 |
| 5.8 | Availability model | 🔴 | Candidate availability | New model |
| 5.9 | Clash detection | 🔴 | Prevent double-booking | Overlap checks |
| 5.10 | Cancellation/no-show | 🔴 | Policy + charge impact | Rules + hooks to P8 |

## Build Scope (the gap)
- Implement Application status lifecycle + events (largely greenfield logic on the scaffold).
- **Introduce the Booking/Assignment entity** — the missing keystone that P7/P8/P9 depend on.
- Eligibility/matching engine (consumes P6 compliance + availability).
- Offer/accept handshake across admin/brand/candidate surfaces (P2/P3).
- Availability + clash detection.

## Risk Assessment
- **Highest-risk gap.** Everything downstream (timesheets, invoices, payslips, payments, dashboards)
  is meaningless until this exists and is correct.
- The Booking entity may or may not exist in code (not visible in admin nav) — **confirm via source**;
  if absent it is a foundational new model touching the whole schema.
- Money correctness (charges, cancellations) lives here — must be airtight + tested (P14).
