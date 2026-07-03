---
phase: 10
title: "Notifications-Comms"
status: pending
priority: P2
effort: "30d (MVP 18d)"
dependencies: [5]
---

# Phase 10: Notifications & Communications

## Overview
A two-sided marketplace runs on timely nudges (offers, approvals, compliance reminders,
shift reminders, invoice/payslip ready). **No notification system is visible.**

## Current State (verified)
- 🟡 System holds an invoice contact email/phone → transactional email *may* be partially wired for invoices, but nothing observable (no invoices generated).
- 🔴 No notification centre, no email/SMS templates surfaced, no preferences, no in-app notifications.

## Production-Grade Target
- **Transactional email** (Laravel mailables) for every key event: account verify/reset, application
  received, offer made, booking confirmed, compliance item required/expiring, timesheet to approve,
  invoice issued/overdue, payslip ready.
- **SMS** for time-critical events (shift offer/reminder) — candidates on phones.
- **In-app notification centre** for brand + candidate portals.
- Per-user preferences + unsubscribe; templated, branded per tenant (P12).
- Reminder scheduler (cron/queue) for compliance expiry, apply-by, unconfirmed shifts.
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

## Build Scope (the gap)
- Notification layer over Laravel notifications (mail + SMS + database channels).
- Event hooks across P1/P5/P6/P7/P8 to fire the right messages.
- In-app notification UI in both portals; preferences; scheduled reminders.

## Risk Assessment
- Cuts across nearly every other phase; cheapest if a notification seam is added as those phases are built,
  not retrofitted after.
- Email deliverability (SPF/DKIM/domain) is operational setup, easy to forget.
