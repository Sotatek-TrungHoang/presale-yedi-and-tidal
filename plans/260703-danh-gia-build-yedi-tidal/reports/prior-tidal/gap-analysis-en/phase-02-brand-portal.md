---
phase: 2
title: "Brand-Portal"
status: pending
priority: P1
effort: "60d (MVP 44d)"
dependencies: [1]
---

# Phase 2: Brand-Facing Portal (self-service)

## Overview
The whole brand-side web surface. **Does not exist** — today brands are managed by admin
staff inside Filament. A brand account exists in data but cannot log in or do anything itself.

## Current State (verified)
- 🟡 Brand entity exists admin-side: name, email, phone, status, compliance, bio, additional info,
  contact-with-login. (evidence: `advertisers/create`, `06-brands-list.png`)
- 🔴 No brand-facing app of any kind: no dashboard, no advert posting, no application review, no invoices view.

## Production-Grade Target
Self-service portal where a brand can run its hiring without phoning the agency:
- Onboarding: company profile, billing/legal details, compliance docs upload, accept terms.
- **Post & manage adverts** (the existing rich advert form, brand-scoped): create, edit, duplicate, close.
- See incoming **applications**; shortlist / accept / decline candidates; view candidate profile (compliance-masked).
- **Bookings** view: who is booked for which shift, calendar.
- Approve/confirm **timesheets** submitted by candidates.
- **Invoices**: list, download PDF, payment status.
- Messaging/notifications with agency + candidates.
- Multi-user (owner invites colleagues) — see P1.

## Feature Gap Matrix
| # | Feature | Current | Target | Gap |
|---|---------|---------|--------|-----|
| 2.1 | Brand dashboard | 🔴 | KPIs: open adverts, applicants, upcoming shifts, outstanding invoices | New SPA/Blade surface |
| 2.2 | Company onboarding/profile | 🟡 admin-only | Self-edit profile + billing/legal | Brand-scoped forms |
| 2.3 | Post advert | 🟡 admin-only | Brand self-post (scoped) | Reuse model, new UI + scoping + approval gate |
| 2.4 | Manage adverts | 🔴 | Edit/close/duplicate own adverts | CRUD scoped to brand |
| 2.5 | Review applications | 🔴 | Shortlist/accept/decline | Depends on P5 |
| 2.6 | Candidate profile view | 🔴 | Compliance-aware masked view | Field-level visibility rules |
| 2.7 | Bookings/calendar | 🔴 | Confirmed shifts view | Depends on P5/P7 |
| 2.8 | Timesheet approval | 🔴 | Approve/dispute hours | Depends on P7 |
| 2.9 | Invoices view/pay | 🔴 | List + PDF + pay/status | Depends on P8/P9 |
| 2.10 | Messaging/notifications | 🔴 | In-app + email | Depends on P10 |
| 2.11 | Multi-user seats | 🔴 | Invite colleagues, roles | Depends on P1.10 |

## Build Scope (the gap)
- New brand web app (Blade+Livewire, or Filament panel, or decoupled SPA + API).
- Brand-scoped data access (every query filtered by brand_id) + authorization policies.
- Reuse existing Advert model/validation; build brand-facing posting + approval handshake with admin.
- Bind to P5 (applications), P7 (timesheets), P8/P9 (invoices/pay), P10 (comms).

## Risk Assessment
- Largest single surface. Tight coupling to P5/P7/P8 — cannot be "done" before those exist; build incrementally.
- Decision needed: extend a second Filament panel vs custom front-end. Affects design-system & DX (see P12/P3).
