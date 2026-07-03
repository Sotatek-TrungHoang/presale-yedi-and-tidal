---
phase: 8
title: "Billing-Invoices-Payslips"
status: pending
priority: P1
effort: "55d (MVP 44d)"
dependencies: [5, 7]
---

# Phase 8: Billing — Invoices & Payslips

## Overview
Turn approved work into money documents. **Config exists, generation does not.** The agency's
whole revenue model (charge both sides) lives here and currently produces nothing.

## Current State (verified)
- ✅ **System billing config is set up**: References required; default applicant/advertiser charge %
  (10/10); **Invoice config**: due-date days (7), late-payment charge % (20), **bank account name/number/sort-code**,
  invoice contact email/phone/address. (evidence: `system` page)
- ✅ Per-advert pricing: Brand Pay Rate, rate type, Brand Charge %, Candidate Charge %.
- ✅ Dashboard has financial widgets (Income / Expenditure / Brand Charges / Candidate Charges / Profit) — all £0.
- 🔴 **Invoices: 0 records, no "New" button** → meant to auto-generate; **no generation engine exists**. (evidence: `08-invoices-empty.png`)
- 🔴 **Payslips: 0 records, no "New" button** → same. (evidence: `09-payslips-empty.png`)
- 🔴 No PDF rendering, no numbering, no tax/VAT handling, no credit notes, no statement of account.

## Production-Grade Target
- **Invoice generation** from approved timesheets (P7): line items, brand charge %, VAT, due date,
  late-fee terms, sequential numbering, branded PDF.
- **Payslip generation** for candidates: gross from hours/rate, candidate charge % deduction,
  tax/NI treatment (or umbrella/self-employed handling), PDF.
- Billing run (batch weekly/monthly) + per-booking on-demand.
- Lifecycle: draft → issued → sent → paid/overdue/part-paid → cancelled/credited.
- VAT/tax correctness; credit notes; statements; export to accounting (Xero/Sage/CSV).
- Recompute guards (can't edit issued invoice; credit-note instead).

## Feature Gap Matrix
| # | Feature | Current | Target | Gap |
|---|---------|---------|--------|-----|
| 8.1 | Billing config | ✅ | ✅ | — |
| 8.2 | Charge model per advert | ✅ | ✅ | — |
| 8.3 | Invoice generation engine | 🔴 | From approved timesheets | **Core build** (depends P7) |
| 8.4 | Payslip generation engine | 🔴 | From hours + deductions | **Core build** (depends P7) |
| 8.5 | PDF rendering | 🔴 | Branded invoice/payslip PDF | PDF templating |
| 8.6 | Sequential numbering | 🔴 | Per-tenant invoice numbers | Numbering + integrity |
| 8.7 | VAT / tax | 🔴 | Correct VAT + candidate tax/NI | Tax rules (needs accountant input) |
| 8.8 | Invoice lifecycle | 🔴 | draft→issued→paid→overdue | State machine + late fees |
| 8.9 | Credit notes / adjustments | 🔴 | Corrections without editing issued | Credit-note model |
| 8.10 | Statements / accounting export | 🔴 | Xero/Sage/CSV | Export integration |
| 8.11 | Financial dashboard data | 🟡 widgets, £0 | Real figures | Wire to real billing data |

## Build Scope (the gap)
- **Invoice + payslip generation engines** computing off approved timesheets (P7) and advert charge config.
- PDF templating (reuse System contact/bank config + contract branding).
- Numbering, VAT/tax rules, lifecycle (issued→paid→overdue→credit), accounting export.
- Wire the existing dashboard financial widgets to real generated data.

## Risk Assessment
- **Tax/VAT + candidate employment status (PAYE vs umbrella vs self-employed)** is the biggest unknown —
  drives payslip correctness and is compliance-sensitive; needs the client's accountant to specify.
- Depends on P7 (approved hours) and P5 (booking) — cannot produce correct money before those exist.
- Config already present (bank/terms/contracts) reduces setup work; the **engine** is the real gap.
