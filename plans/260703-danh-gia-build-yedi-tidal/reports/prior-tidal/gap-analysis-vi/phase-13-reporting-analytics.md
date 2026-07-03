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
Visibility vận hành + tài chính cho agency, brands, và finance. **Đã có dashboard admin cơ bản**;
reporting thực sự (được nuôi bởi transactions thực) thì chưa — và cũng chưa có gì để report
cho tới khi core loop tạo ra data.

## Current State (verified)
- 🟡 Admin dashboard: count widgets (Brands 2, Candidates 9, Adverts 1) + financial widgets
  (Income/Expenditure/Brand Charges/Candidate Charges/Profit) tất cả đều £0. (evidence: `01-dashboard.png`)
- 🔴 Không có date filters, không drill-down, không report per-brand/per-candidate, không exports, không fill-rate/time-to-fill,
  không compliance reporting, không analytics hướng tới brand hay candidate.

## Production-Grade Target
- **Agency ops**: fill rate, time-to-fill, active candidates, compliance funnel, no-show rate, utilisation.
- **Financial**: revenue (cả hai charges), margin, invoices outstanding/overdue, payouts, theo period/brand/market.
- **Brand-facing**: spend của họ, bookings, upcoming shifts (trong P2).
- **Candidate-facing**: earnings tới hiện tại, shifts đã làm (trong P3).
- Date-range filters, drill-down, CSV/PDF export, scheduled report emails.
- Scoping per-tenant (P12).

## Feature Gap Matrix
| # | Feature | Current | Target | Gap |
|---|---------|---------|--------|-----|
| 13.1 | Admin count widgets | 🟡 | ✅ | Wire vào live data |
| 13.2 | Financial widgets | 🟡 £0 | Real revenue/margin | Phụ thuộc data P8 |
| 13.3 | Date filters / drill-down | 🔴 | Period + entity filters | Reporting queries |
| 13.4 | Ops KPIs (fill rate, TTF) | 🔴 | Recruitment metrics | Định nghĩa metric + queries |
| 13.5 | Compliance reporting | 🔴 | Funnel + expiry view | Phụ thuộc P6 |
| 13.6 | Brand analytics | 🔴 | Spend/bookings | Trong P2 |
| 13.7 | Candidate earnings | 🔴 | Earnings/shifts | Trong P3 |
| 13.8 | Exports / scheduled | 🔴 | CSV/PDF + email | Export + scheduler |

## Build Scope (the gap)
- Reporting queries/aggregations một khi P5/P8 tạo ra data thực; wire các widget hiện có vào số liệu live.
- Reports có filter, drill được + exports; ops + financial KPIs; scoping per-tenant.

## Risk Assessment
- Độ ưu tiên thấp / làm sau cùng — phụ thuộc data thực từ P5/P8. Đừng build trước khi loop tạo ra transactions.
- Dashboard hiện có là khung tốt để mở rộng, không cần thay thế.
