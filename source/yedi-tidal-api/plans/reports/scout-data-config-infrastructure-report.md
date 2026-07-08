# Scout Report: Data, Config & Infrastructure — yedi-tidal-api

Laravel 11 (PHP ^8.2), Filament 3 admin panel, Sanctum API, Horizon/Redis queues, Spatie Data, Owen-It Auditing, Saloon HTTP, Brick Money, Kreait Firebase. White-label single codebase serving two brands (`yedi` / `tidal`) selected by `APP_CONFIGURATION`.

## 1. Database Schema (`database/migrations/`)

All tables use `id()` bigint PK unless noted, and nearly all carry `timestamps()` + `softDeletes()`. FKs declared via `foreignIdFor()`. String columns backing enums are indexed. No `.sql` dump; schema below is reconstructed from all 50 migrations.

### Users / Auth
- **users** (`0001_01_01_000000_create_users_table.php`, plus alters)
  - `type` (indexed, enum `UserType`: admin/advertiser/applicant), `first_name`, `last_name`, `name`, `email` (unique), `email_verified_at`, `password`, `title` (enum `UserTitle`), `date_of_birth` (made nullable in `2025_02_06_173212`), `telephone`, `nullableMorphs('userable')` (polymorphic to Applicant/Advertiser), `rememberToken`, softDeletes.
  - Email-change flow added `2025_01_23_111425`: `new_email`, `new_email_code`, `new_email_code_expires_at`.
  - `is_super_admin` bool default false (`2025_01_29_141111`).
- **password_reset_tokens** (email PK, token, created_at) — same migration.
- **sessions** (id PK, user_id, ip_address, user_agent, payload, last_activity) — same migration.
- **personal_access_tokens** (`2025_01_09_123717`) — Sanctum default.
- **device_tokens** (`2024_10_30_083600`): `user_id` (cascade), `device_token` (unique), `last_used` text. Firebase push tokens.

### Adverts / Shifts
- **advertisers** (`2025_01_09_123534` + alters): `name`, `email`, `telephone`, `bio`, `additional_info`, `compliance_status` (indexed, enum `AdvertiserComplianceStatus`: pending/compliant/non_compliant), `address_id` (nullOnDelete), `photograph_id`→uploads (`2025_01_20_141217`), `profile_status` (enum `ProfileStatus`, `2025_01_27_121410`), `sign_up_completed_at` (`2025_01_30_152914`).
- **applicants** (`2025_01_09_125811` + alters): `compliance_status` (indexed, enum `ApplicantComplianceStatus`: incomplete/pending_approval/compliant/non_compliant), `qualification` (enum `ApplicantQualification`), `teacher_number`, `address_id`, `photograph_id`, `evidence_of_id_id`→uploads, `video_verification_id` (`2025_01_10_135738`), `profile_status`, `rating` decimal (`2025_01_28_164021`), `sign_up_completed_at`, `type_of_work_id` (`2025_03_07_095407`), `job_role_id` (`2025_03_07_101935`).
- **adverts** (`2025_01_09_140315` + alters): `advertiser_id` (cascade), `type` (indexed, enum `AdvertType`: day_to_day/long_term), `status` (indexed, enum `AdvertStatus`: pending_approval/rejected/approved/pending_allocation/filled/not_filled), `title`, `description`, `starts_at`, `ends_at`, `shift_start_time`, `shift_end_time`, `apply_by`, `advertiser_pay_rate` (json, Money), `advertiser_pay_rate_type` (enum `PayType`: daily/hourly), `applicant_charge_percentage` float, `advertiser_charge_percentage` float, `address_id` (restrictOnDelete, `2025_01_20_092553`), contact fields `contact_name/position/email/telephone` (`2025_01_28_154922`), `day_to_day_active_minutes` (`2025_01_22_122113`), `marked_as_completed_at` indexed (`2025_01_24_120107`).
- **shifts** (`2025_02_04_091405`): `advert_id` (cascade), `starts_at`, `ends_at`.
- **types_of_work** (`2025_03_07_095407`): `name`.
- **job_roles** (`2025_03_07_101935`): `name`.
- **hearted_applicants** (`2025_01_29_104415`): `advertiser_id`, `applicant_id` (both cascade) — favourites pivot.

### Applications
- **applications** (`2025_01_09_142726` + alters): `applicant_id` (cascade), `advert_id` (cascade), `status` (indexed, enum `ApplicationStatus`: pending/accepted/declined/cancelled), `actioned_at` (converted string→dateTime in `2025_01_22_102219`), `rating` tinyint unsigned (`2025_01_28_164021`).

### Compliance
- **references** (`2025_01_10_121008` + `2025_02_03_095805` + `2025_02_04_112549`): `applicant_id` (cascade), `name`, `telephone`, `email`; big reference-form set added: `status` (enum `ReferenceStatus`: created/sent_to_referee/pending_confirmation/confirmed/rejected), `reference_id` uuid, employment/referee fields, rating-style string fields (curriculum_knowledge, pupil_management, etc. — enum `ReferenceRating` in app), boolean flags (any_disciplinary_procedures, was_dismissed, would_reemploy, may_share_with_new_employers…), `signature_name/date/signature` (mediumText), `upload_id` (nullOnDelete).
- **declarations** (`2025_01_10_121314`): `title`, `description`, `time_to_complete`, `upload_id`, `required` bool default true.
- **declaration_agreements** (`2025_01_10_122815`): `declaration_id`, `applicant_id` (both cascade).
- **right_to_work_declarations** (`2025_01_10_123208`): `applicant_id` (cascade) + 4 booleans (right_to_work_uk, require_visa_to_work_uk, lived_or_worked_outside_uk_6_months, has_criminal_convictions_or_prosecutions_pending).
- **required_evidence** (`2025_01_10_123750`): `title`, `time_to_complete`, `required` bool.
- **applicant_evidence** (`2025_01_10_124136`): `applicant_id`, `required_evidence_id`, `upload_id` (all cascade).
- **video_verifications** (`2025_01_10_135738`): `applicant_id` (cascade), `upload_id`, `code`.

### Billing
- **invoices** (`2025_01_24_093814` + `2025_02_03_155715`): `invoice_number`, `title`, `advert_id` (cascade), `upload_id` (nullOnDelete), `due_date`, `invoice_due_date_days`, `invoice_late_payment_charge_percent` float, `sub_total`/`vat`/`total` (json Money).
- **invoice_items** (`2025_02_03_155715` + fix `2025_02_04_101446`): `invoice_id` (cascade), `date`, `description`, `rate_type`, `rate` json, `quantity` decimal (was json), `amount` json.
- **payslips** (`2025_01_24_093814`): `payslip_number`, `title`, `advert_id`, `applicant_id`, `upload_id` (nullOnDelete).
- **contracts** (`2025_01_27_152000`): `title`, `morphs('owner')`, `upload_id` (nullOnDelete).

### Misc / Infrastructure tables
- **uploads** (`2025_01_09_115553` + `2025_01_21_112227`): **uuid PK**, `nullableMorphs('owner')`, `disk`, `file_path`, `file_name`, `mime_type`, `extension`, `size`, `uploaded_by_id`→users, `expires_at` (indexed), `image_width`/`image_height`.
- **image_conversions** (`2025_01_21_112227`): uuid PK, `upload_id` (foreignUuid cascade), `conversion_name` (enum `ImageConversionType`: thumbnail/small/medium/large), disk/path/name/file_name/mime_type/extension/size/width/height.
- **addresses** (`2025_01_09_122545` + `2025_01_23_151246`): `nullableMorphs('owner')`, `line_1`, `line_2`, `town_city`, `postcode`, `country`, `latitude`/`longitude` decimal(10,7), `expires_at` indexed.
- **documents** (`2025_01_27_092250`): `title`, `morphs('owner')`, `upload_id` (cascade).
- **audits** (`2025_01_31_101110`): Owen-It auditing — user morph, event, `auditable_type`, `auditable_id` uuid, old/new_values, url, ip_address, user_agent, tags.
- Framework: **cache**/**cache_locks** (`0001_01_01_000001`), **jobs**/**job_batches**/**failed_jobs** (`0001_01_01_000002`).

### Settings (single-row config table) + seed-style alter migrations
- **settings** (`2025_01_10_140607`): `references_required` uint, `require_teacher_number` bool.
- Progressive **"add_new_settings" alter migrations** (schema-only, defaults; actual row seeded by YediSeeder):
  - `2025_01_22_120835_add_new_settings.php`: `default_applicant_charge_percentage` (10), `default_advertiser_charge_percentage` (10).
  - `2025_02_03_151202_add_new_settings_fields.php`: `invoice_due_date_days` (7), `invoice_late_payment_charge_percent` (20), invoice payment account name/number/sort_code, invoice contact address/email/telephone.
  - `2025_02_04_102843_add_contract_fields_to_settings.php`: `applicant_contract`, `advertiser_contract` (mediumText — contract templates).

## 2. Seeders & Factories (`database/seeders/`, `database/factories/`)
- **DatabaseSeeder.php**: creates 2 users — `admin@example.com` (UserType::Admin) and `applicant@example.com` (UserType::Applicant), both password `password`.
- **YediSeeder.php**: idempotent (guards on `exists()`). Seeds the single Settings row (`references_required=2`, `require_teacher_number=true`), 3 Declarations (Safeguarding / Disqualification / Medical, lorem placeholder text, each with a faked uploaded file via `UploadFileHandler`), and 1 RequiredEvidence ("DBS Evidence"). No TidalSeeder exists.
- **UserFactory.php**: only factory present. Default state (name/email/verified/password `password`/remember_token) + `unverified()` state. Does NOT set `type`/`title`/`telephone` — supplied by DatabaseSeeder.

## 3. Notable config (`config/`)
- **app.php**: `'configuration' => env('APP_CONFIGURATION', 'yedi')` (the white-label switch). `'deeplink_url' => env('APP_DEEPLINK_URL')` (mobile deep links for password reset).
- **services.php**: `firebase.credentials` (FIREBASE_CREDENTIALS — push), `google_maps` (enabled flag + api_key — geocoding), `docgen` (url/username/password — external PDF generation service, Saloon), `mailgun` (domain/secret, endpoint default `api.eu.mailgun.net`), plus postmark/ses/resend/slack stubs.
- **filesystems.php**: default `local` (root `storage/app/private`, `serve=true`); disks `tmp` (`storage/app/tmp`), `public`, and **s3** (AWS_* keys, bucket, url, endpoint, path-style flag).
- **horizon.php**: single supervisor `HORIZON_SUPERVISOR` default `yedi-v2-supervisor--1`, redis connection, **queues: `default`, `conversions`, `documents`, `audits`**. maxProcesses 10 (production) / 3 (dev/local). `ProcessDispatchAudit` silenced. memory_limit 64.
- **queue.php**: default `env('QUEUE_CONNECTION','database')`; redis connection defined for Horizon; failed driver `database-uuids`.
- **audit.php**: enabled by default; events created/updated/deleted/restored; guards web/api/sanctum; **queued** (queue `audits`, connection from QUEUE_CONNECTION); driver database.
- **data.php** (Spatie): custom casts registered — **`MoneyCast` (Brick\Money)** and **`EloquentCast`** (`app/Casts/Data/`); date formats incl. `d-m-Y`; structure caching enabled; validation only on requests.
- **sanctum.php**: guard `web`, stateful domains from SANCTUM_STATEFUL_DOMAINS, no expiration.
- **sentry.php**: standard Sentry Laravel; DSN via SENTRY_LARAVEL_DSN/SENTRY_DSN; sample_rate default 1.0; ignores `/up`.
- **auth.php**: single `web` session guard, eloquent `users` provider. No separate `api` guard (Sanctum handles API).
- **mail.php**: default `MAIL_MAILER` (falls back `log`); mailgun + smtp + ses + postmark + resend + sendmail mailers.
- Also: `cache.php` (default `database`), `session.php` (driver `database`), `database.php` (default sqlite, mysql/mariadb/pgsql/sqlsrv + redis phpredis), `logging.php`, `ide-helper.php`.

## 4. White-label mechanics
- **`app/helpers.php`** — global `___($key, $replace, $locale)` helper (registered via composer `autoload.files`). Reads `config('app.configuration')`; if `yedi`|`tidal`, prefixes the key with that namespace and calls `__()`. Strips leftover `yedi.`/`tidal.` prefixes if translation missing so raw English falls through. This is the core brand-string resolver.
- **`lang/en/yedi.php` vs `lang/en/tidal.php`** — parallel key sets. Differences are terminology/branding only (same keys):
  - `brand`: Yedi vs Tidal; `brand_colour`: `#E78B2A` vs `#A0ACFF`.
  - Domain vocabulary: applicant = **Teacher** vs **Candidate**; advertiser = **School** vs **Brand**; advert = **Job** vs **Advert** (plus plurals).
  - `advertiser-icon`: `heroicon-o-academic-cap` vs `heroicon-o-shopping-bag`.
  - Overridden full sentences (route-guard messages, sign-up overview titles) rephrased per brand. No URL differences in the lang files.
- **Brand-conditional views**:
  - `resources/views/landing-yedi.blade.php` / `landing-tidal.blade.php` — routed in `routes/web.php` `/` by `config('app.configuration')`; only difference observed is `<title>` (Yedi vs Tidal).
  - `resources/views/pdfs/components/header.blade.php` — `@if config('app.configuration')==='yedi'` renders the Yedi inline SVG logo (`#EF9F1F`), `@else` renders Tidal SVG logo (black). Used across PDFs (invoice, payslip, contracts, reference).
- **Filament brand config** (`app/Providers/Filament/AdminPanelProvider.php`): `->brandName(___('brand'))` and `->colors(['primary' => ___('brand_colour')])` — panel name/theme colour driven entirely through the `___()` helper.
- **tailwind.config.js** additionally hardcodes brand palette: `yediBg #F0E4D4`, `tidalBg #F3F3F3`, `yediAccent #EF9F1F`, `tidalAccent #3E4DB0`; fonts Figtree + Sora.

## 5. Deployment / Dev infra
- **docker-compose.yml** (Laravel Sail, runtime 8.4): services `laravel.test` (app, ports APP_PORT:80 + VITE_PORT 5173), `mysql` (mysql-server:8.0, port 3306), `redis` (redis:alpine, 6379), `mailpit` (1025/8025). Volumes sail-mysql, sail-redis; network `sail`.
- **.husky/pre-commit**: runs Laravel Pint via Sail on staged files then `git update-index --again`. PHPStan and Pest lines are commented out.
- **package.json**: scripts `build` (vite build), `dev` (vite), `prepare` (husky). Deps: tailwindcss 3.4, vite 6, laravel-vite-plugin, axios, concurrently, **signature_pad** (reference-form signatures).
- **composer.json** `scripts.dev`: concurrently runs `php artisan serve` + `queue:listen --tries=1` + `pail` (logs) + `npm run dev` (named server/queue/logs/vite). `post-autoload-dump` runs `filament:upgrade`. Notable requires: filament/filament, laravel/horizon, laravel/sanctum, kreait/firebase-php, brick/money, spatie/laravel-data, spatie/image, owen-it/laravel-auditing, saloonphp (saloon + laravel-plugin + cache-plugin), sentry/sentry-laravel, league/iso3166, league/flysystem-aws-s3-v3, symfony/mailgun-mailer.
- **vite.config.js**: inputs `resources/css/app.css`, `resources/js/app.js`; refresh watches `app/Livewire/**` and `app/Filament/**`.
- **phpunit.xml**: defines Unit + Feature suites pointing at `tests/Unit` / `tests/Feature`, **but no `tests/` directory exists** (autoload-dev maps `Tests\\` to `tests/` — no tests written). Testing env: DB `testing`, sync queue, array cache/session, mail array.
- **.editorconfig**: 4-space (2 for yaml), LF, final newline.
- **storage/** structure: `app/private`, `app/public`, `app/tmp` (per filesystems), `framework/`, `debugbar/`.

## 6. Environment variables a deployer must set
Core: `APP_KEY`, `APP_NAME`, `APP_ENV`, `APP_URL`, `APP_DEEPLINK_URL`, **`APP_CONFIGURATION`** (`yedi`|`tidal` — brand selector), `APP_DEBUG`, `APP_TIMEZONE`.
Database: `DB_CONNECTION`, `DB_HOST`, `DB_PORT`, `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD`.
Redis / queues: `REDIS_HOST`, `REDIS_PASSWORD`, `REDIS_PORT`, `REDIS_CLIENT`, `QUEUE_CONNECTION` (use `redis` for Horizon), `HORIZON_SUPERVISOR`, `HORIZON_DOMAIN`, `HORIZON_PATH`.
Cache/session: `CACHE_STORE`, `SESSION_DRIVER`, `SESSION_DOMAIN`, `SANCTUM_STATEFUL_DOMAINS`.
Filesystem/S3: `FILESYSTEM_DISK`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_DEFAULT_REGION`, `AWS_BUCKET`, `AWS_URL`, `AWS_ENDPOINT`.
Mail: `MAIL_MAILER`, `MAILGUN_DOMAIN`, `MAILGUN_SECRET`, `MAILGUN_ENDPOINT`, `MAIL_FROM_ADDRESS`, `MAIL_FROM_NAME`.
Third-party: `FIREBASE_CREDENTIALS` (push), `GOOGLE_MAPS_ENABLED` + `GOOGLE_MAPS_API_KEY` (geocoding), `DOCGEN_URL` + `DOCGEN_USERNAME` + `DOCGEN_PASSWORD` (external doc/PDF generation).
Monitoring: `SENTRY_LARAVEL_DSN` (or `SENTRY_DSN`), `SENTRY_ENVIRONMENT`, `SENTRY_RELEASE`, `AUDITING_ENABLED`.
(Sail-only: `WWWGROUP`, `WWWUSER`, `APP_PORT`, `VITE_PORT`, `FORWARD_DB_PORT`, `FORWARD_REDIS_PORT`, `FORWARD_MAILPIT_PORT`.)

## 7. Providers & queue/schedule wiring
- **bootstrap/providers.php**: `AppServiceProvider`, `Filament\AdminPanelProvider`, `HorizonServiceProvider`.
- **bootstrap/app.php**:
  - Routing: web routes; API route groups mounted with prefixes `app/common` (public), `app/applicant` (auth:sanctum + `user-type:applicant`), `app/advertiser` (auth:sanctum + `user-type:advertiser`). Health check `/up`. Local-only `/testing` route.
  - Middleware: alias `user-type` → `UserTypeMiddleware`; appends `DeviceTokenMiddleware` to the `api` group.
  - Exceptions: `Sentry\Laravel\Integration::handles($exceptions)`.
  - **Schedule** (`withSchedule`): `ClearExpiredAddressesCommand`, `ClearExpiredDeviceTokensCommand`, `ClearExpiredUploadsCommand` every 5 min; `MarkAdvertsAsCompleteCommand`, `UpdateApprovedAdvertsStatusesCommand`, `UpdatePendingAllocationAdvertsStatusesCommand` every minute.
- **AppServiceProvider**: binds singletons `UrlService`, `DeepLinkUrlService` (uses `app.deeplink_url`), `DropdownRegistry`; auto-discovers & tags all `DropdownOptionInterface` classes under `app/Registries/Dropdowns/Options/`. Configures Filament DatePicker/DateTimePicker/Select to non-native. Overrides password-reset URL to a deep link.
- **HorizonServiceProvider**: `viewHorizon` gate → `$user->isAdmin()`.
- **AdminPanelProvider** (Filament): panel id `admin`, path `/admin`, login + profile, brand name/colour via `___()`, auto-discovers Resources/Pages/Widgets, full max width, injects Vite `app.js` at panel body end.

### Notable gaps / observations
- No `tests/` directory despite phpunit.xml + autoload-dev mapping (zero tests).
- No `TidalSeeder`; only `YediSeeder` exists (brand-neutral content).
- `audit.php` references an `api` guard not defined in `auth.php`.
- Money/decimal amounts stored as JSON columns (Brick Money via Spatie `MoneyCast`) on adverts, invoices, invoice_items.
