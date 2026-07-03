---
title: "Tidal-Yedi Feature Gap Analysis: Current vs Production-Grade"
description: "Feature-by-feature inventory of the existing Laravel+Filament staffing admin vs a production-grade two-sided staffing marketplace. Documents current state, target, and concrete gap per domain. No cost estimation."
status: pending
priority: P1
branch: "main"
tags: [gap-analysis, presale, staffing-marketplace, filament]
blockedBy: []
blocks: []
created: "2026-06-29T03:31:12.698Z"
createdBy: "ck:plan"
source: skill
---

# Tidal-Yedi Feature Gap Analysis: Current vs Production-Grade

## Tổng quan

Phân tích gap theo từng feature của nền tảng staffing agency **Tidal/Yedi** do client tự
xây. Mục tiêu: thay thế kiểu nói chung chung "build phần còn lại" bằng một bản kiểm kê cụ thể —
**cái gì đang có hôm nay (verified live), production-grade đòi hỏi gì, và gap chính xác là gì.**

- **System under analysis:** Laravel + **Filament** admin panel, `admin.tidalagency.co.uk`.
- **Business model:** two-sided recruitment marketplace (Brands ↔ Candidates), agency ăn
  commission cả hai phía (Brand Charge %, Candidate Charge %).
- **Evidence base:** `tidal-teardown-live-findings.md`, `tidal-agency-analysis.md`,
  `evidences/*.png` (11 screenshots), deep live crawl mọi resource create/edit
  form và trang System settings, **cộng với 4-agent black-box behavioral test**
  (`tidal-blackbox-test-findings.md`, `evidences/blackbox/*.png`, 47 screenshots) — tất cả 2026-06-29.
- **Black-box corrections applied** (behavioral, không chỉ UI): Application CRUD + aggregation
  logic *works* (không phải bare scaffold); invoice/payslip generation *confirmed absent* (không có trigger ở đâu cả);
  candidate evidence capture (ID/video/contract) *là thật* → một candidate onboarding flow nhiều khả năng đang tồn tại;
  Declarations create *broken* (server upload bug); **admin KHÔNG có RBAC** ("role selector" trước đây là
  đọc nhầm field Title — đã sửa).
- **Scope note:** tài liệu này là **bản đồ feature/gap thuần** — không có con số man-day hay cost
  (theo yêu cầu). Đây là input cho một pass estimation/roadmap sau.

## Cách đọc tài liệu này

Mỗi phase = một **feature domain**. Bên trong mỗi phase:
- **Current State (verified)** — cái gì thực sự works trong live app, kèm evidence refs.
- **Production-Grade Target** — một staffing platform thật, bán được phải làm gì.
- **Feature Gap Matrix** — line-by-line `Feature | Current | Target | Gap`.
- **Build Scope (the gap)** — phần việc cụ thể mà gap hàm ý.

**Maturity legend (per feature):**
- ✅ **Done** — đã có & dùng được as-is.
- 🟡 **Partial** — scaffold/data-model có nhưng logic, UI, hoặc flow chưa hoàn chỉnh.
- 🔴 **Missing** — chưa có; greenfield build.

## Headline finding

Nền tảng có một **xương sống data-model + admin-CRUD vững** nhưng **cơ bắp giao dịch
và mọi self-service surface đều vắng mặt**:

- ✅ **Spine exists:** Advert model phong phú (pricing/charges/shifts/address), Candidate model
  sâu (4-tab profile, references, **real ID/video/contract evidence**, compliance status),
  Brand model, **và một System settings được cấu hình đầy đủ** (charge %, references-required,
  invoice bank/terms, applicant + advertiser **contract templates**). Brand & Candidate records
  mang theo **login user accounts**. Application CRUD + aggregation (advert.accepted_application,
  candidate counts) **works** — verified by black-box.
- 🔴 **Core transaction loop dừng sau Application:** Application persist + cập nhật relations,
  nhưng **không có Booking entity**, advert status **không** auto-transition, và **không có
  invoice/payslip generation trigger ở bất cứ đâu** (verified — không chỉ là list rỗng).
- 🔴 **Không có live brand/candidate front-end nào tồn tại** *(domain recon verified)*: `tidalagency.co.uk` là
  marketing site (không login/register); `app.tidalagency.co.uk` là một bare nginx 403 placeholder (chưa deploy
  app nào); `admin.tidalagency.co.uk` (Laravel/Filament) là app thật duy nhất. Candidate evidence
  (video/ID/contract) thấy trong admin **nhiều khả năng là dev/test seed data** — candidates + login đều là
  `@ne6.studio` (build agency). Vậy P2/P3 portals được xác nhận là **greenfield**, không phải xây dở.
- 🔴 **Không có admin RBAC** (corrected): user form không có field role/permission; identity nhiều khả năng
  polymorphic (các bảng applicant/advertiser/admin tách riêng).
- 🔴 **Không có self-service:** không có Brand portal, không có Candidate portal — accounts tồn tại nhưng không
  có chỗ nào cho họ log in. Mọi thứ đều admin-operated.
- 🔴 **Compliance chưa cấu hình:** bảng Required Evidence + Declarations rỗng; Job Roles =
  chỉ "Any Role". Compliance *engine* (rules, enforcement, right-to-work) chưa được build.
- 🔴 **Không có multi-tenancy:** single Tidal deployment; Yedi không verify được; không có white-label layer.

## Phases (feature domains)

| Phase | Domain | Current maturity | Headline gap | Priority |
|-------|--------|------------------|--------------|----------|
| 1 | [Identity-Auth-Access](./phase-01-identity-auth-access.md) | 🟡 Admin auth + accounts có | Không portal auth, không reset/verify/2FA, RBAC một phần | P1 |
| 2 | [Brand-Portal](./phase-02-brand-portal.md) | 🔴 None | Toàn bộ brand self-service surface | P1 |
| 3 | [Candidate-Portal](./phase-03-candidate-portal.md) | 🔴 None | Toàn bộ candidate self-service surface | P1 |
| 4 | [Adverts-Job-Lifecycle](./phase-04-adverts-job-lifecycle.md) | 🟡 Model phong phú, status thủ công | Approval flow, publish, search, geo | P2 |
| 5 | [Applications-Matching-Booking](./phase-05-applications-matching-booking.md) | 🔴 Empty scaffold | Core marketplace loop | P1 |
| 6 | [Compliance-RightToWork](./phase-06-compliance-righttowork.md) | 🟡 Chỉ status fields | Rules engine, evidence enforcement, RTW | P1 |
| 7 | [Timesheets-Attendance](./phase-07-timesheets-attendance.md) | 🔴 None | Shift confirmation → hours → pay basis | P1 |
| 8 | [Billing-Invoices-Payslips](./phase-08-billing-invoices-payslips.md) | 🟡 Chỉ config, 0 docs | Generation engine + PDF + lifecycle | P1 |
| 9 | [Payments-Settlement](./phase-09-payments-settlement.md) | 🔴 None | Collection + payout + reconciliation | P2 |
| 10 | [Notifications-Comms](./phase-10-notifications-comms.md) | 🔴 Không thấy | Transactional email/SMS/in-app | P2 |
| 11 | [Documents-Contracts-Esign](./phase-11-documents-contracts-esign.md) | 🟡 Templates có | Generation + e-signature + storage | P2 |
| 12 | [MultiTenancy-WhiteLabel](./phase-12-multitenancy-whitelabel.md) | 🔴 Single deploy | Tenant isolation + branding/config | P2 |
| 13 | [Reporting-Analytics](./phase-13-reporting-analytics.md) | 🟡 Dashboard cơ bản | Operational + financial reporting | P3 |
| 14 | [NonFunctional-Security-QA](./phase-14-nonfunctional-security-qa.md) | 🔴 Unknown/none | Security, GDPR, tests, CI/CD, perf | P1 |

## Dependencies

Build-order coupling (không phải cross-plan):
- P5 (Matching/Booking) là xương sống; P7 (Timesheets) → P8 (Billing) → P9 (Payments) nối tiếp từ đó.
- P1 (Auth) gate P2/P3 (portals).
- P6 (Compliance) gate P5 (chỉ compliant candidates mới được booked).
- P12 (Multi-tenancy) là cross-cutting — rẻ nhất nếu quyết trước khi làm UI P2/P3.

## Open questions (blocking precise scoping)

1. **Source code access** — mức độ hoàn chỉnh của *backend* các module rỗng (controllers/services)
   không rõ nếu không có repo. Một số 🔴 có thể là 🟡.
2. **Yedi** — URL/login chưa được cung cấp; giả định multi-tenant vs separate-deploy chưa verify.
3. **Scope of "full app"** đã confirm trước đó: Brand + Candidate **web** portals (không native mobile),
   giữ & mở rộng Laravel/Filament, single multi-tenant, semi-automated payments.
