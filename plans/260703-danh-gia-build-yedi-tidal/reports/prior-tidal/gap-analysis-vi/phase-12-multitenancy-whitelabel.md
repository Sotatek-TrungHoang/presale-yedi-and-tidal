---
phase: 12
title: "MultiTenancy-WhiteLabel"
status: pending
priority: P2
effort: "39d (MVP 25d)"
dependencies: []
---

# Phase 12: Multi-Tenancy & White-Label (Tidal + Yedi)

## Overview
"Cùng một platform, tách biệt các thị trường" (Tidal UK + Yedi). Production cần một codebase duy nhất phục vụ
cả hai brand với data tách biệt + branding/config theo từng market. **Chưa có tenancy layer nào.**

## Current State (verified)
- 🔴 Chỉ có một Tidal deployment; brand ở sidebar cố định là "Tidal"; không có tenant switch.
- 🟡 System settings (charge %, invoice bank/contact, contracts) hiện là **single-set/global** — cần chuyển thành per-tenant.
- ❓ Không truy cập được Yedi instance (chưa cung cấp URL/login); không xác nhận được đây là code fork, một deploy riêng, hay mới ở dạng kế hoạch.

## Production-Grade Target
- **Một codebase multi-tenant duy nhất** (đã xác nhận là approach ưu tiên): tenant = market (Tidal, Yedi, tương lai).
- **Data isolation** theo từng tenant (row-level tenant_id scoping hoặc DB-per-tenant) trên mọi entity.
- **Config per-tenant**: branding (logo/colors/domain), currency, locale, charge % defaults, invoice
  bank/contact, contract templates, compliance rules, email/SMS templates.
- Auth tenant-aware (một candidate/brand thuộc về một tenant), routing (domain/subdomain theo từng market).
- Admin: super-admin xuyên tenant + operator theo từng tenant.
- Tenant onboarding/provisioning.

## Feature Gap Matrix
| # | Feature | Current | Target | Gap |
|---|---------|---------|--------|-----|
| 12.1 | Tenant model | 🔴 | Tenant = market | Tenancy package + model |
| 12.2 | Data isolation | 🔴 | Scope mọi query | Global scopes / DB-per-tenant |
| 12.3 | Per-tenant branding | 🔴 | Logo/colors/domain | Theming + domain routing |
| 12.4 | Per-tenant config | 🟡 global settings | Settings per tenant | Migrate System → tenant-scoped |
| 12.5 | Currency/locale | 🟡 GBP only | Per-market | i18n + currency |
| 12.6 | Tenant-aware auth/routing | 🔴 | Domain → tenant | Middleware |
| 12.7 | Cross-tenant super-admin | 🟡 single admin | Multi-tenant admin | Role + scoping |
| 12.8 | Tenant provisioning | 🔴 | Mở market mới | Provisioning flow |

## Build Scope (the gap)
- Đưa tenancy vào (vd stancl/tenancy hoặc spatie/laravel-multitenancy) — **quyết định sớm**, vì nó chạm tới mọi model.
- Migrate global System settings sang configuration per-tenant.
- Theming per-tenant + domain/subdomain routing; currency/locale.
- Guards tenant-aware xuyên admin/brand/candidate (P1).

## Risk Assessment
- **Rẻ nhất nếu quyết định trước khi làm portal P2/P3 + auth P1** — retrofit tenancy sau khi đã build
  các portal single-tenant là rework tốn kém. Đây là quyết định kiến trúc nền tảng.
- Chi tiết Yedi chưa verify → xác nhận xem Yedi đã diverge trong code chưa (sẽ buộc phải có bước reconciliation/merge).
