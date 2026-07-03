---
phase: 9
title: "Payments-Settlement"
status: pending
priority: P2
effort: "32d (MVP 8d)"
dependencies: [8]
---

# Phase 9: Payments & Settlement

## Tổng quan
Chuyển tiền thực sự: thu tiền từ brands, trả tiền cho candidates, reconciling. **Vắng mặt.**
Hiện tại settlement ngầm định là offline (bank details in trên invoice). Production cần
tối thiểu là payment được tracked/reconciled, lý tưởng nhất là tự động collection + payout.

## Hiện trạng (verified)
- 🟡 Invoice config giữ **bank account name/number/sort-code** → payment là **offline bank transfer**, reconciled thủ công.
- 🔴 Không có payment gateway, không direct debit, không payout rail, không reconciliation, không payment status automation,
  không có candidate payout records ngoài payslips (vốn vắng mặt).

## Mục tiêu Production-Grade
- **Brand collection**: GoCardless (BACS direct debit) hoặc Stripe; tự động đánh dấu invoices đã paid khi settlement.
- **Candidate payout**: scheduled BACS/Faster Payments (hoặc qua umbrella), payout records reconciled với payslips.
- **Reconciliation**: match incoming/outgoing bank transactions với invoices/payslips; flag các mismatch.
- Payment status webhooks → invoice lifecycle (P8); retries, failures, late-fee triggers.
- Client-money handling/segregation nếu agency giữ funds (regulatory).
- Refunds / partial payments / write-offs.

## Feature Gap Matrix
| # | Feature | Current | Target | Gap |
|---|---------|---------|--------|-----|
| 9.1 | Offline bank details | 🟡 on invoice | Giữ làm fallback | — |
| 9.2 | Brand collection (DD/card) | 🔴 | GoCardless/Stripe | Gateway integration |
| 9.3 | Auto mark-paid | 🔴 | Webhook → invoice paid | Webhooks → P8 |
| 9.4 | Candidate payout | 🔴 | Scheduled BACS / umbrella | Payout rail |
| 9.5 | Reconciliation | 🔴 | Bank ↔ docs matching | Recon engine / feed |
| 9.6 | Retries / failures / late fees | 🔴 | Dunning + late charge | Dunning logic |
| 9.7 | Refunds / part-pay / write-off | 🔴 | Adjustments | Flows → P8 credit notes |
| 9.8 | Client-money segregation | 🔴 | Regulatory handling nếu áp dụng | Policy + accounts |

## Build Scope (phần gap)
- Payment gateway integration cho collection (GoCardless khuyến nghị cho B2B BACS) + payout mechanism.
- Webhook handling → invoice/payslip lifecycle; dunning/late-fee automation.
- Reconciliation tooling.
- (Scope kiểu Phase-2: có thể launch với offline + tracked payments, automate sau.)

## Risk Assessment
- Regulatory: nếu agency giữ client money, cần xét segregation/FCA — confirm model.
- Candidate payment route (PAYE/umbrella/self-employed) quyết định payout mechanism — cùng unknown như P8.7.
- Mức độ khẩn cấp thấp hơn P5–P8: cách tiếp cận tracked-offline có thể ship trước.
