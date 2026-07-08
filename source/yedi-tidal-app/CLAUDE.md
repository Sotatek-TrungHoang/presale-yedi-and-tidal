# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A single-codebase Flutter app shipped as **two branded flavors**: **Yedi** (Yedi Education, `com.ne6.yedi`, `admin.yedi.group`) and **Tidal** (`com.ne6.tidal`, `admin.tidalagency.co.uk`). It's a two-sided marketplace connecting **applicants** (job seekers) and **advertisers** (posters of adverts/bookings). The Dart package is always `yedi_app` — imports are `package:yedi_app/...` for both flavors.

## Flavor system (read before running or building)

Flavor is chosen at build time via Flutter's `--flavor` + `--dart-define-from-file`. `appFlavor` (from `flutter/services`) is read at runtime to branch theme, colours, icons, and assets:

- `lib/ui/theme/app_theme.dart` — `appFlavor == 'tidal' ? tidalX : yediX` for theme/colours/icons/borderRadius.
- Assets resolved by flavor path at runtime, e.g. `"assets/$appFlavor/logo.svg"` (`assets/yedi/`, `assets/tidal/`).
- Env (`BASE_API_URL`, `GOOGLE_MAPS_API_KEY`) comes from `.env.yedi` / `.env.tidal` via `--dart-define-from-file`, read through `Env` (`lib/util/env.dart`) using `String.fromEnvironment`. `Env.validate()` throws on startup if unset.

**Generated files are shared between flavors and must be regenerated when switching brands:**
- `lib/firebase_options.dart` — single file, overwritten per flavor by `scripts/flutterfire_config_<flavor>.sh`.
- `lib/l10n/app_localizations.dart` — generated from **flavor-specific** ARB files (`lib/l10n/yedi/intl_en.arb` vs `lib/l10n/tidal/intl_en.arb`), so the two brands have different copy.

Always run the `pre_<flavor>` script before running/building a flavor, or you'll build with the wrong brand's Firebase config and strings. There is no `l10n.yaml`; generation args are hardcoded in the scripts.

## Commands

```bash
# Prepare a flavor (regenerates firebase_options.dart + app_localizations.dart)
./scripts/pre_yedi.sh          # or ./scripts/pre_tidal.sh

# Run
flutter run --flavor yedi  --dart-define-from-file .env.yedi
flutter run --flavor tidal --dart-define-from-file .env.tidal

# Build (each script runs pre_<flavor> then appbundle/ios/ipa)
./scripts/build/yedi.sh
./scripts/build/tidal.sh

# Regenerate localizations only
./scripts/generate_localizations_yedi.sh   # or _tidal

# App launcher icons (uses flutter_launcher_icons-<flavor>.yaml)
./scripts/generate_app_icons.sh

flutter analyze                 # static analysis (custom_lint plugin enabled)
flutter test                    # all tests
flutter test test/unit_test.dart   # single test file
```

Android flavors (`flavorDimensions "default"`) live in `android/app/build.gradle`; `flutter_env_native` wires `--dart-define-from-file` values into the native build there.

## Architecture

**State/DI:** `flutter_bloc` (Blocs + Cubits) for state, `get_it` for global singletons, `RepositoryProvider` for services.
- `main.dart` — bootstraps: `Env.validate()`, libphonenumber, Firebase (per-flavor named app + FCM token → registered as `FirebaseToken` singleton), registers `ApiService` and `SharedPreferences` in `getIt`, resolves current user, then `runApp`.
- `app.dart` — `MultiRepositoryProvider` registers **all feature services** + a single always-on `AuthenticationBloc`. `AppView` listens to auth state, refreshes the router, and swaps between `ApplicantAuthProviders` / `AdvertiserAuthProviders` (from `lib/ui/auth_providers.dart`) based on `user.type`.

**Feature modules** — `lib/modules/<feature>/` each split into `bloc/`, `models/`, `services/`. Features: `adverts`, `authentication`, `common`, `documents`, `profile`, `sign_up`, `login`, `forgot_password`, `reset_password`, `hearted_applicants`. Services do HTTP via `ApiService`; blocs/cubits hold UI state. Many advert flows are split by role (`advertiser_advert_service.dart` vs `applicant_advert_service.dart`).

**Networking** — `lib/modules/api/api.dart`: single Dio-based `ApiService`. Request interceptor injects `Authorization: Bearer <bearerToken>` (from `SharedPreferences` key `bearerToken`) and `X-FCM-Token`. `_handleException` maps `DioException` → `APIException`, with 422 responses parsed into `APIValidationException` (field → message map). Prefer throwing/catching these typed exceptions over raw Dio errors.

**Routing** — `lib/pages/router.dart`: `go_router` with a central `redirect` acting as the auth guard. Three zones: unauthenticated (`/landing/...`), applicant `ShellRoute` (`/applicant/...`), advertiser `ShellRoute` (`/advertiser/...`), each with its own navigator key. Guard logic: `unknown` status holds the splash; unauthenticated → `/landing`; authenticated-but-incomplete-signup → `/landing/sign-up`; cross-role access is blocked with a toast + redirect to the user's home. Add routes as constants in `Routes` and wire them in the matching shell.

**UI layer** — `lib/pages/` holds screen widgets (often `*_page.dart` + `*_content.dart`); `lib/ui/` holds shared scaffolds (`applicant_scaffold.dart`, `advertiser_scaffold.dart`), reusable inputs, cubits, and theme. `lib/util/` holds cross-cutting helpers (`env`, `firebase`, `forms`, `validator`, `toast`, `dates`, `strings`).

## Conventions

- Two user types drive most branching: `UserType.applicant` and `UserType.advertiser`. Role-specific pages/services/routes are namespaced accordingly.
- Analysis is `flutter_lints` with `avoid_print` and `constant_identifier_names` disabled (`print` is used intentionally, e.g. `main.dart`).
- `.env.yedi` / `.env.tidal` are committed and contain the API base URL + Maps key — treat the Maps key as a real secret; do not add new secrets here.
- When adding user-facing strings, add them to **both** `lib/l10n/yedi/intl_en.arb` and `lib/l10n/tidal/intl_en.arb` (unless the copy is intentionally brand-specific), then regenerate.
