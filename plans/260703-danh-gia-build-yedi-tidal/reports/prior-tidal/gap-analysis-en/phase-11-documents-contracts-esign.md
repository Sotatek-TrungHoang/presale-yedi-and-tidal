---
phase: 11
title: "Documents-Contracts-Esign"
status: pending
priority: P2
effort: "27d (MVP 15d)"
dependencies: [5]
---

# Phase 11: Documents, Contracts & E-signature

## Overview
Generate and capture signed agreements (candidate contract, advertiser contract) and manage
uploaded files. **Templates exist; generation, signing, and lifecycle do not.**

## Current State (verified)
- ✅ System holds **Applicant contract** + **Advertiser contract** rich-text templates ("Tidal Contract"). (evidence: `system` page)
- 🟡 Advert + Candidate forms include **Documents** repeaters/sections → file attachment is modeled.
- 🔴 No contract **generation** from template (merge candidate/brand/booking data), no **e-signature**,
  no signed-document storage/versioning, no expiry/renewal.

## Production-Grade Target
- **Contract generation**: merge template + party/booking data → PDF, on candidate activation / brand onboarding / per booking as required.
- **E-signature**: in-app signing or provider (DocuSign/SignWell/native) with audit trail + timestamp.
- **Document store**: versioned, access-controlled, per-entity (candidate evidence, contracts, advert docs).
- Re-issue on template change; track who signed what version when.
- Secure, expiring download links; virus scan on upload.

## Feature Gap Matrix
| # | Feature | Current | Target | Gap |
|---|---------|---------|--------|-----|
| 11.1 | Contract templates | ✅ rich-text | ✅ (+ merge fields) | Add merge tokens |
| 11.2 | Contract generation | 🔴 | Template→PDF with data | Generation engine |
| 11.3 | E-signature | 🔴 | Signed + audit trail | Signing flow/provider |
| 11.4 | Document storage | 🟡 attach fields | Versioned, access-controlled | Storage layer + policies |
| 11.5 | Versioning / re-issue | 🔴 | Track signed versions | Versioning |
| 11.6 | Secure download | 🔴 | Expiring signed URLs | Signed URL + scan |
| 11.7 | Virus scan on upload | 🔴 | Scan candidate uploads | AV integration |

## Build Scope (the gap)
- Contract merge + PDF generation reusing existing templates.
- E-signature capture (native or provider) with audit trail.
- Centralized, access-controlled, versioned document store (shared with P6 evidence + P8 invoices).

## Risk Assessment
- Overlaps P6 (evidence storage) and P8 (invoice PDFs) — build **one** document/PDF subsystem, not three.
- E-sign legal validity requirements (UK) should be confirmed (audit trail, intent capture).
