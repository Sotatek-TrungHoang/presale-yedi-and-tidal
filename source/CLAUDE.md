# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository layout

This directory holds **two separately-buildable projects** that together form one product — a white-label, two-sided shift-work/gig marketplace shipped under two brands, **Yedi** (education focus) and **Tidal** (general staffing):

- `yedi-tidal-api/` — **Laravel 11 (PHP 8.2+)** backend API + **Filament 3** admin panel. Serves the mobile apps and hosts compliance review, document generation, and financials.
- `yedi-tidal-app/` — **Flutter (Dart ^3.5.2)** mobile app (iOS/Android). Consumes the API.

There is **no root build, package manager, or shared tooling** tying the two together — treat each subdirectory as its own repo. `cd` into the relevant project before running any command. Each has its own `CLAUDE.md`, `README.md`, and `docs/` — **read the subproject's `CLAUDE.md` first** when working inside it; those files are the source of truth for commands, architecture, and conventions:

- `yedi-tidal-api/CLAUDE.md` — routing (in `bootstrap/app.php`, not `routes/api.php`), Controller→Handler→Model layering, Saloon integrations, white-label `___()` helper.
- `yedi-tidal-app/CLAUDE.md` — flavor build system (`--flavor` + `--dart-define-from-file`), bloc/get_it DI, go_router auth guard, typed API exceptions.

The actual git root is one level up (`agency-brands-ads/`), which is a Sotatek **presale/audit engagement** workspace (proposals, evidences, effort estimates). The `plans/` and `docs/` folders under each subproject were produced during that audit, not by the original product team.

## The two brands (shared across both projects)

The single most important cross-cutting concept: **one codebase, two brands, switched at runtime/build time — never fork per brand.**

| | Yedi | Tidal |
|---|---|---|
| API selector | `APP_CONFIGURATION=yedi` | `APP_CONFIGURATION=tidal` |
| App flavor | `--flavor yedi` | `--flavor tidal` |
| Backend host | `admin.yedi.group` | `admin.tidalagency.co.uk` |
| Bundle id | `com.ne6.yedi` | `com.ne6.tidal` |

When adding a user-facing string, add it to **both** brands' translation files (`lang/en/{yedi,tidal}.php` in the API; `lib/l10n/{yedi,tidal}/intl_en.arb` in the app) unless the copy is intentionally brand-specific. See each subproject's CLAUDE.md for the exact helper/regeneration step.

## Shared domain model (keep API and app in sync)

Both sides model the same marketplace, so a change on one side usually needs a matching change on the other:

- **Two user types** drive nearly all branching: `applicant` (job seeker) and `advertiser` (school/brand). A `User` has a `type` and a polymorphic profile.
- **Advertisers** post **Adverts** (containing **Shifts**); **Applicants** apply → **Applications** with a lifecycle (apply/accept/decline/rate).
- **Compliance gating** blocks marketplace access until onboarding is complete: applicants supply references, declarations, right-to-work, evidence, and video verification; admins review and approve in the Filament panel. Status is tracked in compliance-status enums on both sides.
- Money is **GBP** (Brick Money on the backend); contracts/invoices/payslips are generated via an external DocGen service.

When changing an API contract (route, DTO field, enum value, validation), update the Flutter service/model that calls it — the app maps 422 responses into `APIValidationException` keyed by field name, so field names must match.

## Common commands (run inside the relevant subproject)

```bash
# --- yedi-tidal-api/ (Laravel Sail: MySQL 8, Redis, Mailpit) ---
./vendor/bin/sail up -d                 # start containers (needed before commit — Husky runs Pint via Sail)
./vendor/bin/sail artisan migrate
./vendor/bin/sail artisan test          # (--filter=SomeTest for one test)
./vendor/bin/sail php ./vendor/bin/pint # lint/format
composer run dev                        # serve + queue + logs + vite

# --- yedi-tidal-app/ (always run pre_<flavor> before running/building) ---
./scripts/pre_yedi.sh                   # regenerates firebase_options.dart + app_localizations.dart
flutter run --flavor yedi --dart-define-from-file .env.yedi
flutter analyze                         # must pass
flutter test                            # (flutter test test/unit_test.dart for one file)
./scripts/build/yedi.sh                 # release AAB + IPA
```

Switching Flutter flavors **without** re-running `pre_<flavor>.sh` builds with the wrong brand's Firebase config and strings — a frequent source of confusing bugs.
