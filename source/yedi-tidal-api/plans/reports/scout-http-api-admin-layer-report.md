# Scout Report: HTTP/API + ADMIN Layer — yedi-tidal-api

Multi-brand Laravel 11 app (Filament v3 admin). Single codebase drives two brands via `APP_CONFIGURATION` (`yedi` | `tidal`); brand-specific labels resolved by the `___()` helper (`app/helpers.php`) pulling from `lang/en/yedi.php` / `lang/en/tidal.php`. Yedi = "Teacher"/"School"; Tidal = "Candidate"/"Brand".

## 1. Routing

### Registration — `bootstrap/app.php`
- `web` group -> `routes/web.php`.
- **`api.php` is commented out / NOT registered** (line: `// api: __DIR__.'/../routes/api.php'`).
- `commands` -> `routes/console.php`; health check at `/up`.
- `then:` closure mounts three API route groups:
  - `routes/app/common.php` — prefix `app/common`, name `common.`, middleware `['api']`.
  - `routes/app/applicant.php` — prefix `app/applicant`, name `applicant.`, middleware `['api','auth:sanctum','user-type:applicant']`.
  - `routes/app/advertiser.php` — prefix `app/advertiser`, name `advertiser.`, middleware `['api','auth:sanctum','user-type:advertiser']`.
  - Local-only `GET /testing`.
- Middleware config: alias `user-type => UserTypeMiddleware`; `DeviceTokenMiddleware` appended to `api` group globally.
- Exceptions handed to Sentry. Schedule registers Common cleanup commands (every 5 min) and Advert status commands (every minute).

### `routes/web.php`
- Group `reference.` prefix `/reference/{reference:reference_id}`, middleware `['signed']`, controller `Public\ReferenceController`:
  - `GET /` -> `index`, name `reference.show`
  - `POST /` -> `store`, name `reference.store`
- `GET /` -> closure returning `landing-yedi` or `landing-tidal` view based on `config('app.configuration')`.

### `routes/app/common.php` (prefix `app/common`, name `common.`)
| Method | Path | Handler | Name | Auth |
|---|---|---|---|---|
| GET | `/` | closure ("Common") | — | api |
| POST | `auth/login` | `AuthController@login` | `auth.login` | public |
| POST | `auth/forgot-password` | `AuthController@forgotPassword` | `auth.forgot-password` | public |
| POST | `auth/reset-password` | `AuthController@resetPassword` | `auth.reset-password` | public |
| GET | `auth/user` | `AuthController@user` | `auth.user` | sanctum |
| POST | `uploads` | `UploadController@store` | — | sanctum |
| POST | `uploads/from-google` | `UploadController@storeFromGoogle` | — | sanctum |
| POST | `change-email/request` | `ChangeEmailController@requestEmailChange` | `change-email.request` | sanctum |
| POST | `change-email/verify-code` | `ChangeEmailController@verifyCode` | `change-email.verify` | sanctum |
| POST | `change-password` | `ChangePasswordController` (invokable) | `change-password` | sanctum |
| POST | `delete-account` | `DeleteAccountController` (invokable) | `delete-account` | sanctum |
| POST | `dropdowns` | `DropdownController` (invokable) | `dropdowns` | public |
| GET | `uploads/{upload}` | `UploadController@serve` | `uploads.serve` | signed URL |
| GET | `image-conversions/{imageConversion}` | `ImageConversionController@serve` | `image-conversions.serve` | signed URL |
| GET | `settings` | `SettingsController` (invokable) | `settings` | public |

### `routes/app/applicant.php` (prefix `app/applicant`, name `applicant.`, sanctum + user-type:applicant)
- `GET /` closure ("Applicant").
- **Sign-up** (`ApplicantSignUpController`, prefix `sign-up`, name `sign-up.`):
  - `GET pages` -> `pages` (middleware stripped: no auth)
  - `POST create-profile` -> `createProfile` (auth stripped)
  - `POST submit-compliance` -> `submitCompliance`
  - `POST submit-address` -> `submitAddress`
  - `POST submit-qualifications` -> `submitQualifications`
  - `POST submit-references` -> `submitReferences`
  - `POST submit-evidence/{requiredEvidence}` -> `submitEvidence`
  - `POST agree-to-declaration/{declaration}` -> `agreeToDeclaration`
  - `POST submit-right-to-work-declaration` -> `submitRightToWorkDeclaration`
  - `POST complete-sign-up` -> `completeSignUp`
  - `POST cancel-sign-up` -> `cancelSignUp`
- `apiResource required-evidence` (show only) -> `RequiredEvidenceController@show`
- `apiResource declarations` (show only) -> `DeclarationController@show`
- `apiResource references` (index only) -> `ReferenceController@index`
- **Profile** (`ApplicantProfileController`, prefix `profile`): `GET /` index; `POST update-profile`; `update-compliance`; `update-address`; `update-qualifications`; `update-evidence/{requiredEvidence}`; `agree-to-declaration/{declaration}`; `update-right-to-work-declaration`.
- **Adverts** (`Applicant\AdvertsController`, prefix `adverts`): `GET /` index; `GET {advert}` show; `POST {advert}/apply`; `POST {advert}/cancel-application`.
- **Bookings** (`BookingsController`, prefix `bookings`): `GET confirmed`; `GET applied-to`.
- **Video verifications** (`VideoVerificationController`, prefix `video-verifications`): `POST /` store; `POST {videoVerification}/submit`.
- `apiResource payslips` (index) -> `PayslipsController@index`
- `apiResource contracts` (index) -> `Applicant\ContractsController@index`
- Note: `ReferenceController@store` (`CreateReferenceRequest`) exists but is NOT wired to a route in applicant.php (only `index` via apiResource). Store appears unused/legacy.

### `routes/app/advertiser.php` (prefix `app/advertiser`, name `advertiser.`, sanctum + user-type:advertiser)
- `GET /` closure ("Advertiser").
- **Sign-up** (`AdvertiserSignUpController`, prefix `sign-up`): `GET pages` (auth stripped); `POST create-profile` (auth stripped); `POST submit-address`; `POST submit-photograph`; `POST complete-sign-up`; `POST cancel-sign-up`.
- **Profile** (`AdvertiserProfileController`, prefix `profile`): `POST update-profile`; `POST update-address`.
- **Adverts** (`Advertiser\AdvertsController`, prefix `adverts`): `GET /` index; `POST /` store; `GET {advert}` show; `DELETE {advert}` destroy; `GET {advert}/applications` -> `AdvertApplicationsController@index`.
- **Applications** (`ApplicationsController`, prefix `applications`): `GET /` index.
- `POST applications/{application}/accept` -> `AdvertApplicationsController@accept`
- `POST applications/{application}/decline` -> `AdvertApplicationsController@decline`
- `POST applications/{application}/rate` -> `AdvertApplicationsController@rate`
- `GET applicants` -> `HeartedApplicantsController@index`
- `POST applicants/{applicant}/heart` -> `HeartedApplicantsController@heart`
- `POST applicants/{applicant}/unheart` -> `HeartedApplicantsController@unheart`
- `apiResource invoices` (index) -> `InvoicesController@index`
- `apiResource contracts` (index) -> `Advertiser\ContractsController@index`

### `routes/api.php` (unregistered)
- `GET /user` -> closure returning `$request->user()`, middleware `auth:sanctum`. Dead code (group not mounted).

## 2. Controllers (`app/Http/Controllers`)

Base `Controller.php` provides JSON envelope helpers: `stdResponse`, `stdSuccess`, `stdError` (wraps `{data, message}`). Uses `Spatie\LaravelData\Optional` to omit message when unset.

Traits (`app/Http/Controllers/Traits/`):
- `AdvertiserPortalTrait::getAdvertiser()` — resolves `Auth::user()->userable` as `Advertiser` (throws if not).
- `ApplicantPortalTrait::getApplicant()` — same for `Applicant`.

### Advertiser folder
- **AdvertApplicationsController** — `index(Advert)` lists applications (Gate `view`); `accept`/`decline` delegate to `AcceptApplicationHandler`/`DeclineApplicationHandler` (Gates `accept`/`decline`); `rate` delegates to `RateApplicationHandler` (`RateApplicationRequest`).
- **AdvertiserProfileController** — `updateProfile` (`UpdateProfileRequest`, associates photograph Upload); `updateAddress` (`Common\UpdateAddressRequest`, diffs via `isSameAs`). Inline DB transactions, no handler.
- **AdvertiserSignUpController** — DI: `AdvertiserSignUpPagesHandler`, `NotifyAdminsHandler`. `pages` computes step completion + current index; `createProfile` creates Advertiser+User+Sanctum token; `submitAddress`; `submitPhotograph`; `completeSignUp` (validates all steps, sets compliance Pending/profile Pending, notifies admins via `AdvertiserSignUpCompleteNotification`, dispatches `CreateAdvertiserContractJob`); `cancelSignUp` (cascade-deletes, soft-anonymizes user).
- **AdvertsController** — DI `CreateAdvertHandler`, `DeleteAdvertHandler`. `index` (`ListAdvertsRequest`, filters by type + advertiser); `show` (Gate); `store` (maps to `CreateAdvertData` DTO -> handler); `destroy` (Gate + handler).
- **ApplicationsController** — `index` (`ListApplicationsRequest`, Gate `viewAny`, optional status filter).
- **ContractsController / InvoicesController / HeartedApplicantsController** — read-only listing scoped to advertiser. HeartedApplicants adds `heart` (guards that applicant applied to one of advertiser's adverts, `updateOrCreate` withTrashed) and `unheart`.

### Applicant folder
- **AdvertsController** — DI 3 handlers. `index` (`ListAdvertsRequest`; only Approved adverts of Compliant advertisers); `show` (Gate); `apply` -> `ApplyToAdvertHandler` (Gate); `cancelApplication` -> `CancelApplicationHandler` (Gate).
- **ApplicantProfileController** — DI `SettingsResolver`. `index` builds home-screen "blocks" (references/evidence/declarations/RTW completion). Private `needToResetCompliance()` flips status to `PendingApproval` when key fields dirty. Update methods: `updateProfile`, `updateCompliance`, `updateAddress`, `updateQualifications`, `updateEvidence/{requiredEvidence}`, `agreeToDeclaration/{declaration}`, `updateRightToWorkDeclaration`. All inline DB transactions.
- **ApplicantSignUpController** — DI: `ApplicantSignUpPagesHandler`, `NotifyAdminsHandler`, `RequestReferenceHandler`. Mirrors advertiser sign-up plus `submitCompliance` (photograph + evidence + video verification), `submitQualifications`, `submitReferences` (deletes+recreates), `submitEvidence`, `agreeToDeclaration`, `submitRightToWorkDeclaration`. `completeSignUp` fires `RequestReferenceHandler` per reference + `ApplicantSignUpCompleteNotification` + `CreateApplicantContractJob`.
- **BookingsController** — `confirmed` (adverts with accepted application), `appliedTo` (applied, not cancelled/accepted).
- **ContractsController / PayslipsController** — read-only listing scoped to applicant.
- **DeclarationController** — `show` returns `DeclarationResource`.
- **ReferenceController** — DI `RequestReferenceHandler`. `index` lists references; `store` creates a Reference + fires handler (route not registered).
- **RequiredEvidenceController** — `show`.
- **VideoVerificationController** — `store` (creates empty VideoVerification, clears prior unlinked); `submit` (associates uploaded video).

### Common folder
- **AuthController** — `login` (email/password, Sanctum token), `user`, `forgotPassword` (`Password::sendResetLink`), `resetPassword` (marks email verified on reset).
- **ChangeEmailController** — `requestEmailChange` (6-digit code, 10-min expiry, notifies new email via `VerifyNewEmailNotification`), `verifyCode`.
- **ChangePasswordController** — invokable; re-hashes password.
- **DeleteAccountController** — invokable; anonymizes user + cascade-deletes Applicant/Advertiser related records, returns 204.
- **DropdownController** — invokable; resolves option from `DropdownRegistry`, `authCheck()`, returns `DropdownCollection`. Uses `DropdownData` DTO.
- **ImageConversionController / UploadController** — `serve` methods require `hasValidSignature()` (401 otherwise), stream from disk. UploadController `store` (`UploadFileRequest` -> `UploadFileHandler`), `storeFromGoogle` (`UploadFromGoogleRequest` -> `CreateUploadFromGoogleHandler`, Google Places photo).
- **SettingsController** — invokable; returns resolved Settings.

### Public folder
- **ReferenceController** — DI `NotifyAdminsHandler`. `index` returns `reference-form` blade (or `reference-form-complete` if already actioned; 404 if status Created). `store` (`CompleteReferenceRequest`) fills reference, sets `PendingConfirmation`, notifies admins (`NewReferenceProvidedNotification`), dispatches `CreateReferencePdfJob`, returns completion view. Accessed only via signed URLs.

## 3. Requests & Resources

### Requests (`app/Http/Requests`) — organized by audience/feature: `Advertiser/{Adverts,Applications,Profile,SignUp}`, `Applicant/{Adverts,Profile,SignUp,VideoVerification}`, `Common/{Auth,ChangeEmail,ChangePassword,Dropdowns,Profile,Uploads}`, `Public`.
Notable patterns:
- Method-injected dependencies in `rules()` (e.g. `SubmitReferencesRequest(SettingsResolver)`, `DropdownRequest(DropdownRegistry)`).
- Config-conditional rules: `CompleteReferenceRequest` adds Yedi-only rating fields (`ReferenceRating` enum) and conditional `would_reemploy_reason`.
- Type-conditional rules: `CreateAdvertRequest` adds `day_to_day_active_minutes` (DayToDay) or `apply_by` (LongTerm); `authorize()` calls `Gate::authorize('create', Advert::class)`.
- Custom rules used: `App\Rules\UploadRule` (ownership-scoped upload validation), `App\Rules\TimeRule`.
- `authorize()` used for policy checks: `CompleteReferenceRequest` allows only when status `SentToReferee`.
- `CreateProfileRequest` conditionally requires email/password only when unauthenticated (upgrade-in-place flow).
- Enum validation via `Illuminate\Validation\Rules\Enum`; `Password::default()`.

### Resources (`app/Http/Resources`) — grouped: `Advertisers`, `Adverts`, `Applicants/{Declarations,Evidence,HeartedApplicants,JobRoles,References,RightToWorkDeclarations,TypesOfWork,VideoVerifications}`, `Applications`, `Common/{Addresses,Documents,Dropdowns,Uploads}`, `Contracts`, `Invoices`, `Payslips`.
Notable patterns:
- Enums serialized as both `x` (value) and `x_label` (via `getLabel()`/`label()`).
- Audience-aware payloads via `mergeWhen($user->type === UserType::...)` — `AdvertResource` exposes advertiser pay rates + contact only to Advertiser, applicant pay + own application to Applicant (contact revealed only if accepted).
- `AuthUserResource` conditionally embeds a nested `applicant` or `advertiser` object based on `userable` type.
- `MoneyResource` wraps `Brick\Money\Money` -> `{display, currency, amount, minor_amount}`.
- Collections (`*Collection.php`) paired with singular resources.

## 4. Middleware (`app/Http/Middleware`)
- **UserTypeMiddleware** (`user-type` alias) — param `$userType`; 401 if unauthenticated or missing type; 403 with brand-localized message if type mismatches (Admin/Advertiser/Applicant).
- **DeviceTokenMiddleware** (appended to `api` group globally) — reads `X-FCM-Token` header; if no user, deletes token; else `updateOrCreate` `DeviceToken` (user_id, last_used) and merges `fcm_device_token` into request. FCM push registration.

## 5. Integrations (Saloon) — `app/Http/Integrations`
- **DocGen** (`DocGenConnector`) — base URL `config('services.docgen.url')`; `BasicAuthenticator` (username/password from `services.docgen.*`, only if both set); `AcceptsJson`, `AlwaysThrowOnErrors`. `Requests/GeneratePdfRequest` — POST `/`, JSON body `{html, landscape, format=A4}`; setters for landscape/format. (HTML-to-PDF service backing contract/invoice/payslip/reference PDFs.)
- **GoogleMaps** (`GoogleMapsConnector`) — base URL `https://maps.googleapis.com/maps/api/`; `tries=1`; default query `key` from `services.google_maps.api_key`. Requests:
  - `GeocodeRequest` — GET `geocode/json`, query `address`; Cacheable (Laravel cache, 5 min); fail unless status OK/ZERO_RESULTS.
  - `FindPlaceRequest` — GET `place/findplacefromtext/json`, `input`/`inputtype=textquery`/`fields=photo`; Cacheable (5 min).
  - `GetPlacePhotoRequest` — GET `place/photo`, `photoreference` + `maxwidth=1200` (not cached).

## 6. Filament Admin — `app/Filament` + `app/Providers/Filament/AdminPanelProvider.php`

### Panel config (`AdminPanelProvider`)
- Default panel id `admin`, path `/admin`.
- `brandName(___('brand'))`, primary color `___('brand_colour')` — brand-driven.
- `->login()`, `->profile(isSimple: false)`.
- Auto-discovers Resources/Pages/Widgets; explicitly registers `Pages\Dashboard`.
- `sidebarFullyCollapsibleOnDesktop(true)`, `maxContentWidth(Full)`.
- Standard session/cookie/CSRF middleware; auth middleware `Authenticate`.
- `register()` injects `@vite('resources/js/app.js')` at body end.

### Resources
Primary (navigation sorted):
- **AdvertiserResource** (sort 10, brand icon `advertiser-icon`) — label `___('advertiser')`. `canEdit` false when profile Incomplete. Global search (name/email/user/address). Pages: List/Create/View/Edit. Relation: `AdvertsRelationManager`.
- **AdvertResource** (sort 20, `newspaper`) — full form (details, documents repeater, payment & charges, faker "fill" action local-only). Table with applications_count. Relation: `ApplicantsRelationManager`. Pages List/Create/Edit/View.
- **ApplicantResource** (sort 30, `user-group`) — form switches Create/Edit schema; infolist from `ViewApplicant`. `canEdit` gated on profile status. Global search. Relation: `ApplicationsRelationManager`.
- **ApplicationResource** (sort 40, `inbox-stack`) — form (applicant/advert/status/actioned_at), infolist. Pages List/Create/Edit/View.
- **InvoiceResource** (sort 70, `document-currency-pound`) — `canCreate` false; list-only; download links; global search + result actions.
- **PayslipResource** (sort 70, `credit-card`) — `canCreate` false; list-only; links to advert/applicant; global search.

Settings group:
- **DeclarationResource** — CRUD, file upload (`UploadFileHandler`), `required` toggle.
- **RequiredEvidenceResource** — list-only page (title/time/required).
- **JobRoleResource**, **TypeOfWorkResource** — simple name CRUD (list page only).

Admin group / hidden:
- **UserResource** (`Admin` group) — `canAccess` = `isSuperAdmin()`; table filtered to `type=Admin` & non-super-admin.
- **AddressResource** — `canAccess()` false (form schema reused via `getFormSchema()` by other resources' create-option forms).
- **UploadResource** — `canAccess()` false (create page only; edit commented out).

### Custom Pages
- **System.php** (`app/Filament/Pages/System.php`) — Settings group, `/settings` view (`resources/views/filament/pages/settings.blade.php`). Edits singleton `Settings`: references_required, default charge %, teacher-number toggle (Yedi-only), invoice config (due days, late charge, bank account, contact), and `applicant_contract`/`advertiser_contract` rich-editor templates using custom `RichEditorTemplateStrings` component with `{{APPLICANT_NAME}}`/`{{ADVERTISER_NAME}}` template items.

### Widgets (`app/Filament/Widgets`)
- **Dashboard.php** — stats overview: advertisers (active/pending), applicants (active/pending), non-compliant applicant count, adverts (completed/not-filled).
- **ExpenditureOverview.php** — money stats (total income, expenditure, advertiser/applicant charges, profit) from completed+filled adverts via `Brick\Money`.
- `_AdvertiserComplianceChart.php`, `_AdvertiserStatusChart.php`, `_ApplicantsChart.php` — underscore-prefixed (disabled from auto-discovery).

### Infolists
- **VideoEntry.php** (`app/Filament/Infolists/Components/VideoEntry.php`) — custom Entry rendering `infolists.components.video` blade (video player in applicant identification tab).

### Admin workflows
- **Applicant compliance review** — `ViewApplicant` (`app/Filament/Resources/ApplicantResource/Pages/ViewApplicant.php`): tabbed infolist (Personal, Identification [photo/ID/video verification], Work [references, RTW declaration, declaration agreements, required evidence], Contracts). Header actions: "Update Status" (sets `profile_status` + `compliance_status`), "Update References". `EditApplicant` provides full editable schema incl. declaration checkbox sync and evidence repeater. `ListApplicants` tabs: All / Compliant / Non-Compliant / Incomplete / Pending Approval — the compliance review queue.
- **Advertiser compliance/approval** — `ViewAdvertiser` "Update Status" action; `ListAdvertisers` tabs All/Compliant/Non-Compliant/Pending. `AdvertsRelationManager` tabs by advert status incl. Approved / Pending Approval / Rejected — the advert approval workflow.
- **Advert application management** — `ApplicantsRelationManager` on AdvertResource tabs by application status (accepted/cancelled/declined/pending).
- Compliance/approval statuses driven by enums: `ApplicantComplianceStatus`, `AdvertiserComplianceStatus`, `AdvertStatus`, `ProfileStatus`, `ApplicationStatus`.

## 7. Providers (`app/Providers`)
- **AppServiceProvider** — `register()`: builds `dropdown-options` container tag by reflection-scanning `app/Registries/Dropdowns/Options/` for `DropdownOptionInterface` implementors; binds singletons `UrlService`, `DeepLinkUrlService` (deeplink base = `config('app.deeplink_url')`), `DropdownRegistry`. `boot()`: globally sets Filament DatePicker/DateTimePicker/Select `native(false)`; customizes `ResetPassword::createUrlUsing` to produce a deeplink URL via `DeepLinkUrlService`.
- **HorizonServiceProvider** — `gate()` defines `viewHorizon` allowing only `$user->isAdmin()`. Notification routing hooks present but commented.
- **AdminPanelProvider** — see §6.

## 8. Views (`resources`)
- **Landing pages**: `landing-yedi.blade.php` (beige `#F0E4D4`, Yedi logo) and `landing-tidal.blade.php` (black bg, Tidal logo) — self-contained inline-styled brand splash, selected by `config('app.configuration')`.
- **Public reference form**: `reference-form.blade.php` (417 lines; inline brand SVG logos per config, Tailwind via `@vite`, signature pad via `resources/js/app.js`), `reference-form-complete.blade.php` (confirmation). Yedi variant adds teaching rating fields.
- **PDF templates** (`resources/views/pdfs/`, rendered to PDF via DocGen): `advertiser-contract.blade.php`, `applicant-contract.blade.php`, `invoice.blade.php`, `payslip.blade.php`, `reference.blade.php`, plus shared `components/header.blade.php`.
- **Mail** (`resources/views/mail/`): admin (advertiser/applicant sign-up complete, new advert, new reference), advertiser (account active, advert had no applications, pending allocation, new application, new invoice), applicant (account active, application accepted/declined, new payslip), common (verify-new-email), public (new-reference-request). Vendor mail theme overrides in `resources/views/vendor/mail/`.
- **Filament**: `filament/pages/settings.blade.php` (System page form), `forms/components/rich-editor-template-strings.blade.php` (custom RichEditorTemplateStrings component), `infolists/components/video.blade.php` (VideoEntry).
- **Assets**: `resources/css/app.css` (Tailwind directives only), `resources/js/app.js` (SignaturePad wiring for reference form: signature capture, would_reemploy conditional field, resize handling), `resources/js/bootstrap.js`.

### Brand config reference
- `config/app.php`: `configuration` = `env('APP_CONFIGURATION','yedi')`; `deeplink_url` = `env('APP_DEEPLINK_URL')`.
- Brand token files `lang/en/yedi.php` / `lang/en/tidal.php` define `brand`, `brand_colour`, `applicant`, `advertiser`, `advertiser-icon`, `advert` labels consumed by `___()` throughout controllers, Filament resources, and views.
