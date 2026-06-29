# Proposal — Tidal / Yedi Staffing Platform: From Admin to Production

**Prepared by:** Sotatek · **For:** Tidal Agency / Yedi · **Date:** 2026-06-29 · **Status:** Draft v1

> Indicative proposal. Figures are estimates from a technical assessment of the live admin;
> they convert to a firm fixed price after a short paid discovery/audit (see §8). Day-rate is a
> placeholder pending Sotatek's current rate card.

---

## 1. Executive summary

You have built a solid **internal admin** (Laravel + Filament) for a two-sided luxury-retail
staffing marketplace. The **data foundation is strong**; what's missing is the **transactional
engine** and the **self-service surfaces** that turn it into a usable product for brands and
candidates.

We propose to **keep and extend** your existing codebase (not rebuild) and deliver, in two tranches:

- **Phase 1 — MVP launch (Tidal):** brand + candidate web portals, the full booking→billing loop,
  compliance, on a multi-tenant-ready foundation. **~5.5–6 months.**
- **Phase 2 — Automation + Yedi + polish:** payment automation, e-signature, in-app notifications,
  full Yedi market, advanced reporting. **~+2–3 months.**

Indicative investment: **Phase 1 ≈ £125k–£156k**; full production-grade ≈ £165k–£206k (see §7).

This proposal is grounded in a **hands-on technical assessment** of your live system (not assumptions) —
including a behavioral test that verified exactly what works today and what does not (§3).

---

## 2. What you have today (verified)

We logged into your live admin and tested it directly. **The spine is real and reusable:**

- **Rich domain model** — Adverts (pricing, brand/candidate charge %, shifts, address, documents),
  Candidates (4-section profile, references, compliance status, ID/video/contract evidence storage),
  Brands, and a fully-configured **System settings** (charge defaults, references policy, invoice
  bank details & terms, applicant/advertiser contract templates).
- **Working admin CRUD** for all core entities, with status filters, bulk actions, and a dashboard
  with financial widgets.
- **Application logic partially works** — creating an application correctly updates related records
  (accepted-application, candidate counters).
- Brand & candidate **login identities exist** in the data model.

This is a meaningful head start — roughly a quarter of a production platform's features are already
in place or partially built.

---

## 3. The gap to production (from our assessment)

The product today is **admin-only**. The pieces that make it a live, sellable two-sided platform are
not yet built:

| Area | Current state (verified) | Gap to production |
|------|--------------------------|-------------------|
| **Brand & Candidate portals** | None — no live front-end (`app.` subdomain is an empty placeholder; the public site is marketing only) | Build both self-service web portals |
| **Core booking loop** | Applications persist, but no Booking entity, no allocation, no status automation | Build matching → offer/accept → booking |
| **Billing (invoices/payslips)** | Templates & bank config exist; **no generation engine** (no way to produce a document) | Build invoice & payslip generation + PDF + lifecycle |
| **Compliance / right-to-work** | Evidence storage exists; rules, enforcement, and a working capture flow do not | Build compliance rules engine + enforcement |
| **Timesheets** | None | Build shift → hours → pay basis |
| **Auth & access** | Admin login works; no portal auth, no roles/permissions (RBAC), no password reset/2FA | Build multi-party auth + RBAC |
| **Multi-tenancy (Tidal + Yedi)** | Single deployment, no tenant isolation | Build multi-tenant, white-label foundation |
| **Payments, notifications, e-sign, reporting** | Minimal/none | Build per phased scope |

Across ~110 discrete features we assessed: **~23 done, ~41 partial, ~46 missing.**

**One finding to flag now (no charge):** creating a Declaration in the current admin fails due to a
file-upload error on your server — worth fixing regardless of this engagement.

---

## 4. Recommended approach

- **Keep & extend** the existing Laravel/Filament backend — reuse the domain model and admin; build
  new surfaces and engines on top. Avoids a costly rebuild.
- **Two responsive web portals** (brand + candidate) — mobile-friendly, no native app in Phase 1.
- **Multi-tenant from the foundation** — one codebase, white-labelled per market (Tidal first, Yedi
  enabled as configuration). Cheaper now than retrofitting later.
- **Semi-automated billing for launch** — auto-generate invoices/payslips as PDFs; settle payments
  offline initially, automate collection/payouts in Phase 2.
- **Compliance enforced, not just labelled** — only compliant candidates can be booked.

---

## 5. Scope

### Phase 1 — MVP launch (Tidal)
Auth + RBAC · Brand portal (post/manage adverts, review applicants, bookings, invoices) ·
Candidate portal (onboarding, evidence upload, search, apply, accept, timesheet, payslips) ·
Core booking loop · Compliance engine · Timesheets · Invoice/payslip generation (PDF) ·
Multi-tenant foundation · Security, GDPR baseline, automated tests, CI/CD · Tidal go-live.

### Phase 2 — Automation + Yedi + polish
Payment automation (collection + payouts) · Automated ID/right-to-work verification ·
E-signature · In-app notifications · Accounting export & credit notes · Geo/multi-slot adverts ·
Reporting depth · Full Yedi market enablement · Advanced performance/security.

### Out of scope (this engagement)
Native mobile apps (separate track), data migration beyond existing records, third-party license
fees, ongoing hosting/support (proposed separately).

---

## 6. Delivery plan & timeline

Team of ~6: 1 tech lead/BE, 2 Laravel/Filament BE, 2 FE, 1 QA, with part-time PM & UI/UX.

| | Phase 1 (MVP) | Full production-grade |
|---|---|---|
| Effort | ~660 person-days | ~870 person-days |
| Timeline | **~5.5–6 months** | **~8.5–10 months** |

Indicative phasing: M1 discovery+audit & foundation → M2–3 core loop + billing + brand portal →
M3–4.5 candidate portal + compliance → M5–6 integration, QA, Tidal go-live; Yedi as configuration.

---

## 7. Investment (indicative)

| Scope | Estimate (GBP) | Estimate (USD) |
|-------|----------------|----------------|
| **Phase 1 — MVP launch (Tidal)** | **~£125k–£156k** | ~$158k–$198k |
| Enhancement tranche (Phase 2) | ~£40k–£50k | ~$50k–$63k |
| **Full production-grade (both phases)** | **~£165k–£206k** | ~$209k–$261k |

Figures are bottom-up from a per-feature assessment (not a top-down guess). Excludes hosting,
third-party license fees, and post-launch support. Day-rate to be confirmed against Sotatek's rate card.

---

## 8. Commercial model — audit-first (de-risked for both sides)

We have assessed your **running system**, but not your **source code**. To protect both parties:

1. **Phase 0 — Discovery & code audit (~2 weeks, fixed price).** We review the repository, confirm
   reusability, and validate the estimate.
2. **Firm fixed price** for Phase 1 issued at the end of Phase 0, within (or below) the indicative
   range above.

This avoids both an inflated "safety-margin" quote and mid-project surprises.

---

## 9. Assumptions & dependencies (to confirm)

1. **Source code (Git) access** for the audit — the single biggest driver of pricing precision.
2. **Yedi** details (URL/credentials) — to confirm single multi-tenant vs separate deployment.
3. **Is there an unreleased mobile app?** Your marketing references an "OnDemand App"; we found no
   live app — please confirm so we scope the candidate front-end correctly.
4. **Candidate employment model** (PAYE / umbrella / self-employed) — drives payslip & tax logic.
5. **Adverts: single-hire or multi-slot** (one role vs N positions per advert) — affects booking & billing.

---

## 10. Why Sotatek

- We start from **evidence**: this proposal is built on a hands-on test of your live system, including
  a behavioral verification of what works — so the scope is real, not guessed.
- **Keep-and-extend** approach respects the investment you've already made.
- Offshore delivery at competitive rates with a senior-led team.

---

## 11. Next steps

1. Confirm rate card & approve **Phase 0 (audit)**.
2. Provide **source code + Yedi access**; answer the §9 questions.
3. We deliver the firm fixed-price for Phase 1 within 2 weeks.

---

*Appendices available on request: full 14-domain feature-gap analysis, behavioral test findings with
47 evidence screenshots, and the per-feature effort breakdown.*
