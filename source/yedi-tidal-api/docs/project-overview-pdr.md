# Project Overview & Product Development Requirements

**Last updated:** 2026-07-08  
**Status:** Reverse-engineered PDR from codebase (v1/v2 feature-complete implementation)

## Project Summary

**Yedi/Tidal** is a white-label two-sided staffing marketplace connecting Advertisers (Yedi: Schools; Tidal: Brands) with Applicants (Yedi: Teachers; Tidal: Candidates) for shift-based work assignments. The platform enforces strict compliance gating on applicants, generates financial documents (contracts, invoices, payslips) via external services, and handles marketplace operations including applications, allocations, and ratings.

Single Laravel 11 codebase serves both brands by switching terminology and styling via `APP_CONFIGURATION` environment variable.

## Core Actors & User Journeys

### 1. Admin (Internal)
- **Access:** Filament 3 panel (`/admin`, authenticated)
- **Responsibilities:**
  - Review and approve advertiser and applicant compliance
  - Approve/reject adverts before public listing
  - Manage compliance templates (declarations, required evidence, reference forms)
  - Monitor system health (Horizon queue monitoring)
  - Edit platform settings (charge percentages, invoice/payslip config)

### 2. Advertiser (Yedi: School; Tidal: Brand)
- **Onboarding Journey:**
  1. Create account (email, password)
  2. Create profile (name, address, photo)
  3. Submit address for geocoding
  4. Upload company photograph
  5. Sign compliance agreement → receive contract PDF
  6. Admin approval → profile Active → can post adverts
  
- **Core Actions:**
  - Post Adverts: specify shift date range, times, pay rate, applicant charge %, whether day-to-day or long-term
  - View Applications: see interested applicants (filtered by compliance status)
  - Accept/Decline: select winner or reject all
  - Rate Applicants: score accepted applicant post-completion
  - Receive Invoices: auto-generated PDFs showing shift hours × pay + Yedi charge deduction
  - Heart Applicants: build candidate favorites list
  - View Contracts, Invoices: download PDFs

### 3. Applicant (Yedi: Teacher; Tidal: Candidate)
- **Onboarding Journey (Compliance Gating):**
  1. Create account (email, password)
  2. Upload photo, evidence of ID, video verification (6-digit code spoken on camera)
  3. Submit address
  4. Declare qualifications (GCSE, A-Level, Degree, etc.; teachers: teacher number if required)
  5. Provide References: min. 2 referees (platform sends external form links)
  6. Complete Required Evidence: submit documents per platform requirements
  7. Agree to Declarations: check boxes on compliance statements
  8. Right-to-Work Declaration: confirm UK work eligibility + visa/criminal history
  9. Sign compliance agreement → receive contract PDF
  10. Admin approval → profile Compliant → can apply to adverts
  
- **Core Actions:**
  - Browse Approved Adverts: filter by date/location (only see Approved adverts from Compliant advertisers)
  - Apply: submit application (status Pending)
  - Cancel Application: withdraw if still pending
  - View Bookings: see accepted and applied-to adverts
  - Receive Payslips: auto-generated PDFs showing hours worked × applicant pay rate
  - View Contracts, Payslips: download PDFs

## Platform Features

### Advert Lifecycle (State Machine)

```
PendingApproval → Approved → PendingAllocation → Filled → Completed
                 ↓
               Rejected

or (no applicants) → NotFilled
```

- **PendingApproval:** Admin review pending
- **Approved:** Open for applicant applications (Yedi/Tidal mode affects auto-closing: day-to-day closes after X minutes; long-term closes at apply_by date)
- **PendingAllocation:** Applications closed; advertiser selects winner
- **Filled:** Winner selected; shift can proceed
- **NotFilled:** No qualified applicants or advertiser deadline passed without selection
- **Completed:** Shift end date passed; invoice + payslip auto-generated

### Application Lifecycle

```
Pending → Accepted  or  Declined  or  Cancelled
```

- **Pending:** Fresh application or revived from cancellation
- **Accepted:** Advertiser selected this applicant; all other pending applications auto-decline
- **Declined:** Advertiser or system rejection
- **Cancelled:** Applicant withdrew

### Compliance Statuses

**Advertiser:**
- Pending (default post-signup)
- Compliant (admin approved)
- NonCompliant (admin rejected; cannot post)

**Applicant:**
- Incomplete (signup not finished)
- PendingApproval (all steps done; awaiting admin review)
- Compliant (admin approved; can apply)
- NonCompliant (admin rejected; cannot apply)

### Document Generation

- **Contracts:** Rendered from Settings templates with advertiser/applicant name substitution; generated at signup completion
- **Invoices:** Per Filled+Completed advert; line items per shift; includes subtotal, 20% VAT, total; due date and late-charge from Settings; notifies advertiser
- **Payslips:** Per Filled+Completed advert for accepted applicant; notifies applicant
- Delivery via signed URLs; stored in S3 (production) or local storage (dev)

### Financial Model

**Advertiser pays → Yedi platform charge → Applicant receives**

Example (hourly, 1 shift, 8 hours):
- Advertiser pay rate: £100/hour
- Advertiser charge %: 10%
- Applicant charge %: 15%
- Shifts: 1 × 8 hours = 8 hours
- Total advertiser cost: £100/hr × 8 = £800
- Yedi advertiser charge: £800 × 10% = £80
- Yedi applicant charge: (£800 − £80) × 15% = £108
- Applicant net: £800 − £80 − £108 = £612
- Yedi profit: £80 + £108 = £188

Currency: GBP (hard-coded); money stored as JSON via Brick Money library.

### Compliance References

- Advertiser can request external referees fill forms
- Referee receives signed URL to reference form (public, no auth)
- Form submission generates PDF attached to Reference; notifies admin
- Admin confirms/rejects reference in Filament

### Notifications

- **Push:** Firebase FCM for application accepted/declined, new application received
- **Email:** Mailgun for account activation, new application, new invoice/payslip, reference requests
- **In-Filament:** Audit trails for all model changes (Owen-It auditing)

## Non-Functional Requirements

- **Scalability:** Redis queues for document generation (contracts, invoices, payslips); Horizon manages workers
- **Security:** Sanctum API tokens; signed URLs for file downloads; polymorphic authorization (Applicant/Advertiser/Admin gates)
- **Compliance:** Audit log of all model changes; GDPR account deletion support
- **Multi-tenancy:** White-label via environment config (no per-customer isolation; single brand per deployment)
- **Observability:** Sentry error tracking; Pail logs in development

## Known Gaps & Future Work

See [project-roadmap.md](./project-roadmap.md) for current implementation status and missing features.
