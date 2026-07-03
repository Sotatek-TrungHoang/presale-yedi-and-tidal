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
Biến công việc đã approve thành money documents. **Config có sẵn, generation thì không.** Toàn bộ
revenue model của agency (charge cả hai phía) nằm ở đây và hiện không tạo ra gì cả.

## Current State (đã verify)
- ✅ **System billing config đã được set up**: References required; default applicant/advertiser charge %
  (10/10); **Invoice config**: due-date days (7), late-payment charge % (20), **bank account name/number/sort-code**,
  invoice contact email/phone/address. (evidence: trang `system`)
- ✅ Pricing theo advert: Brand Pay Rate, rate type, Brand Charge %, Candidate Charge %.
- ✅ Dashboard có financial widgets (Income / Expenditure / Brand Charges / Candidate Charges / Profit) — tất cả £0.
- 🔴 **Invoices: 0 records, không có nút "New"** → ý là auto-generate; **không có generation engine nào tồn tại**. (evidence: `08-invoices-empty.png`)
- 🔴 **Payslips: 0 records, không có nút "New"** → tương tự. (evidence: `09-payslips-empty.png`)
- 🔴 Không có PDF rendering, không numbering, không xử lý tax/VAT, không credit notes, không statement of account.

## Production-Grade Target
- **Invoice generation** từ approved timesheets (P7): line items, brand charge %, VAT, due date,
  late-fee terms, sequential numbering, branded PDF.
- **Payslip generation** cho candidates: gross từ hours/rate, trừ candidate charge %,
  xử lý tax/NI (hoặc xử lý umbrella/self-employed), PDF.
- Billing run (batch weekly/monthly) + theo booking on-demand.
- Lifecycle: draft → issued → sent → paid/overdue/part-paid → cancelled/credited.
- Độ chính xác VAT/tax; credit notes; statements; export sang accounting (Xero/Sage/CSV).
- Recompute guards (không sửa được issued invoice; dùng credit-note thay thế).

## Feature Gap Matrix
| # | Feature | Current | Target | Gap |
|---|---------|---------|--------|-----|
| 8.1 | Billing config | ✅ | ✅ | — |
| 8.2 | Charge model theo advert | ✅ | ✅ | — |
| 8.3 | Invoice generation engine | 🔴 | Từ approved timesheets | **Core build** (phụ thuộc P7) |
| 8.4 | Payslip generation engine | 🔴 | Từ hours + deductions | **Core build** (phụ thuộc P7) |
| 8.5 | PDF rendering | 🔴 | Branded invoice/payslip PDF | PDF templating |
| 8.6 | Sequential numbering | 🔴 | Invoice numbers per-tenant | Numbering + integrity |
| 8.7 | VAT / tax | 🔴 | VAT đúng + candidate tax/NI | Tax rules (cần input accountant) |
| 8.8 | Invoice lifecycle | 🔴 | draft→issued→paid→overdue | State machine + late fees |
| 8.9 | Credit notes / adjustments | 🔴 | Sửa lỗi không cần edit issued | Credit-note model |
| 8.10 | Statements / accounting export | 🔴 | Xero/Sage/CSV | Export integration |
| 8.11 | Financial dashboard data | 🟡 widgets, £0 | Số liệu thật | Wire vào billing data thật |

## Build Scope (gap)
- **Invoice + payslip generation engines** tính từ approved timesheets (P7) và advert charge config.
- PDF templating (tái sử dụng System contact/bank config + contract branding).
- Numbering, VAT/tax rules, lifecycle (issued→paid→overdue→credit), accounting export.
- Wire các financial widgets dashboard hiện có vào data thật được generate.

## Risk Assessment
- **Tax/VAT + employment status của candidate (PAYE vs umbrella vs self-employed)** là ẩn số lớn nhất —
  quyết định độ chính xác payslip và nhạy cảm về compliance; cần accountant của client chỉ định.
- Phụ thuộc P7 (approved hours) và P5 (booking) — không thể tạo money đúng trước khi chúng tồn tại.
- Config đã có sẵn (bank/terms/contracts) giảm công setup; **engine** mới là gap thực sự.
