# Tidal / Yedi — Effort Estimate (mapped from feature-gap analysis)

> Bottom-up estimate derived from `plans/260629-feature-gap-analysis/` (14 feature domains, ~110 features).
> Each phase costed from its gap matrix, not a top-down guess.
> Ngày: 2026-06-29 · Đơn giá blended giả định: **$240–300/man-day** (chờ rate card Sotatek).

## TL;DR (tiếng Việt)

- Ước tính **bottom-up theo từng feature** (không phải áng chừng). Tổng **production-grade đầy đủ** (cả 14 domain) ≈ **~870 man-days**.
- Bản **MVP để Tidal go-live** (cắt phần tự động hoá thanh toán, e-sign, reporting sâu, Yedi đầy đủ) ≈ **~660 man-days**.
- **Con số này CAO HƠN ~2× báo giá thô trước ($80–99k)** — vì báo giá thô đã *thiếu*: lõi giao dịch (P5), engine compliance (P6), engine billing (P8), và gần như bỏ qua toàn bộ non-functional production (P14: security/GDPR/test/CI-CD) + multi-tenancy (P12). Đây chính là điều anh đã chỉ ra. Bản bottom-up này mới là con số đáng tin.

## Method & assumptions

- **Unit:** man-day (md) of a competent Laravel/Filament + frontend engineer.
- **Costing rule:** 🟡 partial features sized as *finish-the-gap*; 🔴 missing as *full build*; ✅ excluded.
- **Cross-phase overlap** (e.g. timesheet UI in portal vs engine in P7) absorbed in contingency, not double-counted in totals.
- **Excludes** ongoing run/hosting, 3rd-party license fees (Twilio/GoCardless/DocuSign/Yoti), and post-launch support.
- **Rate** is a placeholder — confirm Sotatek presale rate card before quoting the client.

## Per-phase effort

| Phase | Domain | Total md | MVP-launch md | Notes / what MVP defers |
|-------|--------|---------:|--------------:|--------------------------|
| 1 | Identity, Auth & Access | 35 | 26 | Defer 2FA, impersonation, full brand multi-user |
| 2 | Brand Portal | 60 | 44 | Defer messaging, multi-seat, calendar polish |
| 3 | Candidate Portal | 70 | 54 | Defer availability calendar, UX polish |
| 4 | Adverts & Job Lifecycle | 40 | 26 | Defer geo-search, multi-slot (if single-hire OK), templates |
| 5 | **Applications-Matching-Booking (core)** | 58 | 58 | None — non-negotiable spine |
| 6 | **Compliance & Right-to-Work** | 52 | 52 | None — legal gate |
| 7 | Timesheets & Attendance | 35 | 35 | None — billing basis |
| 8 | Billing — Invoices & Payslips | 55 | 44 | Defer accounting export, credit notes, statements |
| 9 | Payments & Settlement | 32 | 8 | MVP = offline tracked only; automate later |
| 10 | Notifications & Comms | 30 | 18 | MVP = transactional email + key SMS; defer in-app centre/preferences |
| 11 | Documents, Contracts & E-sign | 27 | 15 | MVP = contract gen + storage; defer e-sign provider |
| 12 | Multi-Tenancy & White-Label | 39 | 25 | MVP = tenant-ready foundation + Tidal; full Yedi enablement later |
| 13 | Reporting & Analytics | 26 | 8 | MVP = wire dashboard + basic ops KPIs |
| 14 | **Non-Functional (security/GDPR/QA/CI-CD)** | 66 | 48 | MVP = security + core tests + CI/CD + GDPR basics; defer adv. perf |
| | **Dev subtotal** | **625** | **461** | |

## Cross-cutting overlays (added on top)

| Item | md (both scopes) |
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

> Contingency set at **15%** (above the usual 12%) because the **source code is still unseen** — some 🔴 may shrink to 🟡 (saving), but empty modules may also hide missing backend (cost). Audit (WS0) collapses this band.

## Timeline & team

**Team ~6:** 1 Tech Lead/BE, 2 Laravel/Filament BE, 2 FE, 1 QA + part-time PM & UI/UX.
Assume ~5 productive md per working-day after coordination overhead.

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

(MVP ≈ £125k–£156k; Full ≈ £165k–£206k at ~0.79.)

## Recommended delivery shape

1. **Tranche 1 — MVP launch (Tidal):** ~660 md, ~$160k–$200k, ~7 months.
   Two-sided platform that actually transacts: auth + both portals + core loop (P5) + compliance (P6) +
   timesheets (P7) + billing generation (P8) + tenant-ready foundation (P12) + security/QA baseline (P14).
   Payments offline-tracked, comms email-first.
2. **Tranche 2 — Automation + Yedi + polish:** ~+210 md, ~$50k–$63k, ~+3 months.
   Payment automation (P9), e-sign (P11), in-app notifications (P10), accounting export + credit notes (P8),
   geo/multi-slot (P4), reporting depth (P13), full Yedi tenant enablement (P12), advanced security/perf (P14).

## Reconciliation with the earlier coarse quote

| | Earlier coarse | This bottom-up (MVP) |
|---|---|---|
| Method | top-down, ~9 workstreams | per-feature across 14 domains |
| Effort | ~330 md | ~660 md |
| Cost | $80k–$99k | $158k–$198k |
| Why different | under-scoped P5/P6/P8; **omitted P14** (security/GDPR/test/CI-CD) and treated P12 as trivial | every feature counted with its gap |

The earlier number was **optimistic and under-scoped** — surfaced exactly by doing the feature-level pass you asked for.

## Confidence & what moves it

- **±15% band** until source audit (WS0). Audit + Yedi access tighten to a firm fixed-price.
- **Black-box behavioral test done** (`tidal-blackbox-test-findings.md`) — the band **still holds**: some
  items shrank (Application CRUD+aggregation works; evidence capture is real), some grew (no admin RBAC;
  Declarations create is a production bug; Booking entity still greenfield). Net ~neutral.
- **Resolved (domain recon):** no live brand/candidate front-end exists — `tidalagency.co.uk` is marketing
  only, `app.tidalagency.co.uk` is an empty nginx 403 placeholder, Filament admin is the only running app.
  Candidate evidence data is most likely dev seed (`@ne6.studio`). → **P2/P3 portals confirmed greenfield**
  (the optimistic "could shrink P3/P6" reducer is removed; estimate stands, not reduced).
- Remaining swing factors: **(a)** whether Invoice/Payslip/Booking have hidden backend services not wired to
  UI (could cut P5/P8); **(b)** candidate employment model PAYE/umbrella/self-employed (drives P8/P9 tax);
  **(c)** single-hire vs multi-slot adverts (P4/P5 schema); **(d)** Yedi code-divergence (P12);
  **(e)** whether an unreleased **mobile app** exists (marketing claims one; none found live).

## Open questions

1. Confirm Sotatek blended **rate card** to replace the $240–300 placeholder.
2. **Source code + Yedi access** to collapse the ±15% band and confirm P5/P12 assumptions.
3. Confirm **MVP scope** is the right launch line, or adjust which deferrals move into Tranche 1.
