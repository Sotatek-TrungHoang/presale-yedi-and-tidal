# Effort & Cost Breakdown — per feature (WBS)

> Bottom-up estimate: every feature from the gap analysis (`plans/260629-feature-gap-analysis/`)
> sized individually, with evidence. Rolls up feature → phase → tranche → total.
> Date: 2026-06-29.

## Method & rate

- **Unit:** man-day (md). **Maturity** (verified live + black-box): ✅ done · 🟡 partial · 🔴 missing.
- **Sizing rule:** ✅ = 0 (reuse); 🟡 = finish-the-gap only; 🔴 = full build.
- **Tranche:** `MVP` = Phase 1 (Tidal launch) · `P2` = Phase 2 (automation/Yedi/polish).
- **Cost:** indicative at **$270/md midpoint** (range $240–300). Per-feature $ = md × $270 (rounded).
- **Overlaps** (e.g. timesheet UI in portal vs engine in P7) are split across the owning lines, not double-counted.
- **"Evidence" column** = why this maturity/size, citing the live test (`tidal-blackbox-test-findings.md`, `evidences/`).

---

## P1 — Identity, Auth & Access

| # | Feature | Mat. | Tranche | md | $@270 | Evidence / rationale |
|---|---------|:----:|:-------:|---:|------:|----------------------|
| 1.1 | Admin login | ✅ | — | 0 | 0 | works (Filament login verified) |
| 1.2 | Admin RBAC (roles/permissions + policies + UI) | 🔴 | MVP | 7 | 1,890 | no role field at all (blackbox t4-user-roles) |
| 1.3 | Brand auth guard + login/logout | 🔴 | MVP | 4 | 1,080 | account exists, no front door |
| 1.4 | Candidate auth guard + login/logout | 🔴 | MVP | 4 | 1,080 | account exists, no front door |
| 1.5 | Registration / invite flow | 🔴 | MVP | 4 | 1,080 | none |
| 1.6 | Email verification | 🔴 | MVP | 2 | 540 | none |
| 1.7 | Password reset | 🔴 | MVP | 2 | 540 | none |
| 1.8 | 2FA / MFA (TOTP) | 🔴 | P2 | 3 | 810 | none |
| 1.9 | Lockout / rate-limit | 🔴 | MVP | 2 | 540 | none observed |
| 1.10 | Brand multi-user seats | 🔴 | P2 | 4 | 1,080 | single user only |
| 1.11 | Admin impersonation | 🔴 | P2 | 2 | 540 | none |
| 1.12 | Auth audit log | 🔴 | MVP | 2 | 540 | none |
| | **P1 subtotal** | | | **36** | **9,720** | MVP 27 / P2 9 |

## P2 — Brand Portal

| # | Feature | Mat. | Tranche | md | $@270 | Evidence / rationale |
|---|---------|:----:|:-------:|---:|------:|----------------------|
| 2.1 | Brand dashboard | 🔴 | MVP | 6 | 1,620 | no front-end (domain recon) |
| 2.2 | Company onboarding / profile self-edit | 🔴 | MVP | 5 | 1,350 | admin-only today |
| 2.3 | Post advert (brand-scoped + approval handshake) | 🔴 | MVP | 7 | 1,890 | reuse advert model, new UI+scoping |
| 2.4 | Manage adverts (edit/close/duplicate) | 🔴 | MVP | 5 | 1,350 | scoped CRUD |
| 2.5 | Review applications (shortlist/accept/decline) | 🔴 | MVP | 6 | 1,620 | depends P5 |
| 2.6 | Candidate profile masked view | 🔴 | MVP | 4 | 1,080 | field-visibility rules |
| 2.7 | Bookings / calendar | 🔴 | MVP | 6 | 1,620 | depends P5/P7 |
| 2.8 | Timesheet approval | 🔴 | MVP | 5 | 1,350 | depends P7 |
| 2.9 | Invoices view / pay | 🔴 | MVP | 4 | 1,080 | depends P8 |
| 2.10 | Messaging / notifications | 🔴 | P2 | 5 | 1,350 | depends P10 |
| 2.11 | Multi-user seats UI | 🔴 | P2 | 3 | 810 | depends 1.10 |
| | **P2 subtotal** | | | **56** | **15,120** | MVP 48 / P2 8 |

## P3 — Candidate Portal (responsive)

| # | Feature | Mat. | Tranche | md | $@270 | Evidence / rationale |
|---|---------|:----:|:-------:|---:|------:|----------------------|
| 3.1 | Candidate dashboard | 🔴 | MVP | 6 | 1,620 | no front-end (domain recon) |
| 3.2 | Onboarding wizard (state machine) | 🔴 | MVP | 9 | 2,430 | admin-driven today; greenfield |
| 3.3 | Profile self-edit (4 sections) | 🔴 | MVP | 6 | 1,620 | admin-only |
| 3.4 | Right-to-work doc upload | 🔴 | MVP | 6 | 1,620 | storage exists, no live capture (data=seed) |
| 3.5 | Declarations sign | 🔴 | MVP | 3 | 810 | depends P6 (current create is broken) |
| 3.6 | References submit | 🔴 | MVP | 4 | 1,080 | workflow exists admin-side only |
| 3.7 | Job search / browse + public advert page | 🔴 | MVP | 8 | 2,160 | none |
| 3.8 | Apply + track | 🔴 | MVP | 5 | 1,350 | depends P5 |
| 3.9 | Accept / decline booking | 🔴 | MVP | 4 | 1,080 | depends P5 |
| 3.10 | Availability calendar | 🔴 | P2 | 5 | 1,350 | new model |
| 3.11 | Timesheet / clock submit | 🔴 | MVP | 5 | 1,350 | depends P7 |
| 3.12 | Payslips view | 🔴 | MVP | 3 | 810 | depends P8 |
| 3.13 | Notifications | 🔴 | P2 | 3 | 810 | depends P10 |
| | **P3 subtotal** | | | **67** | **18,090** | MVP 59 / P2 8 |

## P4 — Adverts & Job Lifecycle

| # | Feature | Mat. | Tranche | md | $@270 | Evidence / rationale |
|---|---------|:----:|:-------:|---:|------:|----------------------|
| 4.1 | Data model + headcount field | 🟡 | MVP | 3 | 810 | rich model exists; add headcount |
| 4.2 | Status enum | ✅ | — | 0 | 0 | 6 statuses present |
| 4.3 | Lifecycle state machine (guards/side-effects) | 🔴 | MVP | 8 | 2,160 | free-select today, no guards (blackbox t3) |
| 4.4 | Approval workflow | 🔴 | MVP | 4 | 1,080 | labels only, no gate |
| 4.5 | Multi-slot allocation | 🔴 | P2 | 8 | 2,160 | single-hire today |
| 4.6 | Public advert page (SEO) | 🔴 | MVP | 4 | 1,080 | none |
| 4.7 | Search index / filters (backend) | 🔴 | MVP | 4 | 1,080 | pairs with 3.7 UI |
| 4.8 | Geo / distance | 🔴 | P2 | 4 | 1,080 | none |
| 4.9 | Auto-expiry / reminders | 🔴 | MVP | 3 | 810 | scheduled jobs |
| 4.10 | Draft / duplicate / template | 🔴 | P2 | 3 | 810 | none |
| | **P4 subtotal** | | | **41** | **11,070** | MVP 26 / P2 15 |

## P5 — Applications, Matching & Booking (CORE)

| # | Feature | Mat. | Tranche | md | $@270 | Evidence / rationale |
|---|---------|:----:|:-------:|---:|------:|----------------------|
| 5.1 | Application lifecycle + events | 🟡 | MVP | 6 | 1,620 | CRUD+aggregation works (blackbox t1); extend lifecycle |
| 5.2 | Candidate apply (logic) | 🔴 | MVP | 3 | 810 | depends P3 |
| 5.3 | Matching / eligibility engine | 🔴 | MVP | 10 | 2,700 | none |
| 5.4 | Suggestions / ranking | 🔴 | P2 | 3 | 810 | optional |
| 5.5 | Offer / accept handshake | 🔴 | MVP | 8 | 2,160 | none |
| 5.6 | **Booking / Assignment entity** | 🔴 | MVP | 12 | 3,240 | missing keystone (blackbox: no booking object) |
| 5.7 | Multi-slot allocation | 🔴 | P2 | 4 | 1,080 | depends 4.5 |
| 5.8 | Availability model | 🔴 | MVP | 4 | 1,080 | none |
| 5.9 | Clash detection | 🔴 | MVP | 4 | 1,080 | none |
| 5.10 | Cancellation / no-show + charge impact | 🔴 | MVP | 5 | 1,350 | none |
| | **P5 subtotal** | | | **59** | **15,930** | MVP 52 / P2 7 |

## P6 — Compliance & Right-to-Work

| # | Feature | Mat. | Tranche | md | $@270 | Evidence / rationale |
|---|---------|:----:|:-------:|---:|------:|----------------------|
| 6.1 | Compliance status auto-compute | 🟡 | MVP | 6 | 1,620 | manual label today |
| 6.2 | Required Evidence catalog (per role/type) | 🟡 | MVP | 4 | 1,080 | CRUD works (blackbox t2); add config |
| 6.3 | Document upload UI/flow | 🔴 | MVP | 6 | 1,620 | storage exists, no live capture |
| 6.4 | Verification workflow + reviewer queue | 🔴 | MVP | 8 | 2,160 | none |
| 6.5 | Expiry tracking | 🔴 | P2 | 4 | 1,080 | none |
| 6.6 | Declarations issue/sign + **fix upload bug** | 🔴 | MVP | 5 | 1,350 | create broken on prod (blackbox t2) |
| 6.7 | References automation (invites/capture) | 🟡 | MVP | 5 | 1,350 | admin workflow exists; automate |
| 6.8 | Right-to-work check (manual) | 🔴 | MVP | 4 | 1,080 | none (KYC integration → P9-adjacent) |
| 6.9 | Eligibility enforcement gate | 🔴 | MVP | 3 | 810 | no enforcement observed |
| 6.10 | Compliance audit trail | 🔴 | P2 | 3 | 810 | none |
| | **P6 subtotal** | | | **48** | **12,960** | MVP 41 / P2 7 |

## P7 — Timesheets & Attendance

| # | Feature | Mat. | Tranche | md | $@270 | Evidence / rationale |
|---|---------|:----:|:-------:|---:|------:|----------------------|
| 7.1 | Timesheet entity (per booking) | 🔴 | MVP | 6 | 1,620 | none; depends P5 |
| 7.2 | Candidate submit hours | 🔴 | MVP | 5 | 1,350 | depends P3 |
| 7.3 | Clock-in/out (geo) | 🔴 | P2 | 4 | 1,080 | none |
| 7.4 | Brand approval / dispute / adjust | 🔴 | MVP | 5 | 1,350 | depends P2 |
| 7.5 | Daily + hourly basis | 🟡 | MVP | 4 | 1,080 | daily seen; confirm/extend hourly |
| 7.6 | Breaks / overtime | 🔴 | P2 | 4 | 1,080 | none |
| 7.7 | No-show / cancellation | 🔴 | MVP | 4 | 1,080 | rules → P8 |
| 7.8 | Approved-lock / versioning | 🔴 | MVP | 3 | 810 | immutable billing input |
| | **P7 subtotal** | | | **35** | **9,450** | MVP 27 / P2 8 |

## P8 — Billing (Invoices & Payslips)

| # | Feature | Mat. | Tranche | md | $@270 | Evidence / rationale |
|---|---------|:----:|:-------:|---:|------:|----------------------|
| 8.1 | Billing config | ✅ | — | 0 | 0 | System settings configured |
| 8.2 | Charge model per advert | ✅ | — | 0 | 0 | rate/charge % present |
| 8.3 | **Invoice generation engine** | 🔴 | MVP | 12 | 3,240 | no trigger anywhere (blackbox t1/t4) |
| 8.4 | **Payslip generation engine** | 🔴 | MVP | 10 | 2,700 | none |
| 8.5 | PDF rendering / templating | 🔴 | MVP | 6 | 1,620 | none |
| 8.6 | Sequential numbering | 🔴 | MVP | 3 | 810 | none |
| 8.7 | VAT / tax | 🔴 | MVP | 6 | 1,620 | needs accountant input |
| 8.8 | Invoice lifecycle + late fees | 🔴 | MVP | 6 | 1,620 | config exists, no engine |
| 8.9 | Credit notes / adjustments | 🔴 | P2 | 4 | 1,080 | none |
| 8.10 | Accounting export (Xero/CSV) | 🔴 | P2 | 5 | 1,350 | none |
| 8.11 | Wire dashboard financials to real data | 🟡 | MVP | 3 | 810 | widgets exist, all £0 |
| | **P8 subtotal** | | | **55** | **14,850** | MVP 46 / P2 9 |

## P9 — Payments & Settlement

| # | Feature | Mat. | Tranche | md | $@270 | Evidence / rationale |
|---|---------|:----:|:-------:|---:|------:|----------------------|
| 9.0 | Offline payment tracking (status vs invoice) | 🔴 | MVP | 8 | 2,160 | bank details on invoice only |
| 9.2 | Brand collection (GoCardless DD) + auto mark-paid | 🔴 | P2 | 8 | 2,160 | none |
| 9.4 | Candidate payout rail | 🔴 | P2 | 6 | 1,620 | none |
| 9.5 | Reconciliation | 🔴 | P2 | 6 | 1,620 | none |
| 9.6 | Dunning / late-fee automation | 🔴 | P2 | 4 | 1,080 | none |
| 9.7/9.8 | Refunds / write-off / client-money | 🔴 | P2 | (incl.) | — | folded into above / advisory |
| | **P9 subtotal** | | | **32** | **8,640** | MVP 8 / P2 24 |

## P10 — Notifications & Comms

| # | Feature | Mat. | Tranche | md | $@270 | Evidence / rationale |
|---|---------|:----:|:-------:|---:|------:|----------------------|
| 10.1 | Transactional email (all key events) | 🔴 | MVP | 6 | 1,620 | none visible |
| 10.2 | SMS (time-critical) | 🔴 | MVP | 3 | 810 | none |
| 10.3 | In-app notification centre | 🔴 | P2 | 6 | 1,620 | none |
| 10.4 | Templates + per-tenant branding | 🔴 | P2 | 4 | 1,080 | depends P12 |
| 10.5 | Preferences / unsubscribe | 🔴 | P2 | 3 | 810 | none |
| 10.6 | Reminder scheduler | 🔴 | MVP | 3 | 810 | none |
| 10.7 | Delivery log / retry | 🔴 | MVP | 2 | 540 | none |
| | **P10 subtotal** | | | **27** | **7,290** | MVP 14 / P2 13 |

## P11 — Documents, Contracts & E-sign

| # | Feature | Mat. | Tranche | md | $@270 | Evidence / rationale |
|---|---------|:----:|:-------:|---:|------:|----------------------|
| 11.1 | Contract templates (merge tokens) | 🟡 | MVP | 3 | 810 | rich-text templates exist (System) |
| 11.2 | Contract generation (template→PDF) | 🔴 | MVP | 6 | 1,620 | no generation action (blackbox t4) |
| 11.3 | E-signature | 🔴 | P2 | 8 | 2,160 | none |
| 11.4 | Document store (versioned, access-controlled) | 🟡 | MVP | 6 | 1,620 | attach fields exist; centralize |
| 11.5 | Versioning / re-issue | 🔴 | P2 | 3 | 810 | none |
| 11.6 | Secure download (signed URLs) | 🔴 | MVP | 2 | 540 | none |
| 11.7 | Virus scan on upload | 🔴 | MVP | 2 | 540 | none |
| | **P11 subtotal** | | | **30** | **8,100** | MVP 19 / P2 11 |

## P12 — Multi-Tenancy & White-Label

| # | Feature | Mat. | Tranche | md | $@270 | Evidence / rationale |
|---|---------|:----:|:-------:|---:|------:|----------------------|
| 12.1 | Tenancy package + tenant model | 🔴 | MVP | 6 | 1,620 | single deploy today |
| 12.2 | Data isolation across all models | 🔴 | MVP | 8 | 2,160 | touches every entity |
| 12.3 | Per-tenant branding / theming | 🔴 | MVP | 6 | 1,620 | white-label for Tidal |
| 12.4 | Per-tenant config (migrate System) | 🔴 | MVP | 5 | 1,350 | System is global today |
| 12.5 | Currency / locale (i18n) | 🔴 | P2 | 4 | 1,080 | GBP only |
| 12.6 | Tenant-aware auth / routing | 🔴 | MVP | 4 | 1,080 | depends P1 |
| 12.7 | Cross-tenant super-admin | 🔴 | P2 | 3 | 810 | single admin scope |
| 12.8 | Tenant provisioning (spin up Yedi) | 🔴 | P2 | 3 | 810 | none |
| | **P12 subtotal** | | | **39** | **10,530** | MVP 29 / P2 10 |

## P13 — Reporting & Analytics

| # | Feature | Mat. | Tranche | md | $@270 | Evidence / rationale |
|---|---------|:----:|:-------:|---:|------:|----------------------|
| 13.1 | Admin count widgets (wire to live) | 🟡 | MVP | 2 | 540 | widgets exist |
| 13.2 | Financial widgets (real figures) | 🟡 | MVP | 3 | 810 | exist, all £0 |
| 13.3 | Date filters / drill-down | 🔴 | P2 | 4 | 1,080 | none |
| 13.4 | Ops KPIs (fill rate, time-to-fill) | 🔴 | P2 | 4 | 1,080 | none |
| 13.5 | Compliance reporting | 🔴 | P2 | 3 | 810 | depends P6 |
| 13.6 | Brand analytics | 🔴 | P2 | 3 | 810 | in P2 portal |
| 13.7 | Candidate earnings | 🔴 | MVP | 2 | 540 | simple |
| 13.8 | Exports / scheduled | 🔴 | P2 | 4 | 1,080 | none |
| | **P13 subtotal** | | | **25** | **6,750** | MVP 7 / P2 18 |

## P14 — Non-Functional (security/GDPR/QA/CI-CD)

| # | Feature | Mat. | Tranche | md | $@270 | Evidence / rationale |
|---|---------|:----:|:-------:|---:|------:|----------------------|
| 14.1 | Authorization policies (every resource) | 🔴 | MVP | 8 | 2,160 | unknown/none from outside |
| 14.2 | OWASP hardening | 🔴 | MVP | 6 | 1,620 | review + fixes |
| 14.3 | Secure file upload + AV | 🔴 | MVP | 3 | 810 | (upload bug seen in t2) |
| 14.4 | UK GDPR (retention/erasure/SAR/consent) | 🔴 | MVP | 8 | 2,160 | holds PII + RTW docs |
| 14.5 | PII encryption at rest | 🔴 | MVP | 4 | 1,080 | sensitive fields |
| 14.6 | Automated tests (money + compliance focus) | 🔴 | MVP | 12 | 3,240 | none known |
| 14.7 | CI/CD + staging/prod envs | 🔴 | MVP | 8 | 2,160 | none known |
| 14.8 | Backups / DR | 🔴 | MVP | 3 | 810 | none known |
| 14.9 | Monitoring / alerting + queues | 🔴 | MVP | 4 | 1,080 | none known |
| 14.10 | Performance pass (N+1, caching) | 🔴 | P2 | 5 | 1,350 | post-launch |
| 14.11 | Audit logging (sensitive actions) | 🔴 | MVP | 3 | 810 | none |
| 14.x | GDPR-advanced + extended tests | 🔴 | P2 | 4 | 1,080 | hardening tail |
| | **P14 subtotal** | | | **68** | **18,360** | MVP 59 / P2 9 |

---

## Roll-up

| | Dev md | MVP md | P2 md |
|---|---:|---:|---:|
| P1 Auth | 36 | 27 | 9 |
| P2 Brand portal | 56 | 48 | 8 |
| P3 Candidate portal | 67 | 59 | 8 |
| P4 Adverts | 41 | 26 | 15 |
| P5 Core loop | 59 | 52 | 7 |
| P6 Compliance | 48 | 41 | 7 |
| P7 Timesheets | 35 | 27 | 8 |
| P8 Billing | 55 | 46 | 9 |
| P9 Payments | 32 | 8 | 24 |
| P10 Notifications | 27 | 14 | 13 |
| P11 Docs/contracts | 30 | 19 | 11 |
| P12 Multi-tenancy | 39 | 29 | 10 |
| P13 Reporting | 25 | 7 | 18 |
| P14 Non-functional | 68 | 59 | 9 |
| **Dev subtotal** | **618** | **462** | **156** |

### Overlays (added once)

| Item | md |
|------|---:|
| Discovery + source-code audit | 10 |
| UI/UX design + design system | 25 |
| Foundation (API layer, project/env scaffolding, CI baseline) | 15 |
| **Overlay subtotal** | **50** |

### Totals

| | Dev | +Overlay | +PM 12% | +Contingency 15% | **Total md** |
|---|---:|---:|---:|---:|---:|
| **MVP (Tidal launch)** | 462 | 512 | ~573 | ~660 | **~660** |
| **Full production-grade** | 618 | 668 | ~748 | ~860 | **~860** |

> Contingency 15% (vs usual 12%) because source code is unseen — see swing factors in `tidal-yedi-estimate-from-feature-gap.md`.

## Cost (indicative, $240–300/md)

| Scope | md | @ $240 | @ $300 | Midpoint @270 | GBP (~0.79) |
|-------|---:|-------:|-------:|--------------:|-------------|
| **MVP launch (Tidal)** | ~660 | $158k | $198k | ~$178k | ~£125k–£156k |
| Enhancement (P2 = Full−MVP) | ~200 | $48k | $60k | ~$54k | ~£38k–£47k |
| **Full production-grade** | ~860 | $206k | $258k | ~$232k | ~£163k–£204k |

## Notes

- Per-feature $ uses the **$270 midpoint** for traceability; the headline range uses $240–300.
- ✅ features (1.1, 4.2, 8.1, 8.2) cost 0 — already built, counted as reuse savings.
- Lines marked "depends Pn" carry their *own-side* effort only (e.g. 2.8 = brand approval UI; the
  timesheet engine itself is 7.x) — no double counting.
- This WBS is the evidence behind the proposal's tranche prices; swap the day-rate to reprice any line.
