---
phase: 13
title: "Reporting-Analytics"
status: pending
priority: P3
effort: "26d (MVP 8d)"
dependencies: [5, 8]
---

# Phase 13: Reporting & Analytics

## Overview
Operational + financial visibility for agency, brands, and finance. A **basic admin dashboard
exists**; real reporting (fed by actual transactions) does not — and there's nothing to report
on until the core loop produces data.

## Current State (verified)
- 🟡 Admin dashboard: count widgets (Brands 2, Candidates 9, Adverts 1) + financial widgets
  (Income/Expenditure/Brand Charges/Candidate Charges/Profit) all £0. (evidence: `01-dashboard.png`)
- 🔴 No date filters, no drill-down, no per-brand/per-candidate reports, no exports, no fill-rate/time-to-fill,
  no compliance reporting, no brand-facing or candidate-facing analytics.

## Production-Grade Target
- **Agency ops**: fill rate, time-to-fill, active candidates, compliance funnel, no-show rate, utilisation.
- **Financial**: revenue (both charges), margin, outstanding/overdue invoices, payouts, by period/brand/market.
- **Brand-facing**: their spend, bookings, upcoming shifts (in P2).
- **Candidate-facing**: earnings to date, shifts worked (in P3).
- Date-range filters, drill-down, CSV/PDF export, scheduled report emails.
- Per-tenant scoping (P12).

## Feature Gap Matrix
| # | Feature | Current | Target | Gap |
|---|---------|---------|--------|-----|
| 13.1 | Admin count widgets | 🟡 | ✅ | Wire to live data |
| 13.2 | Financial widgets | 🟡 £0 | Real revenue/margin | Depends on P8 data |
| 13.3 | Date filters / drill-down | 🔴 | Period + entity filters | Reporting queries |
| 13.4 | Ops KPIs (fill rate, TTF) | 🔴 | Recruitment metrics | Metric definitions + queries |
| 13.5 | Compliance reporting | 🔴 | Funnel + expiry view | Depends on P6 |
| 13.6 | Brand analytics | 🔴 | Spend/bookings | In P2 |
| 13.7 | Candidate earnings | 🔴 | Earnings/shifts | In P3 |
| 13.8 | Exports / scheduled | 🔴 | CSV/PDF + email | Export + scheduler |

## Build Scope (the gap)
- Reporting queries/aggregations once P5/P8 produce real data; wire existing widgets to live figures.
- Filtered, drillable reports + exports; ops + financial KPIs; per-tenant scoping.

## Risk Assessment
- Low urgency / last — depends on real data from P5/P8. Don't build before the loop produces transactions.
- The existing dashboard is a good shell to extend, not replace.
