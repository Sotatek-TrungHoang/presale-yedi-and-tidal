# DOMAIN & BUSINESS-LOGIC SCOUT REPORT — yedi-tidal-api (Laravel)

Base path: `/Users/trung.hoang/Desktop/presale-sotatek/agency-brands-ads/source/yedi-tidal-api`

The platform ("Yedi/Tidal") is a two-sided staffing marketplace connecting **Advertisers** (schools/employers who post jobs) and **Applicants** (supply teachers/workers). Yedi is the intermediary that takes a cut of pay via charge percentages, generates invoices to advertisers and payslips to applicants, and enforces compliance gating on applicants. Money uses `brick/money` (GBP). Auditing via `owenit/laravel-auditing` on nearly every model. Admin backend is Filament; mobile/API clients hit `/app/*` routes.

---

## 1. app/Models

All models (except `DeviceToken`, `Settings`, `Reference`) use `SoftDeletes`. Almost all implement `OwenIt\Auditing\Contracts\Auditable`.

### Core marketplace models

**`Advert.php`** — A job posting. The central domain object.
- Casts: `type`→`AdvertType`, `status`→`AdvertStatus`, `advertiser_pay_rate`→`MoneyCast`, `advertiser_pay_rate_type`→`PayType`; datetimes `starts_at/ends_at/apply_by/marked_as_completed_at`; `applicant_charge_percentage`/`advertiser_charge_percentage` floats.
- Relations: `belongsTo(Advertiser)`, `belongsTo(Address)`, `hasMany(Application)`, `hasOne acceptedApplication` (Application where status=Accepted), `hasOne(Invoice)`, `hasOne(Payslip)`, `hasMany(Shift)`, `morphMany(Document, 'owner')`.
- `booted()`: on saving, if `DayToDay` type and status transitions `PendingApproval→Approved`, auto-sets `apply_by = now + day_to_day_active_minutes`.
- Money computed attributes (all `->shouldCache()`): `totalAdvertiserPay`, `advertiserChargeRate`, `advertiserCharge`, `applicantChargeRate`, `applicantCharge`, `applicantPayRate`, `applicantPay`, `profit`. These implement the fee model: applicant pay = advertiser_pay_rate − advertiser_charge − applicant_charge; Yedi profit = totalAdvertiserPay − applicantPay. Hourly multiplies by shift hours; Daily multiplies by shift count.

**`Advertiser.php`** — Employer entity (`ImplementsAddresses`, `ImplementsUploads`; traits `HasAddresses`, `HasUploads`).
- Casts: `compliance_status`→`AdvertiserComplianceStatus`, `profile_status`→`ProfileStatus`, `sign_up_completed_at` datetime.
- `booted()`: on `updated`, when `profile_status`→`Active`, fires `NotifyAdvertiserHandler` with `AccountActiveNotification`.
- Relations: `morphOne(User,'userable')`, `hasMany(Advert)`, `belongsTo(Address)`, `belongsTo(Upload) photograph`, `morphMany(Contract,'owner')`, `hasMany(HeartedApplicant)`.

**`Applicant.php`** — Worker entity (same interfaces/traits as Advertiser).
- Casts: `profile_status`→`ProfileStatus`, `compliance_status`→`ApplicantComplianceStatus`, `qualification`→`ApplicantQualification`, `rating` float.
- `booted()`: same active-notification pattern with `NotifyApplicantHandler`.
- Relations: `morphOne(User)`, `hasMany(Application)`, `belongsToMany(Advert,'applications') appliedAdverts`, `hasMany(Reference)`, `hasMany(DeclarationAgreement)`, `hasOne(RightToWorkDeclaration)`, `hasMany(ApplicantEvidence)`, `hasMany(VideoVerification)` + `belongsTo(VideoVerification)`, `belongsTo(Upload) photograph`, `belongsTo(Upload) evidenceOfId`, `belongsTo(Address)`, `hasMany(Payslip)`, `morphMany(Contract)`, `hasMany(HeartedApplicant)`, `belongsTo(TypeOfWork)`, `belongsTo(JobRole)`. Represents the compliance surface: photo, ID, video verification, references, evidence, declarations, right-to-work.

**`Application.php`** — Join between Applicant and Advert.
- Casts: `status`→`ApplicationStatus`, `actioned_at` datetime. Fields: `applicant_id`, `advert_id`, `status`, `actioned_at`, `rating`.
- Relations: `belongsTo(Applicant)`, `belongsTo(Advert)`.

**`User.php`** — Auth entity (Sanctum `HasApiTokens`, `Notifiable`, Filament `FilamentUser`). Extends `Authenticatable`.
- Casts: `type`→`UserType`, `title`→`UserTitle`, `password`→hashed, `date_of_birth` date, `is_super_admin` bool. Fields include email-change flow (`new_email`, `new_email_code`, `new_email_code_expires_at`).
- `booted()`: composes `name` from first/last on save.
- Relations: `morphTo(userable)` → Advertiser|Applicant; `hasMany(DeviceToken)`.
- Helpers: `canAccessPanel` (admin only), `isAdmin/isSuperAdmin/isAdvertiser/isApplicant`.

### Finance / document models

**`Invoice.php`** — Advertiser billing doc. Casts `sub_total/vat/total`→`MoneyCast`, `due_date` datetime. `booted()`: generates `invoice_number = 'INV'+padLeft(id,6)` post-create. `belongsTo(Advert)`, `belongsTo(Upload)`, `hasMany(InvoiceItem)`.

**`InvoiceItem.php`** — Line item. Casts `rate_type`→`PayType`, `rate`/`amount`→`MoneyCast`, `date` date, `quantity` float. `belongsTo(Invoice)`.

**`Payslip.php`** — Applicant pay doc. `booted()`: `payslip_number = '#'+padLeft(id,6)`. `belongsTo(Advert)`, `belongsTo(Applicant)`, `belongsTo(Upload)`.

**`Contract.php`** — Advertiser/applicant contract. `morphTo(owner)` (Advertiser|Applicant), `belongsTo(Upload)`.

**`Shift.php`** — Individual work session within an advert. Casts `starts_at/ends_at` datetime; appends `hours`. `belongsTo(Advert)`. Computed `minutes` (diff) and `hours` (minutes/60) — drive pay/invoice quantity.

### Compliance models

**`Reference.php`** — Employment reference (no soft-delete). Large form: ratings cast to `ReferenceRating` (8 competency fields), booleans (disciplinary, dismissed, reemploy, under-18 suitability, share consent), `status`→`ReferenceStatus`, dates. `booted()`: assigns `reference_id` UUID on create. `belongsTo(Applicant)`, `belongsTo(Upload)`.

**`RightToWorkDeclaration.php`** — 4 booleans: `right_to_work_uk`, `require_visa_to_work_uk`, `lived_or_worked_outside_uk_6_months`, `has_criminal_convictions_or_prosecutions_pending`. `belongsTo(Applicant)`.

**`Declaration.php`** (`ImplementsUploads`) — Admin-defined declaration template (title, description, time_to_complete, required bool, upload). `belongsTo(Upload)`, `hasMany(DeclarationAgreement)`.

**`DeclarationAgreement.php`** — Applicant's acceptance of a Declaration. `belongsTo(Declaration)`, `belongsTo(Applicant)`.

**`RequiredEvidence.php`** — Admin-defined evidence requirement (title, time_to_complete, required bool). `hasMany(ApplicantEvidence)`.

**`ApplicantEvidence.php`** (`ImplementsUploads`) — Applicant-submitted evidence. `belongsTo(Applicant)`, `belongsTo(RequiredEvidence)`, `belongsTo(Upload)`.

**`VideoVerification.php`** (`ImplementsUploads`) — Selfie-video identity check. `booted()`: generates 6-digit `code` on create (applicant must say the code on camera). `belongsTo(Applicant)`, `belongsTo(Upload)`.

### Infrastructure / shared models

**`Address.php`** — Polymorphic (`morphTo owner`). Casts `country`→`CountryCast` (ISO3166), lat/long floats, `expires_at`. `booted()`: on save (new or changed lines), calls `GetAddressCoordinatesHandler` to geocode; on create sets `expires_at = now+15min` (for orphan cleanup). Attributes: `formatted`, `components`; helper `isSameAs`.

**`Upload.php`** (UUID PK) — File abstraction. `booted()`: sets `expires_at = now+10min` and `uploadedBy` on create; deletes storage directory on delete. `morphTo(owner)`, `belongsTo(User) uploadedBy`, `hasMany(ImageConversion)`. `getUrlAttribute` → signed serve route.

**`ImageConversion.php`** (UUID PK) — Resized/optimized image variant. `belongsTo(Upload)`; deletes file on model delete; signed URL.

**`Document.php`** (`ImplementsUploads`) — Advert attachments. `morphTo(owner)`, `belongsTo(Upload)`.

**`HeartedApplicant.php`** — Advertiser's favourited applicant (soft-deletes). `belongsTo(Advertiser)`, `belongsTo(Applicant)`.

**`DeviceToken.php`** — FCM push token per user (no soft-delete). `last_used` datetime. `belongsTo(User)`.

**`Settings.php`** — Singleton config row (`table=settings`, no soft-delete). Holds `references_required`, `require_teacher_number`, default charge percentages, invoice config (due days, late charge %, payment account details, contact), and `applicant_contract`/`advertiser_contract` wording templates. Only `references_required` + `require_teacher_number` are publicly visible.

**`JobRole.php`** / **`TypeOfWork.php`** (`types_of_work`) — Lookup tables, each `hasMany(Applicant)`.

### Interfaces (`app/Models/Interfaces`)
- `ImplementsAddresses` — requires `addresses(): MorphMany`.
- `ImplementsUploads` — requires `uploads(): MorphMany`.

### Traits (`app/Models/Traits`)
- `HasAddresses` — provides `morphMany(Address,'owner')`.
- `HasUploads` — provides `morphMany(Upload,'owner')`.

---

## 2. app/Enums

All string-backed; most implement Filament `HasLabel`/`HasColor`.

- **`AdvertStatus`**: `PendingApproval='pending_approval'`, `Rejected='rejected'`, `Approved='approved'`, `PendingAllocation='pending_allocation'`, `Filled='filled'`, `NotFilled='not_filled'`.
- **`AdvertType`**: `DayToDay='day_to_day'`, `LongTerm='long_term'`.
- **`ApplicationStatus`**: `Pending='pending'`, `Accepted='accepted'`, `Declined='declined'`, `Cancelled='cancelled'`.
- **`UserType`**: `Admin='admin'`, `Advertiser='advertiser'`, `Applicant='applicant'`.
- **`UserTitle`**: `Mr/Mrs/Miss/Ms/Dr/Prof/Rev/Other`.
- **`ProfileStatus`**: `Incomplete='incomplete'`, `Pending='pending'`, `Active='active'`, `Disabled='disabled'`.
- **`AdvertiserComplianceStatus`**: `Pending='pending'`, `Compliant='compliant'`, `NonCompliant='non_compliant'`.
- **`ApplicantComplianceStatus`**: `Incomplete='incomplete'`, `PendingApproval='pending_approval'`, `Compliant='compliant'`, `NonCompliant='non_compliant'`.
- **`ApplicantQualification`**: `None/GCSE/ALevel='a_level'/Degree/Masters/PhD='phd'/Other`.
- **`ReferenceStatus`**: `Created='created'`, `SentToReferee='sent_to_referee'`, `PendingConfirmation='pending_confirmation'`, `Confirmed='confirmed'`, `Rejected='rejected'`.
- **`ReferenceRating`**: `Unsatisfactory/Satisfactory/Good/Excellent`.
- **`PayType`**: `Daily='daily'`, `Hourly='hourly'`.
- **`ImageConversionType`**: `Thumbnail/Small/Medium/Large` — carries `getOptions(w,h)` returning `ImageConversionOptions` (Thumbnail=128×128 Contain; Small/Medium/Large = longest-edge 500/720/1024 Fill, skips upscaling).

---

## 3. app/Handlers (single-responsibility action classes, invoked from controllers/models/jobs)

**Advertisers/Adverts/**
- `CreateAdvertHandler` — Builds an advert from `CreateAdvertData`: generates per-day `Shift` rows between start/end at the given shift times (rolls end past midnight), derives advert `starts_at/ends_at` from shifts, sets status `PendingApproval`, pulls default charge percentages from `Settings`, associates advertiser + advertiser's address, saves shifts and documents (via `CreateDocumentHandler`). Notifies admins (`NewAdvertCreatedNotification`). Transactional.
- `AcceptApplicationHandler` — Marks application `Accepted`, auto-`Declined`s all other pending applications, sets advert `Filled`. Then notifies accepted applicant (`ApplicationAcceptedNotification`) and each declined applicant.
- `DeclineApplicationHandler` — Marks application `Declined`; if no pending applications remain, sets advert `NotFilled`. Notifies applicant.
- `RateApplicationHandler` — Sets application rating, recomputes applicant's average rating over accepted+rated applications.
- `DeleteAdvertHandler` — Deletes advert documents (+uploads) then the advert, transactionally.

**Applicants/Adverts/**
- `ApplyToAdvertHandler` — Creates a `Pending` application (or revives a previously `Cancelled` one). Notifies advertiser (`NewApplicationNotification`).
- `CancelApplicationHandler` — Sets the applicant's pending application to `Cancelled`.

**References/**
- `RequestReferenceHandler` — Emails the referee (`NewReferenceRequestNotification`, immediate or queued) and sets reference status `SentToReferee`.

**Notifications/** (fan-out helpers, all accept `$notifyNow` flag)
- `NotifyAdminsHandler` — Notifies all `Admin` users.
- `NotifyAdvertiserHandler` — Notifies the advertiser's user (abstracted for future multi-user advertisers).
- `NotifyApplicantHandler` — Notifies the applicant's user.

**Advertisers/Documents/** `CreateDocumentHandler` — Creates a `Document`, associates upload + owner, and back-links the upload's owner.

**Advertisers/SignUp/** `AdvertiserSignUpPagesHandler` / **Applicants/SignUp/** `ApplicantSignUpPagesHandler` — Compute step-by-step sign-up wizard progress (each page: code, title, time_to_complete, complete bool, show_in_overview). Applicant handler dynamically appends pages for references (if `Settings.references_required>0`), each required `RequiredEvidence`, each required `Declaration`, and right-to-work — driving the compliance checklist.

**Settings/** `SettingsResolver` — `resolve()` returns latest `Settings` singleton (`firstOrFail`).

**Addresses/** `GetAddressCoordinatesHandler` — Geocodes an address: first reuses coordinates from an identical existing address; else (if `services.google_maps.enabled`) calls Google Maps geocode via Saloon connector; logs to `google_maps` channel.

**Uploads/**
- `UploadFileHandler` — Stores an `UploadedFile`, creates `Upload`, dispatches `CreateImageConversionsJob` for images.
- `CreateUploadFromDataHandler` — Same but from raw string data (`handle` + `handlePdf` convenience). Used by all PDF-generating jobs.
- `CreateUploadFromGoogleHandler` — Fetches a place photo from Google Maps (FindPlace → GetPlacePhoto) and stores it as an Upload (advertiser default imagery).

Composition: SignUp handlers use `SettingsResolver`; `CreateAdvertHandler` composes `CreateDocumentHandler` + `NotifyAdminsHandler` + `SettingsResolver`; Accept/Decline/Apply handlers compose the Notify* handlers; Google upload handler composes `CreateUploadFromDataHandler`; `Address` model directly calls `GetAddressCoordinatesHandler` in its boot hook.

---

## 4. app/Jobs (all `ShouldQueue`)

All PDF jobs use `DocGenConnector` (Saloon) → `GeneratePdfRequest` (A4 portrait) rendering a Blade view, then `CreateUploadFromDataHandler` to persist the PDF and cross-associate owner. All on queue `documents` except conversions.

- **`CreateAdvertInvoiceJob`** (queue `documents`) — Builds an `Invoice` for an advert: one `InvoiceItem` per shift (qty = hours if Hourly else 1), computes subtotal, VAT (20%), total; sets due date (`Settings.invoice_due_date_days`) and late-charge %; renders `pdfs.invoice`; notifies advertiser (`NewInvoiceNotification`). **Triggered by** `MarkAdvertsAsCompleteCommand` when a `Filled` advert ends.
- **`CreateAdvertPayslipJob`** (queue `documents`) — For the advert's accepted application/applicant, creates `Payslip`, renders `pdfs.payslip`, notifies applicant (`NewPayslipNotification`). **Triggered by** `MarkAdvertsAsCompleteCommand` (same as invoice).
- **`CreateAdvertiserContractJob`** (queue `documents`) — Renders `pdfs.advertiser-contract` using `Settings.advertiser_contract` wording (`{{ADVERTISER_NAME}}` substitution); creates a `Contract` owned by the advertiser. **Triggered by** `AdvertiserSignUpController` on sign-up completion, and `contracts:generate-advertiser` command.
- **`CreateApplicantContractJob`** (queue `documents`) — Same for applicant (`{{APPLICANT_NAME}}`, `pdfs.applicant-contract`, `Settings.applicant_contract`). **Triggered by** `ApplicantSignUpController` on completion, and `contracts:generate-applicant` command.
- **`CreateReferencePdfJob`** (queue `documents`) — Only runs when reference status is `PendingConfirmation`; renders `pdfs.reference`, attaches PDF to the `Reference`. **Triggered by** `Public/ReferenceController::store` when a referee completes the form.
- **`CreateImageConversionsJob`** (queue `conversions`) — For image uploads, records original dimensions, then generates each `ImageConversionType` variant as optimized WebP via Spatie Image, storing `ImageConversion` rows. **Triggered by** `UploadFileHandler` and `CreateUploadFromDataHandler`.

---

## 5. app/Notifications

Organized by audience folders. All concrete notifications extend `AbstractNotification`, implement `ShouldQueue`, use `Queueable`.

**`AbstractNotification`** (`app/Notifications/AbstractNotification.php`) — Base: injects `UrlService` in constructor (so subclasses must call `parent::__construct()`); `subject()` appends `" | {app.name}"`; `markdown()` prefixes template with `mail.`.

**Custom Channel** — **`Channels/FcmChannel`** (Firebase push). `send()`: only for `User` notifiables having an `fcm()` method returning `FcmNotificationData`; loads device tokens `last_used > 1 week ago`; uses `kreait/firebase` (`services.firebase.credentials`) to send `CloudMessage` per token; deletes tokens on `NotFound`/`InvalidMessage`, reports server errors. Notifications opt into push by declaring `via()` = `['mail', FcmChannel::class]` plus an `fcm()` method (e.g. `ApplicationAcceptedNotification`, `NewApplicationNotification`).

By audience:
- **Admin/**: `AdvertiserSignUpCompleteNotification`, `ApplicantSignUpCompleteNotification`, `NewAdvertCreatedNotification`, `NewReferenceProvidedNotification`.
- **Advertiser/**: `AccountActiveNotification`, `AdvertHadNoApplicationsNotification`, `AdvertPendingAllocationNotification`, `NewApplicationNotification` (mail+FCM), `NewInvoiceNotification`.
- **Applicant/**: `AccountActiveNotification`, `ApplicationAcceptedNotification` (mail+FCM), `ApplicationDeclinedNotification`, `NewPayslipNotification`.
- **Common/**: `VerifyNewEmailNotification` (email-change verification code; routed to `AnonymousNotifiable`).
- **Public/**: `NewReferenceRequestNotification` (mail to referee; includes signed `reference.show` URL).

---

## 6. app/DTOs, app/Casts, app/Rules, app/Policies, app/Services, app/Registries/Dropdowns

**DTOs** (Spatie LaravelData)
- `Adverts/CreateAdvertData` — Advert creation payload (type, title, description, start/end, shift times, pay rate/type, apply_by, day_to_day_active_minutes, contact fields, `DocumentData[]`).
- `Documents/DocumentData` — title + `Upload` (mapped from `upload_id`).
- `Dropdowns/DropdownData` — search string + `additional` array (dot-access helpers).
- `Dropdowns/DropdownValue` — label/value/extra tuple returned by dropdown options.
- `Notifications/FcmNotificationData` — title/body/data for push.
- `Uploads/ImageConversionOptions` — width/height/`Fit` for image resizing.

**Casts**
- `MoneyCast` — Eloquent attribute cast: JSON `{amount(minor),currency}` ↔ `Brick\Money`.
- `CountryCast` — alpha2 string ↔ full ISO3166 country array.
- `Data/MoneyCast` — LaravelData cast → `Brick\Money` (GBP, minor optional).
- `Data/EloquentCast` — resolves an id to a Model by the property's typed class.
- `Data/EloquentCollectionCast` — maps ids/objects to a collection of models.
- `Data/EnumCollectionCast` — maps array → collection of enum instances (nullable option).

**Rules**
- `AddressRule` — validates an address id exists and is unowned (or owned by the given owner).
- `UploadRule` — same ownership validation for uploads.
- `CountryRule` — valid ISO 3166-1 alpha-2.
- `TimeRule` — `HH:MM` 24-hour validation.

**Policies**
- `AdvertPolicy` — `viewAny/view` gate on profile status (deny Pending/Disabled); `create` requires advertiser + Active + `Compliant`; `apply` requires applicant + advert `Approved` + not-already-applied + applicant `Compliant`; `cancelApplication` requires a pending application; `delete` allowed only pre-application (PendingApproval/Rejected/Approved-with-no-applications).
- `ApplicationPolicy` — `accept`/`decline` require advertiser owning the advert, application `Pending`, advert `PendingAllocation`, no existing accepted app; `rate` requires status `Accepted`, advert ended, not yet rated.
- `VideoVerificationPolicy` — `update` only by the owning applicant and only while no upload attached yet.

**Services**
- `UrlService` — builds admin-panel (`/admin/...`) URLs (`applicant`, `advertiser`, `advert` helpers); injected into `AbstractNotification`.
- `DeepLinkUrlService` — builds mobile deep-link URLs (e.g. `resetPassword`).

**Registries/Dropdowns** — Pluggable dropdown-options system serving the API's generic dropdown endpoint.
- `DropdownRegistry` — collection of `DropdownOptionInterface` keyed by id (`all/ids/get`).
- `DropdownOptionInterface` — `getId()`, `getResults(DropdownData)`, `authCheck()`.
- `Options/AbstractDropdownOption` — base auth (public vs sanctum user + `allowedTypes` by `UserType`).
- `Options/AbstractEnumDropdownOption` — `getEnumResults()` turns any enum into searchable/sortable `DropdownValue`s.
- Concrete: `DropdownCodesDropdownOption` (lists all registered dropdown ids); `Applicants/JobRolesDropdownOption` (public), `Applicants/QualificationsDropdownOption`, `Applicants/TypesOfWorkDropdownOption`; `Common/CountriesDropdownOption` (ISO3166, cached, GB pinned first); `Users/UserTitlesDropdownOption`.

---

## 7. app/Console/Commands & schedule (`bootstrap/app.php`)

**Adverts/** (lifecycle automation)
- `MarkAdvertsAsCompleteCommand` (`adverts:mark-as-complete`) — **everyMinute**. For adverts past `ends_at` with no `marked_as_completed_at`: marks completed; if status `Filled`, dispatches `CreateAdvertInvoiceJob` + `CreateAdvertPayslipJob`.
- `UpdateApprovedAdvertsStatusesCommand` (`adverts:approved-statuses`) — **everyMinute**. For `Approved` adverts past `apply_by`: if pending applications exist → `PendingAllocation` (+ `AdvertPendingAllocationNotification`), else → `NotFilled` (+ `AdvertHadNoApplicationsNotification`).
- `UpdatePendingAllocationAdvertsStatusesCommand` (`adverts:pending-allocation-statuses`) — **everyMinute**. For `PendingAllocation` adverts past `starts_at` (advertiser never chose) → `NotFilled`.

**Common/**
- `ClearExpiredAddressesCommand` (`common:addresses:clear-expired`) — **everyFiveMinutes**. Force-deletes expired, unowned addresses.
- `ClearExpiredDeviceTokensCommand` (`common:device-tokens:clear-expired`) — **everyFiveMinutes**. Deletes tokens `last_used < 1 week`.
- `ClearExpiredUploadsCommand` (`common:uploads:clear-expired`) — **everyFiveMinutes**. Force-deletes expired, ownerless uploads.
- `PopulateMissingAddressCoordinatesCommand` (`common:addresses:populate-coordinates`) — **not scheduled** (manual backfill of geocodes).

**Contracts/** (not scheduled — manual/ops)
- `GenerateAdvertiserContractsCommand` (`contracts:generate-advertiser`) — dispatchSync `CreateAdvertiserContractJob` for every advertiser.
- `GenerateApplicantContractsCommand` (`contracts:generate-applicant`) — dispatchSync `CreateApplicantContractJob` for every applicant.

---

## 8. Core business lifecycle

### Advert lifecycle (creation → approval → allocation → completion)
1. **Creation** — Advertiser (must be Active + `Compliant`, per `AdvertPolicy::create`) submits `CreateAdvertData`. `CreateAdvertHandler` explodes the date range into `Shift` rows, sets status `PendingApproval`, applies default charge percentages from `Settings`, notifies admins.
2. **Approval** — Admin (Filament) approves → status `Approved` (or `Rejected`). For `DayToDay` adverts, the model's `saving` hook sets `apply_by = now + day_to_day_active_minutes` on the Approved transition.
3. **Applying window** — While `Approved`, compliant applicants apply. `UpdateApprovedAdvertsStatusesCommand` (every minute) closes the window at `apply_by`: → `PendingAllocation` if there are pending applications, else `NotFilled` (advertiser notified either way).
4. **Allocation** — During `PendingAllocation` the advertiser accepts one application (`AcceptApplicationHandler`): application `Accepted`, all others `Declined`, advert `Filled`. If instead all are declined, advert becomes `NotFilled`. `UpdatePendingAllocationAdvertsStatusesCommand` fails the advert to `NotFilled` if `starts_at` passes without a choice.
5. **Completion** — After `ends_at`, `MarkAdvertsAsCompleteCommand` stamps `marked_as_completed_at`; if `Filled`, it dispatches invoice + payslip generation. Post-completion the advertiser can `rate` the accepted applicant (`RateApplicationHandler` recomputes applicant average rating).

### Application flow
`Pending` (on apply, or revived from `Cancelled`) → advertiser `Accepted`/`Declined`, or applicant `Cancelled`. Accepting one advert auto-declines siblings. Enforced by `ApplicationPolicy`/`AdvertPolicy`.

### Compliance gating (applicant onboarding)
Applicant starts `Incomplete`. `ApplicantSignUpPagesHandler` computes required steps: photo, evidence-of-ID, video verification (say the 6-digit `VideoVerification.code` on camera), address, qualification (+ teacher number if `Settings.require_teacher_number`), N references (`Settings.references_required`), each required `RequiredEvidence`, each required `Declaration` (→ `DeclarationAgreement`), and `RightToWorkDeclaration`. On completion the controller sets status `PendingApproval` + `sign_up_completed_at`, dispatches `CreateApplicantContractJob`. Admin then marks `Compliant`/`NonCompliant` in Filament. Only `Compliant` applicants can apply, and only they surface to advertisers/adverts (queries filter on compliance). Editing compliance-relevant profile fields resets status back to `PendingApproval` (`ApplicantProfileController`).

**Reference sub-flow**: applicant adds a `Reference` (`Created`) → `RequestReferenceHandler` emails referee, status `SentToReferee` → referee completes public form (`Public/ReferenceController::store`), status `PendingConfirmation`, admins notified, `CreateReferencePdfJob` dispatched → admin confirms → `Confirmed`/`Rejected`.

### Advertiser onboarding
Advertiser starts compliance `Pending`; completes profile + address + photo (`AdvertiserSignUpPagesHandler`), sets `sign_up_completed_at`, dispatches `CreateAdvertiserContractJob`. Admin marks `Compliant` to allow advert creation. Profile `Active` triggers `AccountActiveNotification`.

### Contracts / invoices / payslips generation
- **Contracts** — Generated from `Settings.{advertiser,applicant}_contract` wording templates with name placeholders, rendered to PDF via DocGen, stored as `Contract`+`Upload`. Triggered on sign-up completion (and bulk backfill commands).
- **Invoices** — Per filled+completed advert: line items per shift, subtotal + 20% VAT + total, due date/late-charge from `Settings`, PDF via `pdfs.invoice`, advertiser notified. Numbered `INV000001`.
- **Payslips** — Per filled+completed advert for the accepted applicant, PDF via `pdfs.payslip`, applicant notified. Numbered `#000001`.
Both invoice + payslip fire together from `MarkAdvertsAsCompleteCommand` once a `Filled` advert ends.

---

### Cross-cutting notes
- **Money model**: `Advert` computed attributes centralize all fee math (advertiser pay → Yedi charges → applicant pay → profit); invoices bill advertisers at `advertiser_pay_rate`, payslips pay applicants at `applicant_pay_rate`. Currency hard-coded GBP.
- **External integrations** (`app/Http/Integrations`, Saloon): `DocGen` (HTML→PDF for all documents), `GoogleMaps` (geocoding + place photos).
- **Auditing**: nearly every model is `Auditable` (owenit) for full change history surfaced in Filament.
