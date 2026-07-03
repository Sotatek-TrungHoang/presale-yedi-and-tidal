---
title: "Tidal-Yedi Feature Gap Analysis: Current vs Production-Grade"
description: "Feature-by-feature inventory of the existing Laravel+Filament staffing admin vs a production-grade two-sided staffing marketplace. Documents current state, target, and concrete gap per domain. No cost estimation."
status: pending
priority: P1
branch: "main"
tags: [gap-analysis, presale, staffing-marketplace, filament]
blockedBy: []
blocks: []
created: "2026-06-29T03:31:12.698Z"
createdBy: "ck:plan"
source: skill
---

# Tidal-Yedi Feature Gap Analysis: Current vs Production-Grade

## Overview

Feature-by-feature gap analysis of the client-built **Tidal/Yedi** staffing agency
platform. Goal: replace hand-wavy "build the rest" with a concrete inventory —
**what exists today (verified live), what production-grade requires, and the exact gap.**

- **System under analysis:** Laravel + **Filament** admin panel, `admin.tidalagency.co.uk`.
- **Business model:** two-sided recruitment marketplace (Brands ↔ Candidates), agency takes
  commission both sides (Brand Charge %, Candidate Charge %).
- **Evidence base:** `tidal-teardown-live-findings.md`, `tidal-agency-analysis.md`,
  `evidences/*.png` (11 screenshots), deep live crawl of every resource create/edit
  form and the System settings page, **plus a 4-agent black-box behavioral test**
  (`tidal-blackbox-test-findings.md`, `evidences/blackbox/*.png`, 47 screenshots) — all 2026-06-29.
- **Black-box corrections applied** (behavioral, not UI-only): Application CRUD + aggregation
  logic *works* (not bare scaffold); invoice/payslip generation *confirmed absent* (no trigger anywhere);
  candidate evidence capture (ID/video/contract) *is real* → a candidate onboarding flow likely exists;
  Declarations create is *broken* (server upload bug); **admin has NO RBAC** (earlier "role selector" was
  a misread of the Title field — corrected).
- **Scope note:** this document is a **feature/gap map only** — no man-day or cost figures
  (per request). It is the input for a later estimation/roadmap pass.

## How to read this

Each phase = one **feature domain**. Inside each phase:
- **Current State (verified)** — what actually works in the live app, with evidence refs.
- **Production-Grade Target** — what a real, sellable staffing platform must do.
- **Feature Gap Matrix** — line-by-line `Feature | Current | Target | Gap`.
- **Build Scope (the gap)** — the concrete work the gap implies.

**Maturity legend (per feature):**
- ✅ **Done** — exists & usable as-is.
- 🟡 **Partial** — scaffold/data-model exists but logic, UI, or flow incomplete.
- 🔴 **Missing** — not present; greenfield build.

## Headline finding

The platform has a **solid data-model + admin-CRUD spine** but the **transactional
muscles and all self-service surfaces are absent**:

- ✅ **Spine exists:** rich Advert model (pricing/charges/shifts/address), deep Candidate
  model (4-tab profile, references, **real ID/video/contract evidence**, compliance status),
  Brand model, **and a fully-configured System settings** (charge %, references-required,
  invoice bank/terms, applicant + advertiser **contract templates**). Brand & Candidate records
  carry **login user accounts**. Application CRUD + aggregation (advert.accepted_application,
  candidate counts) **works** — verified by black-box.
- 🔴 **Core transaction loop stops after Application:** Application persists + updates relations,
  but there is **no Booking entity**, advert status does **not** auto-transition, and **no
  invoice/payslip generation trigger exists anywhere** (verified — not just empty lists).
- 🔴 **No live brand/candidate front-end exists** *(domain recon verified)*: `tidalagency.co.uk` is a
  marketing site (no login/register); `app.tidalagency.co.uk` is a bare nginx 403 placeholder (no app
  deployed); `admin.tidalagency.co.uk` (Laravel/Filament) is the only real app. The candidate evidence
  (video/ID/contract) seen in admin is **most likely dev/test seed data** — candidates + login are all
  `@ne6.studio` (the build agency). So P2/P3 portals are confirmed **greenfield**, not partially built.
- 🔴 **No admin RBAC** (corrected): user form has no role/permission field; identity is likely
  polymorphic (separate applicant/advertiser/admin tables).
- 🔴 **No self-service:** no Brand portal, no Candidate portal — accounts exist but there is
  nowhere for them to log in. Everything is admin-operated.
- 🔴 **Compliance unconfigured:** Required Evidence + Declarations tables empty; Job Roles =
  only "Any Role". The compliance *engine* (rules, enforcement, right-to-work) is not built.
- 🔴 **No multi-tenancy:** single Tidal deployment; Yedi not verifiable; no white-label layer.

## Phases (feature domains)

| Phase | Domain | Current maturity | Headline gap | Priority |
|-------|--------|------------------|--------------|----------|
| 1 | [Identity-Auth-Access](./phase-01-identity-auth-access.md) | 🟡 Admin auth + accounts exist | No portal auth, no reset/verify/2FA, partial RBAC | P1 |
| 2 | [Brand-Portal](./phase-02-brand-portal.md) | 🔴 None | Entire brand self-service surface | P1 |
| 3 | [Candidate-Portal](./phase-03-candidate-portal.md) | 🔴 None | Entire candidate self-service surface | P1 |
| 4 | [Adverts-Job-Lifecycle](./phase-04-adverts-job-lifecycle.md) | 🟡 Rich model, manual status | Approval flow, publish, search, geo | P2 |
| 5 | [Applications-Matching-Booking](./phase-05-applications-matching-booking.md) | 🔴 Empty scaffold | The core marketplace loop | P1 |
| 6 | [Compliance-RightToWork](./phase-06-compliance-righttowork.md) | 🟡 Status fields only | Rules engine, evidence enforcement, RTW | P1 |
| 7 | [Timesheets-Attendance](./phase-07-timesheets-attendance.md) | 🔴 None | Shift confirmation → hours → pay basis | P1 |
| 8 | [Billing-Invoices-Payslips](./phase-08-billing-invoices-payslips.md) | 🟡 Config only, 0 docs | Generation engine + PDF + lifecycle | P1 |
| 9 | [Payments-Settlement](./phase-09-payments-settlement.md) | 🔴 None | Collection + payout + reconciliation | P2 |
| 10 | [Notifications-Comms](./phase-10-notifications-comms.md) | 🔴 None visible | Transactional email/SMS/in-app | P2 |
| 11 | [Documents-Contracts-Esign](./phase-11-documents-contracts-esign.md) | 🟡 Templates exist | Generation + e-signature + storage | P2 |
| 12 | [MultiTenancy-WhiteLabel](./phase-12-multitenancy-whitelabel.md) | 🔴 Single deploy | Tenant isolation + branding/config | P2 |
| 13 | [Reporting-Analytics](./phase-13-reporting-analytics.md) | 🟡 Basic dashboard | Operational + financial reporting | P3 |
| 14 | [NonFunctional-Security-QA](./phase-14-nonfunctional-security-qa.md) | 🔴 Unknown/none | Security, GDPR, tests, CI/CD, perf | P1 |

## Dependencies

Build-order coupling (not cross-plan):
- P5 (Matching/Booking) is the spine; P7 (Timesheets) → P8 (Billing) → P9 (Payments) chain off it.
- P1 (Auth) gates P2/P3 (portals).
- P6 (Compliance) gates P5 (only compliant candidates can be booked).
- P12 (Multi-tenancy) is cross-cutting — cheapest if decided before P2/P3 UI work.

## Open questions (blocking precise scoping)

1. **Source code access** — completeness of the empty modules' *backend* (controllers/services)
   is unknown without the repo. Some 🔴 may be 🟡.
2. **Yedi** — URL/login not provided; multi-tenant vs separate-deploy assumption unverified.
3. **Scope of "full app"** confirmed earlier: Brand + Candidate **web** portals (no native mobile),
   keep & extend Laravel/Filament, single multi-tenant, semi-automated payments.
