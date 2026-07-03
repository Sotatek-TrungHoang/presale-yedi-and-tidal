# §8.3 Route nhanh nhất tới MVP + §8.4 Product roadmap

> Nội bộ Sotatek · 2026-07-03 · dựa §6 MVP docx + gap Phase 5 + kiến trúc shared Phase 4.

## §8.3 Con đường nhanh nhất tới MVP ổn định

**Chiến lược:** *Keep & extend* trên nền shared codebase — KHÔNG rebuild. Xây theo thứ tự dependency để mỗi bước mở khoá bước sau. Làm **1 lần cho cả 2 platform** (multi-tenant), Tidal go-live trước, Yedi bật bằng config + lớp compliance giáo dục.

### Thứ tự build (dependency-ordered)
```
0. Discovery + source audit (2 tuần)  ── chốt biến số, khoá fixed-price
1. Foundation: multi-tenant + auth + RBAC + CI/CD + env
        │
2. Auth portal (candidate + client/school): register/login/reset/verify
        │
3. Adverts lifecycle (state machine) + public job page + search
        │
4. Core loop: Application → Matching → Offer/Accept → **Booking entity**
        │
5. Timesheet (submit → approve → lock)
        │
6. Billing engine: Invoice + Payslip generation + PDF (offline payment tracking)
        │
7. Compliance engine + **enforcement gate** (block non-compliant)
        │   └── Yedi: DBS/safeguarding/expiry layer (gate bắt buộc trước go-live Yedi)
        │
8. Notification (email-first + key SMS) + dashboard wire số thật
        │
9. Security/GDPR baseline + automated tests (money + compliance) → Tidal go-live
```

**Tái dùng được (không tính tiền lại):** data model lõi, admin CRUD, System settings, evidence storage schema, config per-tenant, dashboard shell.
**Build mới (phần lớn effort):** toàn bộ portal, booking entity, billing/matching/timesheet engine, compliance enforcement, RBAC, notification, multi-tenancy, non-functional.

**Đường ngắn nhất = MVP launch Tidal (~660 md, ~6.5-7.5 tháng)** — two-sided platform transact được. Yedi bật ngay sau bằng config + delta compliance giáo dục.

---

## §8.4 Product roadmap đề xuất

Legend: **[C]** = chung 2 platform (làm 1 lần) · **[Y]** riêng Yedi · **[T]** riêng Tidal.

### MVP / Tranche 1 — "Launch được" (~660 md)
- **[C]** Auth + RBAC + multi-tenant foundation
- **[C]** Brand/School portal: post/manage request, review applicants, bookings, invoices view
- **[C]** Candidate/Teacher portal: onboarding, upload evidence, **set availability**, search, apply, accept, timesheet, payslip view
- **[C]** Core booking loop (Application→Matching→Offer/Accept→Booking)
- **[C]** **Availability model + clash detection cơ bản** (không double-book — input matching)
- **[C]** Compliance engine + enforcement (chỉ compliant mới book được)
- **[C]** Timesheet (submit→approve→lock)
- **[C]** Invoice/Payslip generation (PDF); payment **offline-tracked**
- **[C]** **Basic notification** (email-first + key SMS: booking confirm, timesheet, compliance alert)
- **[C]** Security + GDPR baseline + automated tests + CI/CD
- **[Y]** Lớp compliance giáo dục: DBS number/expiry, safeguarding training, document-expiry gate (**gate bắt buộc go-live Yedi**)
- **[T]** Tidal go-live trước; talent-pool cơ bản

### Tranche 2 — Automation + Yedi full + polish (~+210 md)
- **[C]** Payment automation (GoCardless collection + candidate payout) + reconciliation
- **[C]** E-signature (contract)
- **[C]** In-app notification centre + preferences
- **[C]** Accounting export (Xero/CSV) + credit notes
- **[C]** Geo/distance + multi-slot adverts
- **[C]** Reporting depth (ops KPI: fill rate, time-to-fill; compliance reporting)
- **[C]** Availability calendar + clash detection nâng cao
- **[C]** **Ratings & Feedback 2 chiều** (client↔candidate) + reliability tracking → nuôi matching
- **[C]** **Referral programme** (candidate giới thiệu candidate)
- **[C]** **Training/onboarding records** (in-app) + expiry
- **[Y]** Yedi full market enablement + education matching (age group/school type/reliability)
- **[T]** Client-visibility dashboard đầy đủ ("Tidal OS": coverage/fill/spend/ratings) + talent pool by city/brand

### Future / Advanced
- AI-assisted matching; demand forecasting; performance scoring
- Automated compliance reminders; client self-serve booking; dynamic rate management
- Automated payroll/invoice; mobile app (native — track riêng); workforce analytics sâu

**Ghi chú roadmap:** phần **[C]** chiếm đa số → xác nhận lợi ích shared backend (làm 1 lần, dùng 2). Khác biệt ngành **[Y]/[T]** là lớp mỏng config/rule/field/branding.
</content>
