# Tidal / Yedi — Ước tính effort (map từ feature-gap analysis)

> Bottom-up estimate suy ra từ `plans/260629-feature-gap-analysis/` (14 feature domains, ~110 features).
> Mỗi phase được cost từ gap matrix của nó, không phải áng chừng top-down.
> Ngày: 2026-06-29 · Đơn giá blended giả định: **$240–300/man-day** (chờ rate card Sotatek).

## TL;DR (tiếng Việt)

- Ước tính **bottom-up theo từng feature** (không phải áng chừng). Tổng **production-grade đầy đủ** (cả 14 domain) ≈ **~870 man-days**.
- Bản **MVP để Tidal go-live** (cắt phần tự động hoá thanh toán, e-sign, reporting sâu, Yedi đầy đủ) ≈ **~660 man-days**.
- **Con số này CAO HƠN ~2× báo giá thô trước ($80–99k)** — vì báo giá thô đã *thiếu*: lõi giao dịch (P5), engine compliance (P6), engine billing (P8), và gần như bỏ qua toàn bộ non-functional production (P14: security/GDPR/test/CI-CD) + multi-tenancy (P12). Đây chính là điều anh đã chỉ ra. Bản bottom-up này mới là con số đáng tin.

## Method & assumptions

- **Unit:** man-day (md) của một engineer Laravel/Filament + frontend có năng lực.
- **Costing rule:** feature 🟡 partial size theo *finish-the-gap*; 🔴 missing theo *full build*; ✅ loại trừ.
- **Cross-phase overlap** (vd timesheet UI trong portal vs engine trong P7) hấp thụ vào contingency, không đếm trùng vào totals.
- **Excludes** chi phí run/hosting thường xuyên, phí license 3rd-party (Twilio/GoCardless/DocuSign/Yoti), và support sau launch.
- **Rate** là placeholder — confirm rate card presale Sotatek trước khi báo giá client.

## Per-phase effort

| Phase | Domain | Total md | MVP-launch md | Notes / what MVP defers |
|-------|--------|---------:|--------------:|--------------------------|
| 1 | Identity, Auth & Access | 35 | 26 | Defer 2FA, impersonation, full brand multi-user |
| 2 | Brand Portal | 60 | 44 | Defer messaging, multi-seat, calendar polish |
| 3 | Candidate Portal | 70 | 54 | Defer availability calendar, UX polish |
| 4 | Adverts & Job Lifecycle | 40 | 26 | Defer geo-search, multi-slot (nếu single-hire OK), templates |
| 5 | **Applications-Matching-Booking (core)** | 58 | 58 | None — xương sống non-negotiable |
| 6 | **Compliance & Right-to-Work** | 52 | 52 | None — legal gate |
| 7 | Timesheets & Attendance | 35 | 35 | None — billing basis |
| 8 | Billing — Invoices & Payslips | 55 | 44 | Defer accounting export, credit notes, statements |
| 9 | Payments & Settlement | 32 | 8 | MVP = chỉ offline tracked; automate sau |
| 10 | Notifications & Comms | 30 | 18 | MVP = transactional email + key SMS; defer in-app centre/preferences |
| 11 | Documents, Contracts & E-sign | 27 | 15 | MVP = contract gen + storage; defer e-sign provider |
| 12 | Multi-Tenancy & White-Label | 39 | 25 | MVP = tenant-ready foundation + Tidal; full Yedi enablement sau |
| 13 | Reporting & Analytics | 26 | 8 | MVP = wire dashboard + basic ops KPIs |
| 14 | **Non-Functional (security/GDPR/QA/CI-CD)** | 66 | 48 | MVP = security + core tests + CI/CD + GDPR basics; defer adv. perf |
| | **Dev subtotal** | **625** | **461** | |

## Cross-cutting overlays (cộng thêm bên trên)

| Item | md (cả hai scope) |
|------|-----------------:|
| Discovery + source-code audit | 10 |
| UI/UX design + design system (2 portals) | 25 |
| Foundation (API layer, project/env scaffolding, CI baseline) | 15 |
| **Fixed overlay subtotal** | **50** |

## Roll-up

| | Dev | +Overlay | +PM (~12%) | +Contingency (~15%) | **Total** |
|---|---:|---:|---:|---:|---:|
| **MVP launch (Tidal)** | 461 | 511 | ~572 | ~658 | **~660 md** |
| **Full production-grade (all 14)** | 625 | 675 | ~756 | ~870 | **~870 md** |

> Contingency đặt ở **15%** (cao hơn mức thường 12%) vì **source code vẫn chưa được xem** — một số 🔴 có thể co lại thành 🟡 (tiết kiệm), nhưng các module rỗng cũng có thể giấu backend thiếu (tốn thêm). Audit (WS0) thu hẹp dải này.

## Timeline & team

**Team ~6:** 1 Tech Lead/BE, 2 Laravel/Filament BE, 2 FE, 1 QA + part-time PM & UI/UX.
Giả định ~5 productive md mỗi working-day sau khi trừ coordination overhead.

| Scope | Effort | Throughput | Realistic timeline |
|-------|-------:|-----------|--------------------|
| **MVP launch** | ~660 md | ~5 md/day | **~6.5–7.5 months** |
| **Full production-grade** | ~870 md | ~5 md/day | **~8.5–10 months** |

## Cost (blended $240–300/md)

| Scope | Low ($240) | High ($300) |
|-------|-----------:|------------:|
| **MVP launch (Tidal)** | **~$158k** | **~$198k** |
| **Full production-grade** | **~$209k** | **~$261k** |
| Enhancement tranche (Full − MVP) | ~$50k | ~$63k |

(MVP ≈ £125k–£156k; Full ≈ £165k–£206k ở mức ~0.79.)

## Recommended delivery shape

1. **Tranche 1 — MVP launch (Tidal):** ~660 md, ~$160k–$200k, ~7 tháng.
   Two-sided platform thực sự transact được: auth + cả hai portal + core loop (P5) + compliance (P6) +
   timesheets (P7) + billing generation (P8) + tenant-ready foundation (P12) + security/QA baseline (P14).
   Payments offline-tracked, comms email-first.
2. **Tranche 2 — Automation + Yedi + polish:** ~+210 md, ~$50k–$63k, ~+3 tháng.
   Payment automation (P9), e-sign (P11), in-app notifications (P10), accounting export + credit notes (P8),
   geo/multi-slot (P4), reporting depth (P13), full Yedi tenant enablement (P12), advanced security/perf (P14).

## Reconciliation với báo giá thô trước đó

| | Earlier coarse | This bottom-up (MVP) |
|---|---|---|
| Method | top-down, ~9 workstreams | per-feature across 14 domains |
| Effort | ~330 md | ~660 md |
| Cost | $80k–$99k | $158k–$198k |
| Why different | under-scoped P5/P6/P8; **bỏ sót P14** (security/GDPR/test/CI-CD) và coi P12 là tầm thường | mọi feature đều được đếm kèm gap của nó |

Con số trước đó **lạc quan và under-scoped** — lộ ra chính xác khi làm pass feature-level mà anh yêu cầu.

## Confidence & cái gì làm nó dịch chuyển

- **Dải ±15%** cho tới khi source audit (WS0). Audit + Yedi access thắt lại thành fixed-price chắc chắn.
- **Black-box behavioral test đã xong** (`tidal-blackbox-test-findings.md`) — dải **vẫn giữ**: một số
  item co lại (Application CRUD+aggregation works; evidence capture là thật), một số phình ra (no admin RBAC;
  Declarations create là production bug; Booking entity vẫn greenfield). Net ~trung tính.
- **Resolved (domain recon):** không có live brand/candidate front-end nào tồn tại — `tidalagency.co.uk` chỉ là
  marketing, `app.tidalagency.co.uk` là một empty nginx 403 placeholder, Filament admin là app chạy duy nhất.
  Candidate evidence data nhiều khả năng là dev seed (`@ne6.studio`). → **P2/P3 portals confirmed greenfield**
  (bỏ reducer lạc quan "có thể co P3/P6"; estimate đứng nguyên, không giảm).
- Các swing factor còn lại: **(a)** liệu Invoice/Payslip/Booking có hidden backend services chưa wire vào
  UI không (có thể cắt P5/P8); **(b)** candidate employment model PAYE/umbrella/self-employed (chi phối thuế P8/P9);
  **(c)** single-hire vs multi-slot adverts (schema P4/P5); **(d)** Yedi code-divergence (P12);
  **(e)** liệu có một **mobile app** chưa release không (marketing có claim; chưa tìm thấy live).

## Open questions

1. Confirm **rate card** blended của Sotatek để thay placeholder $240–300.
2. **Source code + Yedi access** để thu hẹp dải ±15% và confirm giả định P5/P12.
3. Confirm **MVP scope** có phải đúng launch line không, hoặc điều chỉnh deferral nào chuyển vào Tranche 1.
