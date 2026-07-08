# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Laravel 11 (PHP 8.2+) API backend for a shift-work/gig marketplace, plus a Filament 3 admin panel. Advertisers post Adverts (with Shifts), Applicants apply; the platform handles compliance (references, declarations, right-to-work, evidence, video verification), contracts, invoices, and payslips.

The same codebase serves **two white-label brands**: `yedi` and `tidal`, switched by `APP_CONFIGURATION` env (`config('app.configuration')`).

## Commands

Development runs through Laravel Sail (Docker: MySQL 8, Redis, Mailpit):

```bash
./vendor/bin/sail up -d              # start containers
./vendor/bin/sail artisan migrate    # run migrations
./vendor/bin/sail artisan test       # run tests (PHPUnit; Unit + Feature suites)
./vendor/bin/sail artisan test --filter=SomeTest   # single test
./vendor/bin/sail php ./vendor/bin/pint            # lint/format (Laravel Pint)
composer run dev                     # serve + queue:listen + pail logs + vite, concurrently
npm run dev                          # Vite dev server (Tailwind)
npm run build                        # build frontend assets
```

- The Husky pre-commit hook runs Pint **through Sail** on staged files — Sail containers must be running to commit.
- Queues run on Redis via Horizon (`sail artisan horizon`). Tests use `QUEUE_CONNECTION=sync` and the `testing` database (see `phpunit.xml`).

## Architecture

### Routing (bootstrap/app.php — not routes/api.php)

`routes/api.php` is **not registered** (commented out in `bootstrap/app.php`). Actual API routes live in `routes/app/` and are mounted in `bootstrap/app.php` with per-audience middleware:

- `routes/app/common.php` → `/app/common` — auth, uploads, dropdowns, settings (partially public)
- `routes/app/applicant.php` → `/app/applicant` — `auth:sanctum` + `user-type:applicant`
- `routes/app/advertiser.php` → `/app/advertiser` — `auth:sanctum` + `user-type:advertiser`

`routes/web.php` holds the brand landing page and a **signed** public reference-completion form for external referees. Scheduled commands (advert status lifecycle, expired uploads/addresses/device-tokens cleanup) are also registered in `bootstrap/app.php`, not a Kernel.

### Layering: Controller → Handler → Model

Business logic lives in single-purpose **Handler** classes under `app/Handlers/{Domain}/` (e.g. `Handlers/Advertisers/Adverts/CreateAdvertHandler.php`), constructor-injected into controllers and each other. Controllers are grouped by audience: `app/Http/Controllers/{Advertiser,Applicant,Common,Public}/`.

Supporting patterns:
- **DTOs** (`app/DTOs/`) via `spatie/laravel-data` carry validated input into handlers.
- **Enums** (`app/Enums/`) back all status/type fields (`AdvertStatus`, `ApplicationStatus`, `UserType`, ...).
- `User` has a `type` (`UserType`: Admin/Advertiser/Applicant) and a polymorphic `userable` pointing to the `Advertiser` or `Applicant` profile model. Only Admins can access the Filament panel.
- **Dropdown registry** (`app/Registries/Dropdowns/`) serves option lists to the mobile apps through a single `POST /app/common/dropdowns` endpoint.
- **Settings** are DB-backed (`Settings` model) and read through `Handlers/Settings/SettingsResolver`.

### External integrations

- **Saloon** connectors in `app/Http/Integrations/`: `GoogleMaps` (geocode/places) and `DocGen` (PDF generation service). PDF-producing work (contracts, invoices, payslips, reference PDFs, image conversions) is done in queued jobs (`app/Jobs/`).
- **Firebase** (kreait) push notifications via `DeviceToken` model and custom channels; notifications are organized by audience in `app/Notifications/{Admin,Advertiser,Applicant,Common,Public}/`.
- Sentry for errors; `owen-it/laravel-auditing` audits model changes.

### White-label branding

Use the `___()` helper (`app/helpers.php`) instead of `__()` for any user-facing string — it prefixes translation keys with the active brand, resolving from `lang/en/yedi.php` or `lang/en/tidal.php`. Brand-conditional views/PDFs check `config('app.configuration')`.

### Filament admin (app/Filament/)

Resources for the main models (Adverts, Advertisers, Applicants, Applications, Invoices, Payslips, ...), registered via `app/Providers/Filament/AdminPanelProvider.php`. Admin compliance review (approving evidence, references, verifications) happens here.
