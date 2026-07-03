---
phase: 9
title: "Payments-Settlement"
status: pending
priority: P2
effort: "32d (MVP 8d)"
dependencies: [8]
---

# Phase 9: Payments & Settlement

## Overview
Actually moving money: collecting from brands, paying candidates, reconciling. **Absent.**
Today settlement is implicitly offline (bank details printed on invoice). Production needs
at minimum tracked/reconciled payments, ideally automated collection + payout.

## Current State (verified)
- 🟡 Invoice config holds **bank account name/number/sort-code** → payment is **offline bank transfer**, manually reconciled.
- 🔴 No payment gateway, no direct debit, no payout rail, no reconciliation, no payment status automation,
  no candidate payout records beyond (absent) payslips.

## Production-Grade Target
- **Brand collection**: GoCardless (BACS direct debit) or Stripe; mark invoices paid automatically on settlement.
- **Candidate payout**: scheduled BACS/Faster Payments (or via umbrella), payout records reconciled to payslips.
- **Reconciliation**: match incoming/outgoing bank transactions to invoices/payslips; flag mismatches.
- Payment status webhooks → invoice lifecycle (P8); retries, failures, late-fee triggers.
- Client-money handling/segregation if agency holds funds (regulatory).
- Refunds / partial payments / write-offs.

## Feature Gap Matrix
| # | Feature | Current | Target | Gap |
|---|---------|---------|--------|-----|
| 9.1 | Offline bank details | 🟡 on invoice | Keep as fallback | — |
| 9.2 | Brand collection (DD/card) | 🔴 | GoCardless/Stripe | Gateway integration |
| 9.3 | Auto mark-paid | 🔴 | Webhook → invoice paid | Webhooks → P8 |
| 9.4 | Candidate payout | 🔴 | Scheduled BACS / umbrella | Payout rail |
| 9.5 | Reconciliation | 🔴 | Bank ↔ docs matching | Recon engine / feed |
| 9.6 | Retries / failures / late fees | 🔴 | Dunning + late charge | Dunning logic |
| 9.7 | Refunds / part-pay / write-off | 🔴 | Adjustments | Flows → P8 credit notes |
| 9.8 | Client-money segregation | 🔴 | Regulatory handling if applicable | Policy + accounts |

## Build Scope (the gap)
- Payment gateway integration for collection (GoCardless recommended for B2B BACS) + payout mechanism.
- Webhook handling → invoice/payslip lifecycle; dunning/late-fee automation.
- Reconciliation tooling.
- (Phase-2-style scope: can launch with offline + tracked payments, automate later.)

## Risk Assessment
- Regulatory: if the agency holds client money, segregation/FCA considerations apply — confirm model.
- Candidate payment route (PAYE/umbrella/self-employed) decides payout mechanism — same unknown as P8.7.
- Lower urgency than P5–P8: a tracked-offline approach can ship first.
