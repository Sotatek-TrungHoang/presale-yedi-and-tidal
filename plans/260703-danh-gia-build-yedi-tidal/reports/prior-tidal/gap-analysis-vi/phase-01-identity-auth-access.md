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
Ai được phép login, login bằng cách nào, và làm được những gì. Admin auth đã chạy; Brand & Candidate
**accounts tồn tại trong data nhưng không có cửa vào nào** (no front door); các phần account-security hygiene (reset,
verify, 2FA, lockout) và granular RBAC đều thiếu.

## Current State (verified)
- ✅ **Admin login** — Filament `/admin/login`, email+password, "remember me", show/hide password. Hoạt động OK.
- 🔴 **Admin users KHÔNG có RBAC** *(đã chỉnh theo black-box)* — form create/edit `Users` chỉ gồm Title, Email, first/last name, Password. **Không có field role/permission**; cái "role selector" trước đây là đọc nhầm dropdown **Title** (Mr/Mrs…). Cột "Type" trong list là giá trị *derived* (suy ra). (evidence: `evidences/blackbox/t4-user-roles.png`)
- 🟡 **Identity nhiều khả năng polymorphic** — "Type" derived (Admin/applicant/advertiser) gợi ý có các user table/subtype riêng, không phải một users table duy nhất. Confirm qua source — điều này quyết định thiết kế multi-guard.
- 🟡 **Brand accounts** — form tạo Brand có Contact block (first/last/email/phone/DOB/**password**) → brand có một login identity đi kèm. (evidence: `advertisers/create`)
- 🟡 **Candidate accounts** — form tạo Candidate có first/last/email/phone/DOB/**password** → candidate login identity tồn tại. (evidence: `applicants/create`)
- 🔴 Không có **login surface** cho brand/candidate (account được tạo nhưng không có chỗ nào để authenticate).
- 🔴 Không thấy password reset / email verification / 2FA / lockout / session policy.

## Production-Grade Target
- Ba auth context riêng biệt: Admin (Filament), Brand portal, Candidate portal — separate guards.
- Self-service: registration (nơi nào cho phép), email verification, password reset, change password.
- Account security: rate-limit/lockout, optional 2FA, session expiry, "logged-in devices".
- RBAC: admin roles (super-admin, ops, finance, compliance), brand multi-user (owner vs staff),
  candidate single-user. Scoped permissions theo từng resource/action.
- Audit log các auth event (login, role change, impersonation).
- Admin **impersonation** brand/candidate để support.

## Feature Gap Matrix
| # | Feature | Current | Target | Gap |
|---|---------|---------|--------|-----|
| 1.1 | Admin login | ✅ | ✅ | — |
| 1.2 | Admin roles/permissions | 🔴 no RBAC (đã chỉnh) | Granular RBAC (ops/finance/compliance) | Full permission model + policies + UI |
| 1.3 | Brand login portal | 🔴 (account đã có) | Dedicated guard + login UI | Auth guard, login/logout, middleware |
| 1.4 | Candidate login portal | 🔴 (account đã có) | Dedicated guard + login UI | Auth guard, login/logout, middleware |
| 1.5 | Registration / invite | 🔴 | Brand invite + candidate self-register | Flows, tokens, gating |
| 1.6 | Email verification | 🔴 | Bắt buộc trước khi activate | Verification pipeline |
| 1.7 | Password reset | 🔴 | Self-service reset | Reset tokens + emails |
| 1.8 | 2FA / MFA | 🔴 | Optional TOTP (admin/finance) | TOTP integration |
| 1.9 | Lockout / rate limit | 🔴 unknown | Brute-force protection | Throttle + lockout |
| 1.10 | Brand multi-user | 🔴 | Owner + staff seats mỗi brand | Membership model |
| 1.11 | Admin impersonation | 🔴 | Support login-as | Impersonation + audit |
| 1.12 | Auth audit log | 🔴 | Full auth event trail | Event logging |

## Build Scope (the gap)
- Multi-guard auth (admin / brand / candidate) trên shared user identity hoặc polymorphic users.
- Permission layer (vd spatie/laravel-permission) + Filament policy wiring.
- Account lifecycle: invite/register → verify → reset → 2FA → lockout.
- Brand membership (multi-seat) model.
- Impersonation + auth audit trail.

## Risk Assessment
- **Hình dạng identity model chưa rõ** nếu không xem source — Brand/Candidate là `User` subtypes, polymorphic,
  hay các table riêng có password column? Điều này quyết định guard design. Confirm qua repo.
- Trộn ba guard trên một table dễ sai; làm cho đúng model trước khi build portal (P2/P3).
