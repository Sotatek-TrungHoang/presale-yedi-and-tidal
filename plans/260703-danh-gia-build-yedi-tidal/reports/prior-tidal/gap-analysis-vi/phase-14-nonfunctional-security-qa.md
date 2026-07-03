---
phase: 14
title: "NonFunctional-Security-QA"
status: pending
priority: P1
effort: "66d (MVP 48d)"
dependencies: []
---

# Phase 14: Non-Functional — Security, GDPR, QA, CI/CD, Performance

## Overview
Tính sẵn sàng production mang tính cross-cutting. Một staffing platform giữ **PII nhạy cảm** (DOB, address,
right-to-work docs, bank details) và **money flows** — nên security, data protection, testing,
và ops không phải tùy chọn. Hiện trạng nhìn từ bên ngoài **phần lớn chưa rõ/chưa có**.

## Current State (verified)
- ✅ Đang dùng HTTPS; Filament admin auth đã có.
- ❓ Mọi thứ còn lại không verify được từ bên ngoài: test coverage, CI/CD, backups, monitoring, secrets mgmt,
  authorization policies, độ sâu input validation, rate limiting, GDPR tooling. Giả định **chưa đạt production-grade** cho tới khi source chứng minh ngược lại.
- 🔴 Không thấy: automated tests, audit logging, data-retention/erasure (GDPR), backup/DR, monitoring/alerting.

## Production-Grade Target
- **Security**: authorization policies trên mọi resource/action; OWASP top-10 hardening; rate limiting;
  secure file upload (type/size/AV); secrets management; dependency scanning; pen-test trước launch.
- **Data protection (UK GDPR)**: lawful basis, consent records, data-retention policy, right-to-erasure,
  data export (SAR), PII encryption at rest cho các field nhạy cảm, access logging.
- **QA**: automated tests (unit + feature + critical e2e), đặc biệt money paths (P5/P7/P8) và compliance gates (P6);
  test data seeding; regression suite.
- **CI/CD**: pipeline (lint, test, build, deploy), multi-env (dev/staging/prod), zero-downtime deploys, migrations gating.
- **Ops**: backups + restore drills, monitoring/alerting (errors, queues, uptime), log aggregation, queue workers + Horizon.
- **Performance**: review pagination/index, N+1 audits, queue offloading cho PDF/email, caching.

## Feature Gap Matrix
| # | Area | Current | Target | Gap |
|---|------|---------|--------|-----|
| 14.1 | Authorization policies | ❓ | Mọi action được gate | Audit + policies |
| 14.2 | OWASP hardening | ❓ | Hardened + pen-tested | Review + fixes + pen-test |
| 14.3 | Secure file upload | 🔴 | Type/size/AV scan | Validation + AV |
| 14.4 | GDPR tooling | 🔴 | Retention/erasure/SAR/consent | Data-protection features |
| 14.5 | PII encryption at rest | ❓ | Field nhạy cảm được encrypt | Field encryption |
| 14.6 | Automated tests | 🔴 unknown | Coverage trên money/compliance | Test suite |
| 14.7 | CI/CD + envs | 🔴 unknown | Pipeline + staging/prod | CI/CD + infra |
| 14.8 | Backups / DR | 🔴 unknown | Tự động + test restore | Backup strategy |
| 14.9 | Monitoring / alerting | 🔴 unknown | Errors/uptime/queues | Observability stack |
| 14.10 | Performance / queues | ❓ | Queue PDF/email, không N+1 | Queue + perf pass |
| 14.11 | Audit logging | 🔴 | Trail cho sensitive-action | Audit log |

## Build Scope (the gap)
- Security audit + phủ authorization policy; OWASP hardening; secure uploads.
- Các feature UK GDPR (retention, erasure, SAR export, consent, PII encryption).
- Test suite tập trung vào tính đúng đắn của money + compliance; CI/CD + staging/prod; backups, monitoring, queues.

## Risk Assessment
- **Ẩn số lớn nhất trong toàn bộ phân tích** — không cái nào quan sát được nếu không có repo. Có thể
  đã có một phần (Laravel cho sẵn vài thứ) hoặc hoàn toàn chưa có. **Bắt buộc source audit** để ước lượng.
- Không thể cắt bỏ với một platform giữ right-to-work docs + bank details; cắt nó là liability, không phải tiết kiệm.
