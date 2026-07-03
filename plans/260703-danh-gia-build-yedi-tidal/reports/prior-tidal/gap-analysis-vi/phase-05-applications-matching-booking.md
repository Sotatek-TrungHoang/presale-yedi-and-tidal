---
phase: 5
title: "Applications-Matching-Booking"
status: pending
priority: P1
effort: "58d"
dependencies: [4, 6]
---

# Phase 5: Applications, Matching & Booking (VÒNG LẶP CỐT LÕI)

## Overview
**Trái tim của marketplace** — candidate apply → agency/brand matching → booking được
xác nhận → ca làm diễn ra. Hôm nay đây **mới chỉ là khung rỗng (empty scaffolding)** và là gap lớn nhất:
không có nó thì không có thu nhập, không invoice, không payslip.

## Current State (đã verify — gồm cả black-box behavioral test)
- ✅ **Application CRUD + aggregation HOẠT ĐỘNG** *(black-box: tạo một application Accepted, quan sát hiệu ứng, rồi xóa)*:
  đặt status=Accepted đã cập nhật **advert.accepted_application** (= candidate) và tăng
  **số Accepted của candidate**. Vậy entity + các relationship + logic aggregation là thật, không phải khung trơ.
  (evidence: `evidences/blackbox/t1-application-create.png`, `t1-advert-1.png`, `t1-candidates-list.png`)
- 🔴 **Không có entity Booking/Allocation** — relationship chỉ là application↔advert↔candidate; không có object confirmed-assignment riêng.
- 🔴 **Không có state side-effects** — advert status **không** tự chuyển sang "Filled" khi một application được Accepted.
- 🔴 **Không có downstream trigger** — không có action "Allocate / Confirm booking / Generate invoice/payslip" ở đâu cả; Invoices/Payslips vẫn rỗng. (evidence: `t1-invoices-after.png`, `t1-payslips-after.png`)
- 🔴 Không có matching/eligibility, không có offer/accept handshake, không có availability, không có clash detection.

## Production-Grade Target
- **Application**: candidate→advert với status lifecycle (applied → shortlisted → offered →
  accepted/declined → withdrawn → rejected), timestamps, audit.
- **Matching**: lọc candidates đủ điều kiện (compliant, đúng role/type, available, trong phạm vi);
  ranking/suggestions tùy chọn; bulk invite.
- **Offer/accept handshake** giữa brand/agency và candidate (có expiry).
- **Booking/Assignment** entity = candidate↔advert(/slot)↔date(s) đã xác nhận: object mà timesheets,
  invoices, payslips đều bám vào.
- **Availability & clash detection** (không double-book một candidate trên các ca trùng giờ).
- Xử lý cancellation/no-show với policy (ảnh hưởng charges).
- Allocation theo headcount/slots của advert (P4).

## Feature Gap Matrix
| # | Feature | Current | Target | Gap |
|---|---------|---------|--------|-----|
| 5.1 | Application entity | 🟡 CRUD+aggregation works | Full status lifecycle + audit | Mở rộng status lifecycle, events (base đã có) |
| 5.2 | Candidate apply | 🔴 | Từ candidate portal | Phụ thuộc P3 |
| 5.3 | Matching/eligibility | 🔴 | Filter compliance+role+availability | Eligibility engine |
| 5.4 | Suggestions/ranking | 🔴 | Gợi ý candidate phù hợp nhất | Scoring (tùy chọn) |
| 5.5 | Offer/accept handshake | 🔴 | Two-sided confirm + expiry | Offer model + flow |
| 5.6 | Booking/Assignment entity | 🔴 | Object assignment đã xác nhận | **Core entity mới** |
| 5.7 | Multi-slot allocation | 🔴 | Fill N của N | Phụ thuộc P4.5 |
| 5.8 | Availability model | 🔴 | Candidate availability | Model mới |
| 5.9 | Clash detection | 🔴 | Ngăn double-booking | Overlap checks |
| 5.10 | Cancellation/no-show | 🔴 | Policy + tác động charge | Rules + hooks tới P8 |

## Build Scope (gap)
- Implement Application status lifecycle + events (chủ yếu là logic greenfield trên scaffold).
- **Giới thiệu Booking/Assignment entity** — keystone còn thiếu mà P7/P8/P9 phụ thuộc.
- Eligibility/matching engine (tiêu thụ compliance P6 + availability).
- Offer/accept handshake xuyên các surface admin/brand/candidate (P2/P3).
- Availability + clash detection.

## Risk Assessment
- **Gap rủi ro cao nhất.** Mọi thứ downstream (timesheets, invoices, payslips, payments, dashboards)
  đều vô nghĩa cho tới khi cái này tồn tại và đúng.
- Booking entity có thể có hoặc chưa có trong code (không thấy trong admin nav) — **confirm qua source**;
  nếu chưa có thì đây là model mới nền tảng đụng tới toàn bộ schema.
- Độ chính xác về tiền (charges, cancellations) nằm ở đây — phải kín kẽ + tested (P14).
