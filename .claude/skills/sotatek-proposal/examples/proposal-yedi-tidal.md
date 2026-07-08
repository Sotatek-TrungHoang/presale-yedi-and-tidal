---
project: "YEDI + TIDAL"
subtitle: "Two-Sided Staffing Platform"
tagline: "From Admin Panel to Production Product"
version: "v1.0"
author: "Sotatek"
approver: ""
location: "Hanoi"
date: "July 6th 2026"
presenter: { name: "Sotatek", position: "Solutions / Delivery", division: "Global Delivery" }
edit_history:
  - { date: "Jul 6, 2026", version: "1.0", description: "Create", editor: "Sotatek" }
approval:
  - { date: "", version: "1.0", approver: "", position: "" }
---

# 1. Project Overview

Yedi and Tidal are a two-sided staffing platform — Yedi connects schools with teachers; Tidal connects brands with candidates — built on a Laravel + Filament admin panel. Sotatek proposes a "keep & extend" programme (no rebuild) that turns the internal admin panel into a production, self-service, transacting product, delivered on a single shared multi-tenant foundation.

*Figures in this proposal are indicative estimates based on a direct, hands-on assessment of the live admin systems (black-box — without source-code access). They will be converted to a fixed price following a ~2-week Phase 0 audit.*

## Current State — Directly Verified

We logged in and tested the live admin of both platforms (Tidal on 2026-06-29; Yedi + Tidal re-verification on 2026-07-03). The backbone is real and reusable — roughly a quarter of a full platform already exists:

- **Rich data model:** Adverts (rate, charge %, shift, address, docs), Candidates (4-tab profile, references, compliance status, ID/video/contract storage), Brands/Schools, and System settings.
- **Working admin CRUD:** full resource coverage, status filters, bulk actions and financial dashboard widgets.
- **Partial application logic:** creating an Application correctly updates the related records.
- **Per-tenant configuration:** Yedi carries 5 education job-roles (QTS) plus a "DBS Evidence" catalogue; Tidal carries its charge defaults.
- **Key finding:** Yedi and Tidal are currently the SAME codebase — separately deployed, re-labelled and configured per tenant.
- **Assessment:** across ~110 features assessed: ~23 done, ~41 partial, ~46 missing.

## Solution Value Proposition

What remains is the transaction engine and the self-service surfaces that turn the admin panel into a sellable product. Because every missing engine is identical for both platforms, we build it once on a multi-tenant foundation:

- Two self-service portals (Brand/School + Candidate/Teacher).
- Core booking engine: Application → Matching → Offer/Accept → Booking.
- Billing engine: invoice/payslip generation + PDF + lifecycle.
- Compliance & right-to-work engine with enforcement.
- Timesheets, multi-party authentication, RBAC and notifications.
- Shared multi-tenant white-label foundation — ~40–45% cheaper than two separate builds.

## Project Objectives

- Turn the internal admin panel into a production, self-service, transacting two-sided platform.
- Launch the Tidal MVP in ~4 months on a shared multi-tenant foundation.
- Enable Yedi immediately after via configuration plus the education compliance layer (DBS/safeguarding — a mandatory gate).
- Deliver production-grade security, a GDPR baseline, automated tests and CI/CD.

# 2. Project Scope

## 2.1 In-Scope Items

Delivery is organised into two tranches. Tranche 1 delivers a launchable Tidal MVP on a shared multi-tenant foundation; Yedi is enabled immediately after via configuration plus the education compliance layer. Tranche 2 adds automation, full Yedi education matching and reporting depth (see 2.1.11).

### 2.1.1 Identity, Authentication & Access

- Multi-party authentication (Brand/School, Candidate/Teacher, Admin) with password reset and 2FA.
- Role-based access control (RBAC) across portals and admin.

### 2.1.2 Brand/School Portal

- Post and manage staffing requests / adverts; review applicants.
- Booking management and invoice view.

### 2.1.3 Candidate/Teacher Portal

- Onboarding, profile, upload evidence, set availability.
- Search, apply, accept; timesheet submission and payslip view.

### 2.1.4 Adverts & Job Lifecycle

- Advert creation, status lifecycle, and publishing to the candidate portal.

### 2.1.5 Applications, Matching & Booking (Core Loop)

- Application → Matching → Offer/Accept → Booking, with allocation and auto-status.
- Availability model + basic clash detection.

### 2.1.6 Compliance & Right-to-Work

- Compliance engine with rules, enforcement and evidence capture (right-to-work gate).
- Yedi education layer: DBS / safeguarding (mandatory gate) enabled per tenant.

### 2.1.7 Timesheets & Attendance

- Shift → hours → pay-basis capture feeding billing and payslips.

### 2.1.8 Billing (Invoice / Payslip)

- Invoice and payslip generation + PDF output + lifecycle (using existing bank/terms/template config).

### 2.1.9 Notifications & Communications

- Basic notifications: email-first plus key SMS (booking / timesheet / compliance).

### 2.1.10 Multi-Tenancy & Non-Functional

- Shared multi-tenant white-label foundation (Yedi + Tidal from one codebase).
- Security + GDPR baseline, automated tests and CI/CD; Tidal go-live.

### 2.1.11 Tranche 2 — Automation, Full Yedi & Polish

- Payment automation (collection + payout); accounting export + credit notes.
- Automated ID / right-to-work verification; e-signature; in-app notification centre.
- Two-way ratings & feedback (client ↔ candidate) + reliability tracking → feeding matching.
- Referral programme; training/onboarding records (in-app).
- Geo / multi-slot adverts; reporting depth; full Yedi + education matching.
- Tidal client-visibility dashboard ("Tidal OS": coverage / fill / spend / ratings).

## 2.2 Out-of-Scope Items

The following are excluded from this engagement and may be considered for future development:

- Native mobile app (separate track).
- Data migration beyond existing records.
- Third-party licence fees.
- Hosting and support after launch.

## 2.3 Dependencies and Assumptions

| # | Category | Description |
|:-:|---|---|
| 1 | Access | Source code + Git access — the biggest variable: whether the empty modules hide a backend, and whether it is a single ENV-configured mono-repo or two drifting forks. |
| 2 | Scope | Candidate employment model (PAYE / umbrella / self-employed) — drives payslip and tax logic. |
| 3 | Scope | Adverts single-hire vs multi-slot — affects the booking/billing schema. |
| 4 | Scope | Whether a mobile app has already been released ("OnDemand App" in marketing) — affects front-end scope. |
| 5 | Third-Party | Payment, SMS, ID-verification and e-sign services (e.g. GoCardless / Twilio / Yoti / DocuSign) — licence fees are client-borne. |
| 6 | Third-Party | Cloud infrastructure (AWS/GCP) costs are paid directly by the client. |
| 7 | Commercial | Fixed price for Tranche 1 is issued at the end of the Phase 0 audit, within (or below) the indicative ranges. |
| 8 | Q&A | Questions and clarifications are answered within 2 working days. |

# 3. Solution Approach

## 3.1 Delivery Methodology

We employ an Agile Scrum methodology with 2-week sprints, following a "keep & extend" approach (no rebuild). A ~2-week Phase 0 audit precedes development: we review the repository, confirm reusability and validate the estimate, then issue a fixed price for Tranche 1.

**Key ceremonies:**

- Sprint Planning — define the sprint backlog from prioritised user stories.
- Daily Standups — 15-minute sync on progress, blockers and next steps.
- Sprint Demo — bi-weekly client demonstration of working software.
- Sprint Retrospective — team reflection to improve the process.

## 3.2 Communication & Collaboration

| Tool / Activity | Purpose |
|---|---|
| Slack / Google Chat | Daily communication, real-time questions and updates |
| Jira | Project tracking, backlog, sprint progress, burn-down charts |
| GitHub / GitLab | Version control, pull-request reviews, automated CI/CD |
| Confluence / Google Docs | SRS, technical documentation, API specs, user guides |
| Figma | UI/UX design, interactive prototypes, design system |
| Zoom / Teams | Bi-weekly demos and reviews |

## 3.3 Quality Assurance Strategy

| Testing Type | Tools | Target / Approach |
|---|---|---|
| Automated Testing | PHPUnit / Pest | Unit + feature tests on booking, billing and compliance logic |
| Integration Testing | QA Engineer | End-to-end portal flows (post → match → book → timesheet → invoice) |
| Manual / Exploratory | QA Engineer | Edge cases, RBAC, multi-tenant isolation, UX validation |
| User Acceptance | Staging environment | Client-led acceptance before go-live |

# 4. Technical Requirements

## 4.1 Core Architectural Principles

- Keep & extend the existing Laravel + Filament core — no rebuild.
- Shared multi-tenant backend; the industry layer is switched on/off via configuration.
- Per-tenant compliance isolation — Yedi safeguarding stays separate from Tidal.
- API-first services powering the Brand and Candidate self-service portals.
- Security and GDPR by design; automated tests and CI/CD from day one.

## 4.2 System Architecture

The system extends the existing admin into a layered, service-oriented platform:

- **Client layer:** Admin (Filament), Brand/School portal, Candidate/Teacher portal.
- **API layer:** REST services with multi-party JWT/session auth and RBAC.
- **Service layer:** Identity, Adverts, Applications/Matching/Booking, Compliance, Timesheets, Billing, Notifications, Multi-Tenancy.
- **Data layer:** MySQL/PostgreSQL (multi-tenant schema), Redis (cache/queue), S3-compatible document storage.
- **External services:** Email/SMS, payments, ID verification and e-signature (Tranche 2).

## 4.3 Architecture Options — Shared vs Separate

Because every missing engine is identical for both platforms, we recommend building it once on a multi-tenant foundation:

| Scenario | Cost | Assessment |
|---|:-:|---|
| A. Shared multi-tenant; industry-specific FE / branding / compliance | Lowest | RECOMMENDED — matches your instinct |
| B. Shared core library + two separate deployments | Medium | Versioning overhead; drift risk |
| C. Two fully separate products | Highest (+70–90%) | Not recommended — 2× maintenance |

## 4.4 Technical Configuration

| Category | Technology | Note |
|---|---|---|
| Backend Framework | Laravel (PHP) | Existing core — keep & extend |
| Admin Panel | Filament 3.x | Existing admin — reuse & extend |
| Frontend (portals) | Livewire + Blade / Inertia | Brand & Candidate self-service portals |
| Database | MySQL 8 / PostgreSQL 14+ | Multi-tenant schema |
| Cache / Queue | Redis + Laravel Queue | Async billing, PDF, notifications |
| File Storage | S3-compatible | Documents, evidence, contracts, PDFs |
| Auth | Laravel + RBAC (2FA) | Multi-party auth; per-tenant roles |
| Notifications | Email (SES/SMTP) + SMS (Twilio) | Email-first + key SMS |
| Payments (Tranche 2) | GoCardless / Stripe | Collection + payout |
| CI/CD | GitHub Actions / GitLab CI | Automated tests, build, deploy |
| Multi-Tenancy | Config-driven tenant + industry layer | White-label Yedi / Tidal |

# 5. Master Schedule

## 5.1 Master Schedule Overview

- **Phase 0 (Discovery & code audit):** ~2 weeks — review repository, confirm reusability, issue fixed price.
- **Tranche 1 (MVP):** ~4 months (8 × 2-week sprints) — Tidal go-live, enlarged parallel team (peak ~9–10).
- **Yedi enablement:** +2–3 weeks — configuration + education compliance layer (DBS/safeguarding).
- **Tranche 2 (Enhancement):** ~2 months (4 × 2-week sprints).

*The MVP timeline is compressed from ~7 months to ~4 months by parallelising the same ~660 md of scope across a larger team — total effort is unchanged.*

## 5.2 Tranche 1 (MVP) Sprint Breakdown

| Sprint | Timeline | Key Activities |
|:-:|:-:|---|
| Sprint 1 | Week 1–2 | Phase 0 hand-off & foundation: multi-tenant core, DB/domain model extension, CI/CD, auth + RBAC scaffolding |
| Sprint 2 | Week 3–4 | Identity/Auth/Access complete (2FA, reset, RBAC); Brand/School & Candidate/Teacher portal skeletons |
| Sprint 3 | Week 5–6 | Adverts & job lifecycle; candidate evidence upload + availability model; application persistence |
| Sprint 4 | Week 7–8 | Core booking loop (Application → Matching → Offer/Accept → Booking); basic clash detection |
| Sprint 5 | Week 9–10 | Compliance engine + right-to-work enforcement; Timesheets (shift → hours → pay basis) |
| Sprint 6 | Week 11–12 | Billing (Invoice/Payslip) generation + PDF + lifecycle; basic notifications (email-first + key SMS) |
| Sprint 7 | Week 13–14 | Multi-tenant white-label finalisation; security + GDPR baseline; automated tests + CI/CD; Tidal UAT |
| Sprint 8 | Week 15–16 | Bug-fix & performance; Tidal go-live; Yedi enablement via configuration + education compliance |

## 5.3 Tranche 2 (Enhancement) Sprint Breakdown

| Sprint | Timeline | Key Activities |
|:-:|:-:|---|
| Sprint 1 | Week 1–2 | Payment automation (collection + payout); accounting export + credit notes |
| Sprint 2 | Week 3–4 | Automated ID / right-to-work verification; e-signature; in-app notification centre |
| Sprint 3 | Week 5–6 | Two-way ratings & feedback + reliability tracking → matching; referral programme; training records |
| Sprint 4 | Week 7–8 | Geo / multi-slot adverts; reporting depth; full Yedi education matching; Tidal OS dashboard; UAT |

# 6. Work Breakdown Structure & Quotation

## 6.1 Quotation Summary

We propose a fixed-price model per tranche, issued at the end of Phase 0 and falling within (or below) the indicative ranges below. Figures exclude hosting, third-party licences (e.g. Twilio / GoCardless / DocuSign / Yoti) and post-launch support.

| Item | Effort | Timeline | Indicative (USD) |
|---|:-:|:-:|:-:|
| Tranche 1 — MVP launch (Tidal, shared) | ~660 md (~34 M/M) | ~4 months | ~$158k–198k |
| + Yedi education delta | +40–70 md | +2–3 weeks | ~$10k–21k |
| Enhancement (Tranche 2) | ~210 md (~11.5 M/M) | ~+2 months | ~$50k–63k |
| Full production-grade (both platforms) | ~870 md | ~6–6.5 months | ~$209k–261k |

> Indicative ranges (GBP equivalent ~£125k–156k for Tranche 1). A fixed price is issued after Phase 0. Cloud infrastructure and third-party service fees are paid directly by the client.

## 6.2 Work Breakdown Structure (Effort by Domain)

Bottom-up, per-feature effort across 14 domains (man-days). PM and contingency are included in the totals.

| Domain | Full (md) | MVP (md) |
|---|:-:|:-:|
| P1  Identity / Auth / Access | 36 | 27 |
| P2  Brand/School Portal | 56 | 48 |
| P3  Candidate/Teacher Portal | 67 | 59 |
| P4  Adverts / Job Lifecycle | 41 | 26 |
| P5  Applications / Matching / Booking (core) | 59 | 52 |
| P6  Compliance & Right-to-Work | 48 | 41 |
| P7  Timesheets & Attendance | 35 | 27 |
| P8  Billing (Invoice / Payslip) | 55 | 46 |
| P9  Payments & Settlement | 32 | 8 |
| P10 Notifications & Comms | 27 | 14 |
| P11 Documents / Contracts / E-sign | 30 | 19 |
| P12 Multi-Tenancy / White-Label | 39 | 29 |
| P13 Reporting & Analytics | 25 | 7 |
| P14 Non-Functional (security / GDPR / QA / CI-CD) | 68 | 59 |
| Development subtotal | 618 | 462 |
| + Overlay (discovery/audit, UI-UX, foundation) | 50 | 50 |
| + PM + contingency (included) | — | — |
| TOTAL (rounded) | ~870 | ~660 |

> Yedi education delta: +40–70 md beyond the baseline.

## 6.3 Team Structure & Cost Breakdown

**6.3.1 Tranche 1 (MVP) — ~4 months, team peaking at ~9–10**

| Position | M1 | M2 | M3 | M4 | Total (M/M) | Unit Price (USD) | Total Cost (USD) |
|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| PM | 1 | 1 | 1 | 0.5 | 3.5 | $5,000 | $17,500 |
| BA & UI/UX Designer | 1 | 1 | 0.5 | 0.5 | 3.0 | $4,500 | $13,500 |
| Tech Lead / Solution Architect | 1 | 1 | 1 | 1 | 4.0 | $6,500 | $26,000 |
| Senior Backend Engineer | 2 | 2 | 2 | 1.5 | 7.5 | $5,200 | $39,000 |
| Senior Frontend Engineer | 2 | 2 | 2 | 1.5 | 7.5 | $5,200 | $39,000 |
| DevOps Engineer | 0.5 | 0.5 | 0.5 | 0.5 | 2.0 | $5,500 | $11,000 |
| QC Engineer | 1 | 2 | 2 | 1.5 | 6.5 | $4,200 | $27,300 |
| TOTAL | 8.5 | 9.5 | 9.0 | 7.0 | 34.0 |  | $173,300 |

> Indicative; fixed price issued after Phase 0, within the Tranche 1 range (~$158k–198k). Yedi education delta adds +2–3 weeks and +$10k–21k.

**6.3.2 Tranche 2 (Enhancement) — ~2 months**

| Position | M1 | M2 | Total (M/M) | Unit Price (USD) | Total Cost (USD) |
|---|:-:|:-:|:-:|:-:|:-:|
| PM | 0.5 | 0.5 | 1.0 | $5,000 | $5,000 |
| BA & UI/UX Designer | 0.5 | 0.5 | 1.0 | $4,500 | $4,500 |
| Senior BE/FE Engineer | 3 | 3 | 6.0 | $5,200 | $31,200 |
| DevOps Engineer | 0.5 | 0.5 | 1.0 | $5,500 | $5,500 |
| QC Engineer | 1 | 1.5 | 2.5 | $4,200 | $10,500 |
| TOTAL | 5.5 | 6.0 | 11.5 |  | $56,700 |

## 6.4 Payment Milestones

**6.4.1 Tranche 1 (MVP)**

| Milestone | Deliverables | Percentage | Timeline |
|---|---|:-:|:-:|
| M1: Contract & Phase 0 | Signed SOW, fixed price issued, environment provisioned, foundation started | 40% | Upon execution |
| M2: Core Booking Demo | Auth + RBAC, portals, adverts, and core booking loop working | 25% | Week 8 |
| M3: UAT (Compliance & Billing) | Compliance, timesheets, billing and notifications complete; Tidal UAT | 25% | Week 14 |
| M4: Go-Live | Tidal production launch, Yedi enabled, documentation + source transfer | 10% | Week 16 |

**6.4.2 Tranche 2 (Enhancement)**

| Milestone | Deliverables | Percentage | Timeline |
|---|---|:-:|:-:|
| M1: Kickoff | Scope confirmation, sprint planning | 50% | Upon execution |
| M2: Automation Demo | Payments, ID verification, e-sign, notification centre | 25% | Week 4 |
| M3: Full Feature & UAT | Ratings, referral, training, reporting, full Yedi, Tidal OS | 15% | Week 7 |
| M4: Launch | Production deployment, docs, source transfer, 2-week post-launch support | 10% | Week 8 |

# 7. Future Enhancements Roadmap

The following are planned for future phases, subject to Tranche 1–2 feedback and client priorities.

- Native mobile apps (candidate / brand) — separate track.
- Advanced matching (AI/ML ranking on reliability, distance and ratings).
- Analytics / BI depth — expansion of the "Tidal OS" coverage / fill / spend / ratings dashboards.
- Integrations marketplace (accounting, HR, background-check providers).
- Data migration tooling for historical records.
- Additional industry verticals on the same multi-tenant core.

# 8. Q&A, Commercial Model & Next Steps

**Q1 — Is the estimate firm?**

No — the figures are indicative (black-box assessment). A ~2-week Phase 0 audit reviews the repository and converts the estimate into a fixed price within (or below) the ranges, so there are no mid-project surprises for either side.

**Q2 — Why a shared multi-tenant build?**

Every missing engine is identical for both platforms. Building once and switching the industry layer via configuration is ~40–45% cheaper than two separate builds, while per-tenant compliance isolation keeps Yedi safeguarding separate from Tidal.

**Q3 — What makes the MVP launchable in ~4 months?**

A larger, parallelised team (peaking at ~9–10) delivers the same ~660 md of scope in ~4 months instead of ~7. Foundation, portals, booking, compliance, timesheets and billing are built in parallel streams rather than sequentially. Total effort — and therefore cost — is unchanged.

**Q4 — What is the biggest risk?**

Source-code / Git access and the candidate employment model. Both are resolved during Phase 0 before any fixed price is committed.

*Goodwill note: during the assessment we identified a production bug — Declaration creation fails on upload (Livewire) — present on both platforms (shared code). We are happy to share the details at no charge.*

## Next Steps

| # | Step |
|:-:|---|
| 1 | Approve Phase 0 (audit). |
| 2 | Provide source code + Yedi/Tidal access; confirm the assumptions in Section 2.3. |
| 3 | Sotatek issues a fixed price for Tranche 1 within ~2 weeks. |

*Appendices available on request: 14-domain gap analysis (EN + VI), black-box test pack (47 screenshots), per-feature effort WBS, requirements traceability matrix, and the Yedi↔Tidal cross-comparison.*
