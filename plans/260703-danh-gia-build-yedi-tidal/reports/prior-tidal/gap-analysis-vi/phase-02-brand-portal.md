---
phase: 2
title: "Brand-Portal"
status: pending
priority: P1
effort: "60d (MVP 44d)"
dependencies: [1]
---

# Phase 2: Brand-Facing Portal (self-service)

## Overview
Toàn bộ web surface phía brand. **Chưa tồn tại** — hiện brands được quản lý bởi admin
staff bên trong Filament. Brand account có trong data nhưng không thể login hay tự làm gì.

## Current State (verified)
- 🟡 Brand entity tồn tại phía admin: name, email, phone, status, compliance, bio, additional info,
  contact-with-login. (evidence: `advertisers/create`, `06-brands-list.png`)
- 🔴 Không có app phía brand dưới bất kỳ dạng nào: no dashboard, no advert posting, no application review, no invoices view.

## Production-Grade Target
Self-service portal nơi brand tự chạy việc tuyển dụng mà không cần gọi điện cho agency:
- Onboarding: company profile, billing/legal details, upload compliance docs, accept terms.
- **Post & manage adverts** (dùng lại form advert rich sẵn có, brand-scoped): create, edit, duplicate, close.
- Xem **applications** đến; shortlist / accept / decline candidates; xem candidate profile (compliance-masked).
- **Bookings** view: ai được book cho shift nào, calendar.
- Approve/confirm **timesheets** do candidate submit.
- **Invoices**: list, download PDF, payment status.
- Messaging/notifications với agency + candidates.
- Multi-user (owner mời đồng nghiệp) — xem P1.

## Feature Gap Matrix
| # | Feature | Current | Target | Gap |
|---|---------|---------|--------|-----|
| 2.1 | Brand dashboard | 🔴 | KPIs: open adverts, applicants, upcoming shifts, outstanding invoices | New SPA/Blade surface |
| 2.2 | Company onboarding/profile | 🟡 admin-only | Self-edit profile + billing/legal | Brand-scoped forms |
| 2.3 | Post advert | 🟡 admin-only | Brand tự post (scoped) | Reuse model, new UI + scoping + approval gate |
| 2.4 | Manage adverts | 🔴 | Edit/close/duplicate adverts của mình | CRUD scoped theo brand |
| 2.5 | Review applications | 🔴 | Shortlist/accept/decline | Phụ thuộc P5 |
| 2.6 | Candidate profile view | 🔴 | Compliance-aware masked view | Field-level visibility rules |
| 2.7 | Bookings/calendar | 🔴 | Confirmed shifts view | Phụ thuộc P5/P7 |
| 2.8 | Timesheet approval | 🔴 | Approve/dispute hours | Phụ thuộc P7 |
| 2.9 | Invoices view/pay | 🔴 | List + PDF + pay/status | Phụ thuộc P8/P9 |
| 2.10 | Messaging/notifications | 🔴 | In-app + email | Phụ thuộc P10 |
| 2.11 | Multi-user seats | 🔴 | Mời đồng nghiệp, roles | Phụ thuộc P1.10 |

## Build Scope (the gap)
- App web brand mới (Blade+Livewire, hoặc Filament panel, hoặc decoupled SPA + API).
- Brand-scoped data access (mọi query filter theo brand_id) + authorization policies.
- Reuse Advert model/validation sẵn có; build posting phía brand + approval handshake với admin.
- Bind vào P5 (applications), P7 (timesheets), P8/P9 (invoices/pay), P10 (comms).

## Risk Assessment
- Surface lớn nhất. Coupling chặt với P5/P7/P8 — không thể "done" trước khi những phần đó tồn tại; build incrementally.
- Cần quyết định: mở rộng thành Filament panel thứ hai vs custom front-end. Ảnh hưởng design-system & DX (xem P12/P3).
