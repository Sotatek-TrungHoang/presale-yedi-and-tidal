# Project Roadmap & Implementation Status

**Last updated:** 2026-07-08  
**Status:** Feature-complete v1/v2 codebase (pre-production audit/presale context)

This document records what is implemented and known gaps. It is **not** a future business roadmap.

## Current Implementation Status

### Core Marketplace Features: COMPLETE
- ✅ Two-sided marketplace (Advertiser ↔ Applicant)
- ✅ Advert creation, approval, application, allocation
- ✅ White-label (Yedi/Tidal) brand switching
- ✅ Filament 3 admin panel for compliance review
- ✅ Sanctum API with audience-based routing (admin/advertiser/applicant)

### Applicant Onboarding (Compliance): COMPLETE
- ✅ Profile creation (photo, address, qualifications)
- ✅ Evidence of ID upload
- ✅ Video verification (6-digit code)
- ✅ Reference requests (external form submission)
- ✅ Right-to-work declaration
- ✅ Customizable compliance declarations + evidence requirements (via Filament)
- ✅ Admin approval workflow

### Advertiser Onboarding: COMPLETE
- ✅ Profile creation (company name, address, photo)
- ✅ Compliance gating
- ✅ Admin approval workflow

### Financial System: COMPLETE
- ✅ Pay rate configuration (hourly/daily)
- ✅ Charge percentages (advertiser, applicant)
- ✅ Automatic invoice generation (per filled advert)
- ✅ Automatic payslip generation (per accepted applicant)
- ✅ Brick Money for GBP handling
- ✅ PDF generation via DocGen service

### Notifications: COMPLETE
- ✅ Email notifications (Mailgun)
- ✅ Push notifications (Firebase FCM)
- ✅ Audience-aware templates

### Document Generation: COMPLETE
- ✅ Contracts (advertiser + applicant, from Settings templates)
- ✅ Invoices (line items, VAT, due date, late charge)
- ✅ Payslips
- ✅ Reference PDFs
- ✅ Signed URLs for secure file serving

### File Management: COMPLETE
- ✅ Upload handling with ownership validation
- ✅ Image conversion (multiple sizes, WebP)
- ✅ Expiry-based cleanup (5-min schedule)
- ✅ S3 support (production)

### Background Processing: COMPLETE
- ✅ Laravel Horizon (queue management)
- ✅ Queued jobs (documents, conversions, audits)
- ✅ Scheduled commands (advert lifecycle, cleanup)

### Admin Features: COMPLETE
- ✅ Advertiser/Applicant list with compliance tabs
- ✅ Advert approval workflow
- ✅ Application management (accept/decline)
- ✅ Settings management (charges, invoice terms, contract templates)
- ✅ Audit logs (Owen-It integration)
- ✅ Dashboard widgets (stats, money, charts — underscore-prefixed, disabled)

### Other Features: COMPLETE
- ✅ Email verification + password reset
- ✅ Email change workflow (6-digit verification)
- ✅ Account deletion (cascading, anonymization)
- ✅ Applicant ratings (post-completion)
- ✅ Advertiser favorites (heart applicants)
- ✅ Address geocoding (Google Maps)
- ✅ Sentry error tracking
- ✅ Device token management (FCM registration)

---

## Known Gaps & Issues

### Testing
- **Status:** Not started
- **Issue:** `tests/` directory exists; `phpunit.xml` configured; Unit + Feature suites mapped
- **Gap:** Zero test files written; no CI/CD testing integration
- **Scope:** Estimate ~200-300 tests for coverage (auth, handlers, policies, controllers)
- **Blocker:** Affects pre-release confidence; must be addressed before production deployment

### Missing Seeders
- **Status:** YediSeeder exists (idempotent, declarations + evidence)
- **Gap:** No TidalSeeder for Tidal-brand-specific seed data
- **Scope:** Tidal likely needs different declarations/evidence templates
- **Impact:** Low (YediSeeder works for both; admin can customize via Filament)

### Dead Code
- **routes/api.php** — Not registered (commented in `bootstrap/app.php`)
- **Applicant/ReferenceController@store** — Method exists but not wired to any route (applicant routes only expose `index` via apiResource)
- **Filament chart widgets** — `_AdvertiserComplianceChart.php`, `_AdvertiserStatusChart.php`, `_ApplicantsChart.php` underscore-prefixed (disabled from auto-discovery)
- **Scope:** Low impact; no functional issue; recommend cleanup in maintenance phase

### Configuration Issues
- **audit.php references undefined 'api' guard** — Config references `'guards' => ['api']` but `auth.php` only defines `web` guard (Sanctum handles API)
- **Impact:** Auditing still works (uses default guard); not blocking but worth fixing

### Unimplemented Features (Not Present in Code)
- ❌ Real-time messaging (no chat between advertiser/applicant)
- ❌ Rating/review system for advertisers (applicant can rate; advertiser cannot)
- ❌ Advanced search filters (location radius, pay range, etc.)
- ❌ Availability calendar (applicants cannot set preferred work times)
- ❌ Mobile app (API exists; no client app in this repo)
- ❌ Payment processing (no Stripe/Sepay integration; invoices generated but unpaid)
- ❌ Two-factor authentication
- ❌ API rate limiting (no throttling middleware)
- ❌ Webhook notifications (no outbound webhooks to external systems)

---

## Recommended Next Steps (Priority Order)

### High Priority
1. **Add Test Suite** (100-150h estimate)
   - Unit tests for Handlers, Services, Enums, Casts
   - Feature tests for all Controllers (auth, adverts, applications, compliance)
   - Policy tests (authorization gates)
   - Job tests (invoice, payslip, contract generation)
   - Fixtures/Factories for all models
   - CI integration (GitHub Actions or similar)

2. **Fix Configuration Gaps** (2-5h)
   - Remove `api` guard reference from `audit.php` or add guard definition
   - Delete unregistered `routes/api.php`
   - Uncomment/remove disabled Filament chart widgets
   - Wire `ReferenceController@store` or remove method
   - Add TidalSeeder (if Tidal-specific seed data needed)

3. **API Rate Limiting** (5-10h)
   - Add middleware throttle per endpoint/user
   - Prevent brute-force reference form submissions
   - Prevent bulk applicant scraping

### Medium Priority
4. **Payment Integration** (80-150h depending on provider)
   - Stripe webhook handling for invoice payments
   - Payslip direct payment (BACS, etc.)
   - Reconciliation system

5. **Real-time Messaging** (60-100h)
   - WebSocket chat (Pusher, Laravel Echo, or similar)
   - In-app notifications for urgent messages

6. **Availability & Advanced Search** (40-60h)
   - Applicant availability calendar
   - Advert filtering (location radius via geocoding, pay range, etc.)
   - Smart matching algorithm

### Low Priority
7. **Mobile App** (depends on platform; 200-400h for native iOS/Android)
   - Flutter or React Native client consuming this API

8. **Analytics & Reporting** (40-80h)
   - Admin dashboard charts (beyond current widgets)
   - Compliance metrics, payment reconciliation reports
   - Revenue/expense tracking

9. **Documentation & Training** (20-40h)
   - API documentation (Swagger/OpenAPI)
   - Admin user guide
   - Advertiser/Applicant onboarding guides

---

## Performance & Scalability Notes

### Current Bottlenecks
- **Single MySQL instance** — Schema has indexes on status fields; no sharding
- **Local file storage** — Works for dev; S3 required for production
- **Synchronous PDF generation** — Queued but single worker pool; may backlog under load
- **No caching layer** — Database queried per request; no Redis-backed HTTP cache

### Recommended Optimizations
- Database read replicas (queries vs writes separation)
- HTTP caching headers on frequently-read endpoints
- Computed attribute caching (already uses `->shouldCache()`)
- CDN for static assets + uploaded images
- Image conversion queueing tuned per load

---

## Release Readiness Checklist

Before production deployment:

- [ ] Comprehensive test suite written and passing (>80% coverage)
- [ ] All configuration gaps fixed (audit guard, dead code removed)
- [ ] Security audit completed (OWASP, rate limiting, input validation)
- [ ] Load testing performed (concurrent users, job throughput)
- [ ] Staging environment validated (same infra as production)
- [ ] Database backup/restore procedure documented
- [ ] Monitoring setup (Sentry, Horizon dashboard, logs)
- [ ] Runbooks written (deployment, incident response, scaling)
- [ ] API documentation complete (Swagger/OpenAPI)
- [ ] Data migration strategy finalized (if from legacy system)

---

## Version History

- **v1/v2 (Current):** Feature-complete marketplace, compliance gating, document generation
- **Future v2.x:** Bug fixes, testing, performance optimization, minor features
- **Future v3.x:** Major features (payments, real-time chat, advanced search)

---

## References

- Full feature inventory: [project-overview-pdr.md](./project-overview-pdr.md)
- Codebase structure: [codebase-summary.md](./codebase-summary.md)
- Architecture: [system-architecture.md](./system-architecture.md)
- Standards: [code-standards.md](./code-standards.md)

