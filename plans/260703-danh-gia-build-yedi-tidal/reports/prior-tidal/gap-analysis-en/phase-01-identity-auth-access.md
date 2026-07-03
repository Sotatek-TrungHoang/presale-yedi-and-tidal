---
phase: 1
title: "Identity-Auth-Access"
status: pending
priority: P1
effort: "35d (MVP 26d)"
dependencies: []
---

# Phase 1: Identity, Auth & Access

## Overview
Who can log in, how, and what they can do. Admin auth works; Brand & Candidate
**accounts exist in data but have no front door**; account-security hygiene (reset,
verify, 2FA, lockout) and granular RBAC are absent.

## Current State (verified)
- ✅ **Admin login** — Filament `/admin/login`, email+password, "remember me", show/hide password. Works.
- 🔴 **Admin users have NO RBAC** *(corrected by black-box)* — `Users` create/edit form is only Title, Email, first/last name, Password. There is **no role/permission field**; the earlier "role selector" was a misread of the **Title** dropdown (Mr/Mrs…). The list "Type" column is a *derived* value. (evidence: `evidences/blackbox/t4-user-roles.png`)
- 🟡 **Identity likely polymorphic** — the derived "Type" (Admin/applicant/advertiser) suggests separate user tables/subtypes, not one users table. Confirm via source — it decides multi-guard design.
- 🟡 **Brand accounts** — Brand create form includes a Contact block (first/last/email/phone/DOB/**password**) → brand has an associated login identity. (evidence: `advertisers/create`)
- 🟡 **Candidate accounts** — Candidate create includes first/last/email/phone/DOB/**password** → candidate login identity exists. (evidence: `applicants/create`)
- 🔴 No brand/candidate **login surface** (accounts created but nowhere to authenticate).
- 🔴 No password reset / email verification / 2FA / lockout / session policy visible.

## Production-Grade Target
- Three distinct auth contexts: Admin (Filament), Brand portal, Candidate portal — separate guards.
- Self-service: registration (where allowed), email verification, password reset, change password.
- Account security: rate-limit/lockout, optional 2FA, session expiry, "logged-in devices".
- RBAC: admin roles (super-admin, ops, finance, compliance), brand multi-user (owner vs staff),
  candidate single-user. Scoped permissions per resource/action.
- Audit log of auth events (login, role change, impersonation).
- Admin **impersonation** of brand/candidate for support.

## Feature Gap Matrix
| # | Feature | Current | Target | Gap |
|---|---------|---------|--------|-----|
| 1.1 | Admin login | ✅ | ✅ | — |
| 1.2 | Admin roles/permissions | 🔴 no RBAC (corrected) | Granular RBAC (ops/finance/compliance) | Full permission model + policies + UI |
| 1.3 | Brand login portal | 🔴 (account exists) | Dedicated guard + login UI | Auth guard, login/logout, middleware |
| 1.4 | Candidate login portal | 🔴 (account exists) | Dedicated guard + login UI | Auth guard, login/logout, middleware |
| 1.5 | Registration / invite | 🔴 | Brand invite + candidate self-register | Flows, tokens, gating |
| 1.6 | Email verification | 🔴 | Required pre-activation | Verification pipeline |
| 1.7 | Password reset | 🔴 | Self-service reset | Reset tokens + emails |
| 1.8 | 2FA / MFA | 🔴 | Optional TOTP (admin/finance) | TOTP integration |
| 1.9 | Lockout / rate limit | 🔴 unknown | Brute-force protection | Throttle + lockout |
| 1.10 | Brand multi-user | 🔴 | Owner + staff seats per brand | Membership model |
| 1.11 | Admin impersonation | 🔴 | Support login-as | Impersonation + audit |
| 1.12 | Auth audit log | 🔴 | Full auth event trail | Event logging |

## Build Scope (the gap)
- Multi-guard auth (admin / brand / candidate) on shared user identity or polymorphic users.
- Permission layer (e.g. spatie/laravel-permission) + Filament policy wiring.
- Account lifecycle: invite/register → verify → reset → 2FA → lockout.
- Brand membership (multi-seat) model.
- Impersonation + auth audit trail.

## Risk Assessment
- **Identity model shape unknown** without source — are Brand/Candidate `User` subtypes, polymorphic,
  or separate tables with password columns? This decides guard design. Confirm via repo.
- Mixing three guards on one table is error-prone; get the model right before portal work (P2/P3).
