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
Cross-cutting production-readiness. A staffing platform holds **sensitive PII** (DOB, address,
right-to-work docs, bank details) and **money flows** — so security, data protection, testing,
and ops are not optional. Current posture is **largely unknown/absent** from the outside.

## Current State (verified)
- ✅ HTTPS in use; Filament admin auth present.
- ❓ Everything else unverifiable from outside: test coverage, CI/CD, backups, monitoring, secrets mgmt,
  authorization policies, input validation depth, rate limiting, GDPR tooling. Assume **not production-grade** until source proves otherwise.
- 🔴 No visible: automated tests, audit logging, data-retention/erasure (GDPR), backup/DR, monitoring/alerting.

## Production-Grade Target
- **Security**: authorization policies on every resource/action; OWASP top-10 hardening; rate limiting;
  secure file upload (type/size/AV); secrets management; dependency scanning; pen-test before launch.
- **Data protection (UK GDPR)**: lawful basis, consent records, data-retention policy, right-to-erasure,
  data export (SAR), PII encryption at rest for sensitive fields, access logging.
- **QA**: automated tests (unit + feature + critical e2e), especially money paths (P5/P7/P8) and compliance gates (P6);
  test data seeding; regression suite.
- **CI/CD**: pipeline (lint, test, build, deploy), multi-env (dev/staging/prod), zero-downtime deploys, migrations gating.
- **Ops**: backups + restore drills, monitoring/alerting (errors, queues, uptime), log aggregation, queue workers + horizon.
- **Performance**: pagination/index review, N+1 audits, queue offloading for PDF/email, caching.

## Feature Gap Matrix
| # | Area | Current | Target | Gap |
|---|------|---------|--------|-----|
| 14.1 | Authorization policies | ❓ | Every action gated | Audit + policies |
| 14.2 | OWASP hardening | ❓ | Hardened + pen-tested | Review + fixes + pen-test |
| 14.3 | Secure file upload | 🔴 | Type/size/AV scan | Validation + AV |
| 14.4 | GDPR tooling | 🔴 | Retention/erasure/SAR/consent | Data-protection features |
| 14.5 | PII encryption at rest | ❓ | Sensitive fields encrypted | Field encryption |
| 14.6 | Automated tests | 🔴 unknown | Coverage on money/compliance | Test suite |
| 14.7 | CI/CD + envs | 🔴 unknown | Pipeline + staging/prod | CI/CD + infra |
| 14.8 | Backups / DR | 🔴 unknown | Automated + tested restore | Backup strategy |
| 14.9 | Monitoring / alerting | 🔴 unknown | Errors/uptime/queues | Observability stack |
| 14.10 | Performance / queues | ❓ | Queued PDF/email, no N+1 | Queue + perf pass |
| 14.11 | Audit logging | 🔴 | Sensitive-action trail | Audit log |

## Build Scope (the gap)
- Security audit + authorization policy coverage; OWASP hardening; secure uploads.
- UK GDPR features (retention, erasure, SAR export, consent, PII encryption).
- Test suite focused on money + compliance correctness; CI/CD + staging/prod; backups, monitoring, queues.

## Risk Assessment
- **Biggest unknown across the whole analysis** — none of this is observable without the repo. Could be
  partly present (Laravel gives some for free) or entirely absent. **Source audit is required** to size it.
- Non-negotiable for a platform holding right-to-work docs + bank details; cutting it is a liability, not a saving.
