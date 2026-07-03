---
phase: 11
title: "Documents-Contracts-Esign"
status: pending
priority: P2
effort: "27d (MVP 15d)"
dependencies: [5]
---

# Phase 11: Documents, Contracts & E-signature

## Tổng quan
Generate và capture các signed agreement (candidate contract, advertiser contract) và quản lý
các file đã upload. **Templates đã có; generation, signing, và lifecycle thì chưa.**

## Hiện trạng (verified)
- ✅ System giữ rich-text templates **Applicant contract** + **Advertiser contract** ("Tidal Contract"). (evidence: `system` page)
- 🟡 Advert + Candidate forms gồm các **Documents** repeaters/sections → file attachment đã được modeled.
- 🔴 Không có contract **generation** từ template (merge candidate/brand/booking data), không **e-signature**,
  không signed-document storage/versioning, không expiry/renewal.

## Mục tiêu Production-Grade
- **Contract generation**: merge template + party/booking data → PDF, khi candidate activation / brand onboarding / per booking khi cần.
- **E-signature**: in-app signing hoặc provider (DocuSign/SignWell/native) với audit trail + timestamp.
- **Document store**: versioned, access-controlled, per-entity (candidate evidence, contracts, advert docs).
- Re-issue khi template thay đổi; track ai đã sign version nào, khi nào.
- Secure, expiring download links; virus scan khi upload.

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

## Build Scope (phần gap)
- Contract merge + PDF generation tái sử dụng các templates hiện có.
- E-signature capture (native hoặc provider) với audit trail.
- Centralized, access-controlled, versioned document store (dùng chung với P6 evidence + P8 invoices).

## Risk Assessment
- Trùng lặp với P6 (evidence storage) và P8 (invoice PDFs) — build **một** document/PDF subsystem, không phải ba.
- Yêu cầu về E-sign legal validity (UK) nên được confirm (audit trail, intent capture).
