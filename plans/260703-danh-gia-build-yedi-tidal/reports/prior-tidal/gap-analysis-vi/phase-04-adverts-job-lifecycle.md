---
phase: 4
title: "Adverts-Job-Lifecycle"
status: pending
priority: P2
effort: "40d (MVP 26d)"
dependencies: []
---

# Phase 4: Adverts & Job Lifecycle

## Overview
Advert là entity hoàn chỉnh nhất trong hệ thống. **Data model mạnh**;
phần **lifecycle automation, publishing, và discovery** quanh nó thì yếu/thủ công.

## Current State (verified)
- ✅ Advert model & form rich: title, brand, type (day-to-day/long-term), full address,
  start/end dates, shift start/end time, apply-by, rich-text description, **Documents repeater**,
  Payment & Charges (Brand Pay Rate £, rate type Daily, Brand Charge %, Candidate Charge %).
  (evidence: `02-advert-detail.png`, `adverts/create`)
- ✅ Status enum: Approved / Filled / Not filled / Pending allocation / Pending approval / Rejected.
- 🟡 Đổi status là một **"Update status" select thủ công** (một listbox), không có workflow/guards. (evidence: status modal)
- 🟡 List có status-filter tabs + bulk actions + column toggles (Filament chuẩn).
- 🔴 Không có public/published advert view, no candidate-facing search, no geocoding, no slots/headcount (1 advert = 1 role? chưa rõ), no auto-expiry theo apply-by.

## Production-Grade Target
- Advert lifecycle dưới dạng **state machine** với các transition cho phép + side-effects
  (approve → publish → allocate → fill → complete/close), không phải free select.
- **Multi-slot adverts** (vd "cần 5 ambassadors") với allocation theo từng slot.
- Brand self-posting → admin approval gate (P2) trước khi publish.
- **Published/public advert page** (SEO-friendly) + candidate search/filter (role, type, location, date, pay).
- Geocoding address → distance search.
- Auto-transitions: close khi tới apply-by, mark not-filled, reminders.
- Advert templates / duplication; draft state.

## Feature Gap Matrix
| # | Feature | Current | Target | Gap |
|---|---------|---------|--------|-----|
| 4.1 | Advert data model | ✅ | ✅ (+ slots/headcount) | Add headcount/slots |
| 4.2 | Status enum | ✅ | ✅ | — |
| 4.3 | Lifecycle state machine | 🟡 manual select | Guarded transitions + side-effects | State-machine logic |
| 4.4 | Approval workflow | 🟡 chỉ status | Brand submit → admin approve | Approval flow + notifications |
| 4.5 | Multi-slot allocation | 🔴 | N candidates mỗi advert | Slot model + allocation |
| 4.6 | Public advert page | 🔴 | Published, shareable, SEO | Public controller + view |
| 4.7 | Candidate search/filter | 🔴 | Role/type/location/date/pay | Search index + filters |
| 4.8 | Geo / distance | 🔴 | Geocode + radius search | Geocoding integration |
| 4.9 | Auto-expiry/reminders | 🔴 | Close khi tới apply-by, nudge | Scheduled jobs |
| 4.10 | Draft / duplicate / template | 🔴 | Reuse adverts nhanh | Draft state + clone |

## Build Scope (the gap)
- Chính thức hóa advert lifecycle thành state machine với transition guards + events.
- Thêm headcount/slots để hỗ trợ multi-hire adverts (ảnh hưởng P5 matching, P8 billing theo từng slot).
- Public advert pages + candidate search (geocoding) cho candidate portal (P3).
- Scheduled jobs cho expiry/reminders.

## Risk Assessment
- "1 advert = 1 booking" vs "1 advert = N slots" là **quyết định định hình model** lan tỏa vào
  matching, timesheets, và billing. Giải quyết sớm; data hiện chỉ có 1 advert nên intent chưa được kiểm chứng.
