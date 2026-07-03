---
phase: 10
title: "Notifications-Comms"
status: pending
priority: P2
effort: "30d (MVP 18d)"
dependencies: [5]
---

# Phase 10: Notifications & Communications

## Tổng quan
Một two-sided marketplace vận hành dựa trên các nudge kịp thời (offers, approvals, compliance reminders,
shift reminders, invoice/payslip ready). **Không thấy notification system nào.**

## Hiện trạng (verified)
- 🟡 System giữ invoice contact email/phone → transactional email *có thể* được wired một phần cho invoices, nhưng không quan sát được gì (chưa có invoices nào được tạo).
- 🔴 Không có notification centre, không email/SMS templates được surface, không preferences, không in-app notifications.

## Mục tiêu Production-Grade
- **Transactional email** (Laravel mailables) cho mọi key event: account verify/reset, application
  received, offer made, booking confirmed, compliance item required/expiring, timesheet to approve,
  invoice issued/overdue, payslip ready.
- **SMS** cho các event time-critical (shift offer/reminder) — candidates dùng điện thoại.
- **In-app notification centre** cho cả brand + candidate portals.
- Per-user preferences + unsubscribe; templated, branded theo từng tenant (P12).
- Reminder scheduler (cron/queue) cho compliance expiry, apply-by, unconfirmed shifts.
- Delivery logging + retry.

## Feature Gap Matrix
| # | Feature | Current | Target | Gap |
|---|---------|---------|--------|-----|
| 10.1 | Transactional email | 🔴/🟡 unknown | Full event coverage | Mailables + triggers |
| 10.2 | SMS | 🔴 | Time-critical alerts | SMS provider (Twilio) |
| 10.3 | In-app notifications | 🔴 | Notification centre | DB notifications + UI |
| 10.4 | Templates + branding | 🔴 | Per-tenant branded | Template system (P12) |
| 10.5 | Preferences / unsubscribe | 🔴 | Per-channel opt-in | Preferences model |
| 10.6 | Reminder scheduler | 🔴 | Cron-driven nudges | Scheduled jobs |
| 10.7 | Delivery log / retry | 🔴 | Observability | Logging + retry |

## Build Scope (phần gap)
- Notification layer dựa trên Laravel notifications (mail + SMS + database channels).
- Event hooks xuyên suốt P1/P5/P6/P7/P8 để fire đúng message.
- In-app notification UI ở cả hai portals; preferences; scheduled reminders.

## Risk Assessment
- Cắt ngang gần như mọi phase khác; rẻ nhất nếu một notification seam được thêm vào khi các phase đó được build,
  thay vì retrofit sau.
- Email deliverability (SPF/DKIM/domain) là operational setup, dễ bị quên.
