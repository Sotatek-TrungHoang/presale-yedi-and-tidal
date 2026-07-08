# Yedi+Tidal App — Project Overview & PDR

## Executive Summary

A Flutter-based two-sided marketplace mobile application shipped as two branded flavors: **Yedi** (education focus) and **Tidal** (agency/staffing). Single codebase, dual branding. Currently v1.0.5+26, targeting SDK ^3.5.2+.

## Product Overview

### What It Does

Connects **applicants** (job seekers) and **advertisers** (employers/agency posters) on a mobile-first platform. Applicants apply for posted adverts; advertisers review, rate, and manage applications and bookings. Compliance-first: rich onboarding workflow with document uploads, references, video verification, and compliance gating before full profile activation.

### Flavor Variants

| Aspect | Yedi | Tidal |
|--------|------|-------|
| **Brand** | Yedi Education | Tidal |
| **Bundle ID** | `com.ne6.yedi` | `com.ne6.tidal` |
| **API Host** | `admin.yedi.group` | `admin.tidalagency.co.uk` |
| **Firebase Project** | `yedi-dev-801c4` | `tidal-dev` (checked-in default) |
| **Assets Dir** | `assets/yedi/` | `assets/tidal/` |
| **Strings/i18n** | `lib/l10n/yedi/intl_en.arb` | `lib/l10n/tidal/intl_en.arb` |

Both share: `yedi_app` Dart package, `lib/` codebase, `flutter_bloc` state management, `go_router` navigation.

### Key User Flows

**Applicant onboarding:** Signup → compliance checks (references, evidence, declarations, video verification) → awaiting approval → profile active → browse adverts → apply → await acceptance/decline → manage bookings.

**Advertiser onboarding:** Signup → compliance review → create advert → review applications → accept/decline/rate applicants → manage bookings and payments.

**Auth guard:** Unauthenticated users see landing/login; authenticated-incomplete-signup gates to `/sign-up`; applicant/advertiser are routed to role-specific home. Cross-role access blocked.

## User Roles

- **Applicant** (`UserType.applicant`): Job seeker. Fields: qualifications, references, evidence, right-to-work, job role, type of work, video verification, compliance status.
- **Advertiser** (`UserType.advertiser`): Employer/agency. Fields: business name, bio, address, photo, compliance status.
- **Admin** (`UserType.admin`): Backend only; not modeled in client UI.

## Compliance Model

Applicants progress through `ApplicantComplianceStatus`: incomplete → pending_approval → compliant / non_compliant.
Advertisers progress through `AdvertiserComplianceStatus`: pending → compliant / non_compliant.
Profile activation gated by `ProfileStatus`: incomplete → pending → active / disabled.
Final gate: `signUpCompletedAt` timestamp must be set before role-home access.

## Technical Stack

**State & DI:** `flutter_bloc` (BLoCs, Cubits), `get_it` singletons.
**Networking:** `dio` HTTP client, single `ApiService` with request/response interceptors.
**Routing:** `go_router` with auth-guard redirect logic.
**Localization:** Full ARB/i18n setup per flavor; currently only `en_GB` locale enabled.
**Firebase:** FCM for push notifications (per-flavor config via `firebase_options.dart`).
**UI:** Material Design, `google_fonts`, `flutter_svg`, native `google_maps_flutter`.

**Layering:** 
- `lib/modules/<feature>/` — feature services, models, BLOCs/Cubits (api, authentication, adverts, profile, documents, etc.)
- `lib/pages/` — screen widgets
- `lib/ui/` — shared scaffolds, inputs, theme, auth providers
- `lib/util/` — cross-cutting: env, firebase, forms, validator, toast, dates, strings

## Scope & Constraints

### In Scope (v1.0.5+26)
- iOS & Android native support
- Two-sided marketplace (applicant + advertiser)
- Compliance gating & document workflow
- Maps-based candidate search / geo selection
- Advert CRUD (advertiser)
- Application lifecycle (apply, accept, decline, rate)
- Bookings (linked to accepted applications)
- Profile management (both roles)
- FCM push notifications
- Shared Preferences auth token caching

### Out of Scope (Known Gaps, Roadmap Items)
- Apple Sign-In (dependency commented in pubspec; not wired)
- Crashlytics error reporting (imported/commented in main.dart; not active)
- Multiple languages (ARB exists, only `en_GB` enabled)
- Payment integration (scope unclear; not in codebase)
- Video uploads (video_player dependency present for playback only)
- Realtime messaging (no socket/realtime layer)

## Product Development Requirements

### Functional Requirements

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-1 | Dual-flavor build & runtime branding | CRITICAL | Done |
| FR-2 | Applicant onboarding with compliance gating | CRITICAL | Done |
| FR-3 | Advertiser advert creation & management | CRITICAL | Done |
| FR-4 | Application lifecycle (apply/accept/decline/rate) | CRITICAL | Done |
| FR-5 | FCM push notifications | HIGH | Done |
| FR-6 | Shared Preferences auth persistence | HIGH | Done |
| FR-7 | Role-based routing (applicant/advertiser) | CRITICAL | Done |
| FR-8 | Compliance document upload & verification | HIGH | Done |
| FR-9 | Bookings management (linked to applications) | HIGH | Done |
| FR-10 | Hearted applicants (favorites) | MEDIUM | Done |

### Non-Functional Requirements

| ID | Requirement | Target | Status |
|----|-------------|--------|--------|
| NFR-1 | Min SDK version | 3.5.2 | Done |
| NFR-2 | iOS + Android support | Both platforms | Done |
| NFR-3 | Auth token + user state persistence | SharedPreferences | Done |
| NFR-4 | API error handling (DioException → APIException) | Typed exceptions | Done |
| NFR-5 | Static analysis pass | flutter_lints + custom_lint | Passing |
| NFR-6 | No secrets in .env files | Treated as safe; Maps key is real | Compliant |

### Acceptance Criteria

- [x] Both flavors build & run independently
- [x] Flavor branding (theme, colors, strings) swaps correctly at runtime
- [x] Applicant flow: signup → compliance → adverts → apply → bookings
- [x] Advertiser flow: signup → create advert → review apps → manage bookings
- [x] Auth guard blocks unauthenticated access to role-home pages
- [x] Compliance gate blocks access if `signUpCompletedAt == null`
- [x] Cross-role access blocked with toast + redirect
- [x] FCM token injected in request headers
- [x] Unit & widget tests pass

## Release Status

**Current Version:** 1.0.5+26 (build 26)
**Last Update:** Dec 1, 2025
**Deployable:** Yes (both flavors ready for internal testing)

## Open Questions

None at this time. All architectural decisions documented in CLAUDE.md and implemented.
