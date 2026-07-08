# Codebase Summary

**Last updated:** 2026-07-08  
**Total LOC:** ~22,000 (PHP, Blade, JavaScript)  
**Key framework:** Laravel 11, Filament 3, Sanctum

## Directory Structure Overview

### `app/`
Core application logic (~15k LOC).

#### `app/Models/` (~1.7k LOC, 30 files)
Eloquent models, nearly all with soft deletes and Owen-It auditing.

**Core Marketplace:**
- `User.php` — Auth entity; polymorphic `userable` to Advertiser|Applicant
- `Advertiser.php`, `Applicant.php` — Profile models (implements Addresses, Uploads)
- `Advert.php` — Job posting; computed money attributes (pay/charges/profit)
- `Application.php` — Join between Applicant and Advert
- `Shift.php` — Individual shift within an advert

**Compliance:**
- `Reference.php`, `RightToWorkDeclaration.php`, `DeclarationAgreement.php`, `ApplicantEvidence.php`, `VideoVerification.php` — Applicant compliance documents
- `Declaration.php`, `RequiredEvidence.php` — Admin-defined compliance templates

**Finance:**
- `Invoice.php`, `InvoiceItem.php` — Advertiser billing
- `Payslip.php` — Applicant pay statement
- `Contract.php` — Polymorphic contract (Advertiser or Applicant)

**Infrastructure:**
- `Address.php` — Polymorphic; triggers geocoding on save
- `Upload.php` — UUID PK; signed URLs; orphan cleanup
- `ImageConversion.php` — Resized image variants
- `Document.php` — Advert attachments
- `DeviceToken.php` — Firebase FCM tokens
- `Settings.php` — Singleton config row
- `JobRole.php`, `TypeOfWork.php` — Lookups

#### `app/Enums/` 
String-backed enums implementing Filament `HasLabel` / `HasColor`:
- `AdvertStatus`, `AdvertType`, `ApplicationStatus`, `UserType`, `UserTitle`, `ProfileStatus`
- `AdvertiserComplianceStatus`, `ApplicantComplianceStatus`, `ApplicantQualification`
- `ReferenceStatus`, `ReferenceRating`, `PayType`, `ImageConversionType`

#### `app/Handlers/` (~800 LOC, single-responsibility action classes)
Invoked from controllers, models, jobs; constructor-injected composition.

**Advertisers/Adverts:**
- `CreateAdvertHandler` — Generates shifts, sets defaults, notifies admins
- `AcceptApplicationHandler`, `DeclineApplicationHandler`, `RateApplicationHandler`
- `DeleteAdvertHandler`

**Applicants:**
- `ApplyToAdvertHandler`, `CancelApplicationHandler`

**References, Notifications, Documents, Settings, Addresses, Uploads:**
- `RequestReferenceHandler` — Emails referees
- `NotifyAdminsHandler`, `NotifyAdvertiserHandler`, `NotifyApplicantHandler`
- `CreateDocumentHandler`, `SettingsResolver`, `GetAddressCoordinatesHandler`
- `UploadFileHandler`, `CreateUploadFromDataHandler`, `CreateUploadFromGoogleHandler`

**SignUp:**
- `AdvertiserSignUpPagesHandler`, `ApplicantSignUpPagesHandler` — Compute wizard progress

#### `app/Jobs/` (Queue `documents`, `conversions`, `audits`)
All queue-able PDF and image-processing work.

- `CreateAdvertInvoiceJob`, `CreateAdvertPayslipJob` — Billing documents
- `CreateAdvertiserContractJob`, `CreateApplicantContractJob` — Agreements
- `CreateReferencePdfJob` — Reference form PDF
- `CreateImageConversionsJob` — Image resizing/optimization

#### `app/Notifications/` (organized by audience)
**By folder:** Admin/, Advertiser/, Applicant/, Common/, Public/  
**Custom channel:** `Channels/FcmChannel` — Firebase push via device tokens  
All extend `AbstractNotification`; some declare `fcm()` method for push variant.

#### `app/Http/Controllers/` (~4.6k LOC, 111 files, organized by audience)
**Audience folders:** Advertiser/, Applicant/, Common/, Public/  
**Traits:** `AdvertiserPortalTrait`, `ApplicantPortalTrait` — User role resolution

**Key controllers:**
- `Advertiser/AdvertsController` — CRUD adverts
- `Advertiser/AdvertApplicationsController` — Accept/decline/rate
- `Applicant/AdvertsController` — Browse and apply
- `Common/AuthController` — Login, password reset
- `Common/UploadController` — File storage
- `Common/DropdownController` — Dynamic option lists
- `Public/ReferenceController` — Signed reference form submission

#### `app/Http/Requests/` (validation & authorization)
Organized by audience/feature; method-injected dependencies in `rules()`.

#### `app/Http/Resources/` (JSON response formatting)
Organized by domain; audience-aware payloads via `mergeWhen()`.

#### `app/Http/Integrations/` (Saloon connectors)
- `DocGenConnector` — HTML→PDF service (contracts, invoices, payslips, references)
- `GoogleMapsConnector` — Geocoding, place photos

#### `app/Http/Middleware/`
- `UserTypeMiddleware` — Enforce user-type gates (Admin/Advertiser/Applicant)
- `DeviceTokenMiddleware` — Register FCM tokens from headers

#### `app/DTOs/` (Spatie LaravelData)
- `Adverts/CreateAdvertData` — Advert creation payload
- `Documents/DocumentData`, `Notifications/FcmNotificationData`, etc.

#### `app/Casts/`
- `MoneyCast` — Brick Money ↔ JSON
- `CountryCast` — ISO3166 handling
- `Data/` — LaravelData custom casts (Money, Eloquent, Enum)

#### `app/Rules/` (Validation rules)
- `AddressRule`, `UploadRule`, `CountryRule`, `TimeRule`

#### `app/Policies/` (Authorization gates)
- `AdvertPolicy` — View, create, apply, delete
- `ApplicationPolicy` — Accept, decline, rate
- `VideoVerificationPolicy` — Update own verification

#### `app/Services/`
- `UrlService` — Admin panel URL builders
- `DeepLinkUrlService` — Mobile deep-link URLs

#### `app/Registries/Dropdowns/` (Pluggable option lists)
- `DropdownRegistry` — Collection of dropdown options
- `Options/` — Concrete implementations (JobRoles, Qualifications, Countries, etc.)

#### `app/Providers/`
- `AppServiceProvider` — Singleton binding, Filament native picker config
- `Filament/AdminPanelProvider` — Panel setup, branding via `___()` helper

#### `app/Console/Commands/`
**Advert lifecycle:** `adverts:mark-as-complete`, `adverts:approved-statuses`, `adverts:pending-allocation-statuses`  
**Cleanup:** `common:addresses:clear-expired`, `common:device-tokens:clear-expired`, `common:uploads:clear-expired`  
**Contracts:** `contracts:generate-advertiser`, `contracts:generate-applicant` (manual)

### `app/Filament/` (~4.1k LOC, 62 files)
Admin resources and pages.

**Resources:** AdvertiserResource, AdvertResource, ApplicantResource, ApplicationResource, InvoiceResource, PayslipResource  
**Settings:** DeclarationResource, RequiredEvidenceResource, JobRoleResource, TypeOfWorkResource  
**Pages:** Dashboard, System (Settings form)  
**Widgets:** Dashboard stats, ExpenditureOverview (money summary)  
**Infolists:** VideoEntry (custom video player)

### `bootstrap/`
- `app.php` — Routing, middleware, scheduling (no `Kernel`)
- `providers.php` — Service provider list

### `routes/` 
- `web.php` — Landing page, signed reference form
- `app/common.php` — Auth, uploads, dropdowns, settings (public + sanctum)
- `app/applicant.php` — SignUp, profile, adverts, applications, bookings (sanctum + user-type)
- `app/advertiser.php` — SignUp, profile, adverts, applications, invoices (sanctum + user-type)
- `api.php` — Unregistered (dead code)
- `console.php` — Artisan commands

### `config/`
Key: `app.php` (`configuration`, `deeplink_url`), `services.php` (Firebase, Google, DocGen, Mailgun), `horizon.php` (queue setup), `audit.php` (Owen-It), `data.php` (Spatie Data casts).

### `database/`
- `migrations/` (50 files) — Schema covering all models, white-label switch
- `seeders/` — DatabaseSeeder (test users), YediSeeder (declarations + evidence)
- `factories/` — UserFactory (only one)

### `resources/`
- `views/` — Landing pages (brand-conditional), reference form, PDFs, mail templates, Filament custom pages
- `css/` — `app.css` (Tailwind directives only)
- `js/` — `app.js` (SignaturePad wiring), `bootstrap.js`

### `storage/`
- `app/private/` — Default disk (local dev); signed URLs
- `app/tmp/` — Temporary files (auto-cleanup)
- Framework caches and logs

### `tests/` (Directory exists; no test files written)
PHPUnit config mapped to `tests/Unit` and `tests/Feature` suites. QUEUE_CONNECTION=sync for tests.

## Key Patterns

### Controller → Handler → Model
- Controllers: thin, delegate to Handlers
- Handlers: single responsibility, constructor-injected composition
- Models: Eloquent + computed attributes + boot hooks

### DTOs & Validation
- Spatie LaravelData for typed request payloads
- Validation rules in Request classes
- Custom rules for ownership/uniqueness

### White-label Branding
- `___()` helper: prefixes translation key with brand namespace
- `lang/en/yedi.php` vs `lang/en/tidal.php` — parallel terminology
- Views check `config('app.configuration')`
- Filament brand name/color via `___()` helper

### Polymorphic Relations
- `User` → Advertiser or Applicant
- `Address`, `Upload` → owned by Advertiser/Applicant/Declaration/etc.
- `Contract` → Advertiser or Applicant

### Authorization
- Policies for business-logic gates
- Middleware for audience routing (Advertiser-only routes, Applicant-only routes)
- `Gate::authorize()` in Requests

### Money Handling
- Brick Money (GBP) via `MoneyCast` on Eloquent + Spatie Data
- JSON storage (major, currency)
- Computed attributes on `Advert` for fee calculations

## Important Implementation Details

- **No auth.api guard:** Sanctum handles API auth; only `web` session guard defined
- **Audit queue:** Owen-It auditing dispatched to `audits` queue
- **Image processing:** WebP optimization via Spatie Image; multiple sizes (thumbnail, small, medium, large)
- **Address cleanup:** Orphaned addresses expire after 15 minutes; scheduled cleanup
- **Upload cleanup:** Orphaned uploads expire after 10 minutes; scheduled cleanup
- **Device token cleanup:** Tokens unused for 1 week are deleted
- **Markdown mail:** Notifications use `markdown()` templates; prefix `mail.` auto-applied
- **Signed URLs:** File serving via signed routes; 24-hour default expiry

## File Statistics

| Directory | Files | Est. LOC |
|-----------|-------|---------|
| app/Models | 30 | 1,700 |
| app/Http/Controllers | 60+ | 4,600 |
| app/Filament | 62 | 4,100 |
| app/Handlers | 15 | 800 |
| app/Jobs | 6 | 400 |
| app/Notifications | 20+ | 1,000 |
| app/Http/Requests | 30+ | 1,200 |
| app/Http/Resources | 25+ | 1,000 |
| routes/ | 4 | 350 |
| database/migrations | 50 | 2,000 |
| resources/views | 25+ | 1,500 |
| **Total** | **400+** | **~22,000** |

