---
phase: 7
title: "Timesheets-Attendance"
status: pending
priority: P1
effort: "35d"
dependencies: [5]
---

# Phase 7: Timesheets & Attendance

## Overview
The bridge between "a shift happened" and "money is owed". **Entirely missing.** Without
captured/approved hours there is no defensible basis for invoices or payslips.

## Current State (verified)
- 🟡 Advert carries shift start/end time + date range → expected hours are derivable.
- 🟡 System charge model is **Daily** rate in sample data (Brand Pay Rate £150/Daily) — so pay may be
  per-day, but hourly is likely needed for retail shifts. Unconfirmed which the model supports.
- 🔴 No timesheet entity, no clock-in/out, no attendance, no approval flow, no variance handling.

## Production-Grade Target
- **Timesheet per booking/shift**: planned vs actual start/end, breaks, total hours/days.
- Candidate submission (clock-in/out or manual entry) from candidate portal (P3).
- Brand/agency **approval** + dispute/adjust flow (P2).
- No-show / late / cancelled handling → feeds charge rules (P5/P8).
- Support both **daily and hourly** pay bases; overtime/premium rates if needed.
- Lock approved timesheets as the immutable input to billing (P8).

## Feature Gap Matrix
| # | Feature | Current | Target | Gap |
|---|---------|---------|--------|-----|
| 7.1 | Timesheet entity | 🔴 | Per booking/shift | New model |
| 7.2 | Candidate submit hours | 🔴 | Clock or manual entry | Depends on P3 |
| 7.3 | Clock-in/out | 🔴 | Optional geo/time stamp | Capture mechanism |
| 7.4 | Brand approval | 🔴 | Approve/dispute/adjust | Depends on P2 |
| 7.5 | Daily vs hourly basis | 🟡 daily sample | Both supported | Confirm + extend model |
| 7.6 | Breaks / overtime | 🔴 | Deduct breaks, premium rates | Calc rules |
| 7.7 | No-show / cancellation | 🔴 | Status + charge impact | Rules → P8 |
| 7.8 | Approved-lock | 🔴 | Immutable billing input | Lock + versioning |

## Build Scope (the gap)
- New Timesheet model bound to the Booking entity from P5.
- Submission UI (candidate) + approval UI (brand/admin).
- Hours/days calculation engine (breaks, overtime, no-show) producing the billing basis for P8.

## Risk Assessment
- Pay basis (daily vs hourly, breaks, overtime) must match the client's real commercial terms —
  wrong assumptions here corrupt every invoice/payslip downstream.
- Depends entirely on P5 Booking entity existing first.
