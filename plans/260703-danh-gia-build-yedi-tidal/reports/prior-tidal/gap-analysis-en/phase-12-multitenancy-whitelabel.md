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
"Same platform, separate markets" (Tidal UK + Yedi). Production needs one codebase serving
both brands with isolated data + per-market branding/config. **No tenancy layer is present.**

## Current State (verified)
- 🔴 Single Tidal deployment; sidebar brand fixed to "Tidal"; no tenant switch.
- 🟡 System settings (charge %, invoice bank/contact, contracts) are **single-set/global** — would need to become per-tenant.
- ❓ Yedi instance not accessible (URL/login not provided); cannot confirm whether it's a code fork, a separate deploy, or planned.

## Production-Grade Target
- **Single multi-tenant codebase** (confirmed preferred approach): tenant = market (Tidal, Yedi, future).
- **Data isolation** per tenant (row-level tenant_id scoping or DB-per-tenant) across every entity.
- **Per-tenant config**: branding (logo/colors/domain), currency, locale, charge % defaults, invoice
  bank/contact, contract templates, compliance rules, email/SMS templates.
- Tenant-aware auth (a candidate/brand belongs to a tenant), routing (domain/subdomain per market).
- Admin: super-admin across tenants + per-tenant operators.
- Tenant onboarding/provisioning.

## Feature Gap Matrix
| # | Feature | Current | Target | Gap |
|---|---------|---------|--------|-----|
| 12.1 | Tenant model | 🔴 | Tenant = market | Tenancy package + model |
| 12.2 | Data isolation | 🔴 | Scoped every query | Global scopes / DB-per-tenant |
| 12.3 | Per-tenant branding | 🔴 | Logo/colors/domain | Theming + domain routing |
| 12.4 | Per-tenant config | 🟡 global settings | Settings per tenant | Migrate System → tenant-scoped |
| 12.5 | Currency/locale | 🟡 GBP only | Per-market | i18n + currency |
| 12.6 | Tenant-aware auth/routing | 🔴 | Domain → tenant | Middleware |
| 12.7 | Cross-tenant super-admin | 🟡 single admin | Multi-tenant admin | Role + scoping |
| 12.8 | Tenant provisioning | 🔴 | Spin up new market | Provisioning flow |

## Build Scope (the gap)
- Introduce tenancy (e.g. stancl/tenancy or spatie/laravel-multitenancy) — **decide early**, it touches every model.
- Migrate global System settings to per-tenant configuration.
- Per-tenant theming + domain/subdomain routing; currency/locale.
- Tenant-aware guards across admin/brand/candidate (P1).

## Risk Assessment
- **Cheapest if decided before P2/P3 portal + P1 auth work** — retrofitting tenancy after building
  single-tenant portals is expensive rework. This is a foundational architectural decision.
- Yedi specifics unverified → confirm whether Yedi already diverged in code (would force a reconciliation/merge step).
