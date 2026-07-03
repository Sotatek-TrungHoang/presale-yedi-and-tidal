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
Cầu nối giữa "ca làm đã diễn ra" và "tiền phải trả". **Hoàn toàn còn thiếu.** Không có giờ làm
được capture/approve thì không có cơ sở vững để xuất invoices hay payslips.

## Current State (đã verify)
- 🟡 Advert mang shift start/end time + date range → expected hours có thể suy ra được.
- 🟡 System charge model là rate **Daily** trong sample data (Brand Pay Rate £150/Daily) — nên pay có thể
  theo ngày, nhưng hourly nhiều khả năng cần cho ca retail. Chưa confirm model hỗ trợ loại nào.
- 🔴 Không có timesheet entity, không clock-in/out, không attendance, không approval flow, không xử lý variance.

## Production-Grade Target
- **Timesheet theo booking/shift**: planned vs actual start/end, breaks, tổng hours/days.
- Candidate submission (clock-in/out hoặc manual entry) từ candidate portal (P3).
- **Approval** brand/agency + flow dispute/adjust (P2).
- Xử lý no-show / late / cancelled → feed vào charge rules (P5/P8).
- Hỗ trợ cả pay basis **daily và hourly**; overtime/premium rates nếu cần.
- Lock approved timesheets làm input bất biến cho billing (P8).

## Feature Gap Matrix
| # | Feature | Current | Target | Gap |
|---|---------|---------|--------|-----|
| 7.1 | Timesheet entity | 🔴 | Theo booking/shift | Model mới |
| 7.2 | Candidate submit hours | 🔴 | Clock hoặc manual entry | Phụ thuộc P3 |
| 7.3 | Clock-in/out | 🔴 | Optional geo/time stamp | Capture mechanism |
| 7.4 | Brand approval | 🔴 | Approve/dispute/adjust | Phụ thuộc P2 |
| 7.5 | Daily vs hourly basis | 🟡 sample daily | Hỗ trợ cả hai | Confirm + extend model |
| 7.6 | Breaks / overtime | 🔴 | Trừ breaks, premium rates | Calc rules |
| 7.7 | No-show / cancellation | 🔴 | Status + tác động charge | Rules → P8 |
| 7.8 | Approved-lock | 🔴 | Billing input bất biến | Lock + versioning |

## Build Scope (gap)
- Timesheet model mới bind tới Booking entity từ P5.
- Submission UI (candidate) + approval UI (brand/admin).
- Engine tính hours/days (breaks, overtime, no-show) tạo ra billing basis cho P8.

## Risk Assessment
- Pay basis (daily vs hourly, breaks, overtime) phải khớp commercial terms thực tế của client —
  giả định sai ở đây làm hỏng mọi invoice/payslip downstream.
- Phụ thuộc hoàn toàn vào việc P5 Booking entity tồn tại trước.
