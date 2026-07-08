# Project Roadmap — Yedi+Tidal App

## Current Status

**Version:** 1.0.5+26 (build 26)
**Release Date:** Dec 1, 2025
**Status:** Stable, internal testing phase

Both flavors (Yedi & Tidal) are feature-complete for MVP and ready for wider testing.

## Completed Phases

### Phase 1: Foundation (Complete)
- [x] Project setup: Flutter + flutter_bloc + go_router
- [x] Dual-flavor architecture (Yedi + Tidal)
- [x] Environment configuration per flavor (.env files)
- [x] Firebase integration per flavor
- [x] Dependency injection (get_it + RepositoryProvider)
- [x] Static analysis (flutter_lints + custom_lint)

### Phase 2: Authentication (Complete)
- [x] Login/signup UI & flow
- [x] Bearer token management (SharedPreferences)
- [x] Auth state machine (unknown → authenticated → unauthenticated)
- [x] Auth guard in go_router redirect
- [x] Password reset/forgot password flows
- [x] Session persistence on app restart

### Phase 3: Compliance & Onboarding (Complete)
- [x] Applicant onboarding wizard (multi-step signup)
- [x] Applicant compliance statuses (incomplete → pending → compliant/non_compliant)
- [x] Advertiser compliance review
- [x] Document upload (evidence, references, qualifications, ID verification)
- [x] Video verification workflow
- [x] Right-to-work declarations
- [x] Compliance gating (signup completion gate)
- [x] Profile status tracking (incomplete → pending → active)

### Phase 4: Marketplace Core (Complete)
- [x] Advertiser: Create, list, edit, delete adverts
- [x] Applicant: Browse adverts, filter, search
- [x] Applicant: Apply for adverts
- [x] Advertiser: Review applications (accept/decline/rate)
- [x] Bookings: Link accepted applications to bookings
- [x] Applicant: Manage bookings + view status
- [x] Role-based routing (applicant vs advertiser zones)

### Phase 5: Profile & Account Management (Complete)
- [x] Applicant profile: Contact info, address, qualifications
- [x] Applicant profile: References, evidence, declarations
- [x] Advertiser profile: Organization info, contact, location
- [x] Change password
- [x] Change email
- [x] Delete account
- [x] Settings per role (notifications, privacy, etc.)

### Phase 6: Features & Polish (Complete)
- [x] Hearted applicants (advertiser favorites)
- [x] FCM push notifications + token management
- [x] Google Maps integration (location-based search)
- [x] Image/file picker for uploads
- [x] Phone number validation (libphonenumber)
- [x] Email validation
- [x] Toast notifications (success, error, info)
- [x] Loading skeletons / shimmer effects
- [x] Localization infrastructure (ARB, per-flavor strings)
- [x] Theme switching (Yedi vs Tidal at runtime)

### Phase 7: Testing (Complete)
- [x] Unit tests (authentication, validation, models)
- [x] Widget tests (pages, components)
- [x] API exception handling tests
- [x] Static analysis passing (flutter analyze)

## Current Roadmap Items (Prioritized)

### Priority 1: Stability & Monitoring
| Item | Status | Notes |
|------|--------|-------|
| Enable Crashlytics error tracking | Not Started | Code commented in main.dart; re-enable for production monitoring |
| Performance profiling on low-end devices | Not Started | Test on Android 10, iOS 12 devices; identify bottlenecks |
| Network resilience testing | Not Started | Test on 3G, poor connectivity; ensure graceful degradation |
| Automated UI tests (Patrol/integration tests) | Not Started | Full user flow coverage (login → apply → booking) |

### Priority 2: Feature Gaps
| Item | Status | Notes |
|------|--------|-------|
| Apple Sign-In | Not Started | Dependency commented in pubspec; integrate into auth flow |
| Payment integration | Not Started | Scope unclear; Stripe/Polar/SePay research needed |
| Messaging / In-app chat | Not Started | Requires WebSocket/realtime layer; not in current stack |
| Video upload for verification | In Progress | Currently video_player playback only; upload endpoint TBD |
| Rating & reviews (bilateral) | Partial | Advertiser rates applicant; applicant rating of advertiser TBD |

### Priority 3: Localization
| Item | Status | Notes |
|------|--------|-------|
| Multi-language support (French, Spanish, etc.) | Not Started | ARB infrastructure ready; translations needed |
| RTL language support (Arabic, Hebrew) | Not Started | Flutter support available; theme updates needed |

### Priority 4: Analytics & Insights
| Item | Status | Notes |
|------|--------|-------|
| User funnel tracking (firebase_analytics) | Not Started | Dependency present; custom events need wiring |
| Compliance rate dashboard | Not Started | Backend insight; frontend could fetch & display |
| Advert performance metrics | Not Started | Views, applies, conversion rates per advert |

### Priority 5: Scale & Infrastructure
| Item | Status | Notes |
|------|--------|-------|
| Infinite scroll pagination | Partial | Some lists paginated; others use limit + load more |
| Image optimization (compression, CDN) | Not Started | Currently raw uploads; consider CloudFront/similar |
| Offline mode (sync on reconnect) | Not Started | Requires local DB (sqflite); scope TBD |
| Push notification deep linking | Partial | FCM token injected; deep link payload handling TBD |

## Known Issues & Technical Debt

### Code-Level
- **Commented-out code:** Crashlytics (main.dart), Apple Sign-In (pubspec.yaml)
- **No multi-language active:** Only `en_GB` supported; infrastructure exists
- **Form validation scattered:** Some in cubits, some in services; consider centralized validator
- **Test coverage:** No coverage metrics tracked; consider adding codecov

### Architecture
- **Token auto-refresh missing:** 401 forces logout; no silent token refresh
- **No offline support:** All features require network
- **Image caching basic:** No compression or CDN layer
- **Real-time features absent:** No WebSocket/messaging layer

### Known Behaviors
- Reset password link requires `email` + `token` query params; invalid params show error + redirect to landing
- Cross-role navigation detected via `user.type` check; if user manually changes URL, guard catches + redirects to correct home
- Flavor-specific files regenerated per build; switching flavors without running pre_<flavor>.sh can cause config mismatch

## Candidate Roadmap Items (Lower Priority)

### Nice-to-Have Features
- Dark mode toggle
- Biometric authentication (fingerprint/Face ID)
- Local notifications for bookings reminders
- Offline form filling (draft saves)
- Advanced search filters (keywords, experience level, availability)
- Invite referrals (share app code)
- In-app help/tutorials
- Accessibility (screen reader, high contrast)

### Technical Improvements
- State persistence across app lifecycle (not just auth token)
- Incremental migration to Riverpod (from flutter_bloc)
- GraphQL migration (from REST)
- Type-safe API client generation (freezed + retrofit)
- Automated screenshot testing
- CI/CD pipeline (GitHub Actions)
- Staging environment setup

## Blocked / TBD Items

| Item | Blocker | Impact | Next Steps |
|------|---------|--------|-----------|
| Payment integration | Business decision on payment partner | High | Product team to decide Stripe vs Polar vs SePay |
| Realtime messaging | Architecture decision (WebSocket vs Firebase Realtime DB) | High | Research & prototype |
| Multi-language rollout | Translation budget + language priority list | Medium | Discuss with stakeholders |
| Offline mode | Database choice (sqflite vs Drift) + sync strategy | Medium | Design data persistence layer |

## Release Schedule (Speculative)

| Release | Timeline | Scope |
|---------|----------|-------|
| **v1.0.6** | Next sprint | Crashlytics, performance fixes, minor UX polish |
| **v1.1.0** | 2-3 sprints | Apple Sign-In, payment integration (MVP), UI/UX improvements |
| **v1.2.0** | 4-5 sprints | Messaging layer, multi-language (EN, FR, ES), analytics dashboard |
| **v2.0.0** | Next quarter | Realtime features, offline mode, GraphQL migration |

**Note:** Timeline is speculative and subject to product roadmap changes.

## Dependency Maintenance

### Version Tracking
- **Flutter SDK:** ^3.5.2 (current pinned)
- **flutter_bloc:** ^9.0.0
- **go_router:** ^14.2.7
- **dio:** ^5.7.0
- **firebase_core:** ^3.10.1

### Update Policy
- Minor/patch updates: Test + merge if no breaking changes
- Major updates: Evaluate breaking changes, create feature branch, full test cycle
- Security updates: Priority 1; merge ASAP

### Known Outdated
- None currently; dependencies are recent as of Dec 2025

## Success Metrics (Post-Launch)

| Metric | Target | Measurement |
|--------|--------|-------------|
| App store rating | ≥ 4.0 | User reviews |
| Crash-free sessions | ≥ 99% | Crashlytics (once enabled) |
| Auth completion rate | ≥ 85% | Backend analytics |
| Compliance acceptance rate | ≥ 80% | Backend compliance dashboard |
| Advert fill rate | ≥ 75% | Advertiser adoption |
| Booking completion | ≥ 70% | End-to-end flow success |

## Unresolved Questions

1. **Payment provider:** Which payment platform will be integrated? (Stripe, Polar, SePay, or other?)
2. **Messaging timeline:** When should in-app messaging be prioritized? Is WebSocket or Firebase Realtime DB preferred?
3. **Offline strategy:** Should the app support offline form filling + sync? If so, which database (sqflite vs Drift)?
4. **Multi-language rollout:** Which languages after English? Priority order?
5. **Scaling:** Expected user base? Performance targets? CDN strategy for assets?
6. **Deprecated features:** Is Apple Sign-In truly required, or can it remain commented out indefinitely?
7. **Test coverage:** Should we enforce a minimum coverage percentage (e.g., 70%)?
8. **CI/CD:** Should we set up GitHub Actions for automated testing & releases?

## Migration Path (If Needed)

If a major architectural change is needed (e.g., Bloc → Riverpod, REST → GraphQL):
1. Create a long-lived feature branch
2. Migrate one module at a time (e.g., adverts first)
3. Run full test suite between each module
4. Merge after PR review
5. Update documentation
6. Plan deprecation timeline for old approach

Current codebase is modular enough to support such migrations incrementally.
