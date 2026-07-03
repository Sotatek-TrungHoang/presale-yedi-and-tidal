---
phase: 4
title: "Adverts-Job-Lifecycle"
status: pending
priority: P2
effort: "40d (MVP 26d)"
dependencies: []
---

# Phase 4: Adverts & Job Lifecycle

## Overview
The advert is the most complete entity in the system. The **data model is strong**;
the **lifecycle automation, publishing, and discovery** around it are weak/manual.

## Current State (verified)
- ✅ Rich advert model & form: title, brand, type (day-to-day/long-term), full address,
  start/end dates, shift start/end time, apply-by, rich-text description, **Documents repeater**,
  Payment & Charges (Brand Pay Rate £, rate type Daily, Brand Charge %, Candidate Charge %).
  (evidence: `02-advert-detail.png`, `adverts/create`)
- ✅ Status enum: Approved / Filled / Not filled / Pending allocation / Pending approval / Rejected.
- 🟡 Status change is a **manual "Update status" select** (one listbox), no workflow/guards. (evidence: status modal)
- 🟡 List has status-filter tabs + bulk actions + column toggles (standard Filament).
- 🔴 No public/published advert view, no candidate-facing search, no geocoding, no slots/headcount (1 advert = 1 role? unclear), no auto-expiry on apply-by.

## Production-Grade Target
- Advert lifecycle as a **state machine** with allowed transitions + side-effects
  (approve → publish → allocate → fill → complete/close), not a free select.
- **Multi-slot adverts** (e.g. "need 5 ambassadors") with per-slot allocation.
- Brand self-posting → admin approval gate (P2) before publish.
- **Published/public advert page** (SEO-friendly) + candidate search/filter (role, type, location, date, pay).
- Geocoding of address → distance search.
- Auto-transitions: close on apply-by, mark not-filled, reminders.
- Advert templates / duplication; draft state.

## Feature Gap Matrix
| # | Feature | Current | Target | Gap |
|---|---------|---------|--------|-----|
| 4.1 | Advert data model | ✅ | ✅ (+ slots/headcount) | Add headcount/slots |
| 4.2 | Status enum | ✅ | ✅ | — |
| 4.3 | Lifecycle state machine | 🟡 manual select | Guarded transitions + side-effects | State-machine logic |
| 4.4 | Approval workflow | 🟡 status only | Brand submit → admin approve | Approval flow + notifications |
| 4.5 | Multi-slot allocation | 🔴 | N candidates per advert | Slot model + allocation |
| 4.6 | Public advert page | 🔴 | Published, shareable, SEO | Public controller + view |
| 4.7 | Candidate search/filter | 🔴 | Role/type/location/date/pay | Search index + filters |
| 4.8 | Geo / distance | 🔴 | Geocode + radius search | Geocoding integration |
| 4.9 | Auto-expiry/reminders | 🔴 | Close on apply-by, nudge | Scheduled jobs |
| 4.10 | Draft / duplicate / template | 🔴 | Reuse adverts fast | Draft state + clone |

## Build Scope (the gap)
- Formalize advert lifecycle as a state machine with transition guards + events.
- Add headcount/slots to support multi-hire adverts (impacts P5 matching, P8 billing per slot).
- Public advert pages + candidate search (geocoding) for the candidate portal (P3).
- Scheduled jobs for expiry/reminders.

## Risk Assessment
- "1 advert = 1 booking" vs "1 advert = N slots" is a **model-defining decision** that ripples into
  matching, timesheets, and billing. Resolve early; current data has only 1 advert so intent is unproven.
