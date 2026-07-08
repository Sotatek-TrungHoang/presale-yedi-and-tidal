# Codebase Summary — Yedi+Tidal App

## Repo Structure

```
yedi-tidal-app/
├── lib/                       # Main Dart source (~22.4k LOC, 295 files)
│   ├── main.dart              # Entry point: Env validation, Firebase init, get_it setup
│   ├── app.dart               # Root widget: MultiRepositoryProvider, AuthenticationBloc
│   ├── firebase_options.dart  # Generated per-flavor Firebase config
│   ├── l10n/
│   │   ├── app_localizations.dart  # Generated localization strings
│   │   ├── yedi/intl_en.arb        # Yedi brand strings
│   │   └── tidal/intl_en.arb       # Tidal brand strings
│   ├── modules/               # Feature modules
│   │   ├── adverts/           # Advert CRUD + applications + bookings
│   │   ├── api/               # HTTP layer (Dio ApiService, exceptions, responses)
│   │   ├── authentication/    # Login/signup/logout, auth state, user model
│   │   ├── common/            # Shared services (account, dropdown, settings, email/password)
│   │   ├── documents/         # Document upload/management
│   │   ├── forgot_password/   # Password recovery flow
│   │   ├── hearted_applicants/# Favorited candidates
│   │   ├── login/             # Login UI + flows
│   │   ├── profile/           # Profile management (both roles)
│   │   ├── reset_password/    # Password reset flow
│   │   └── sign_up/           # Signup wizard, compliance, evidence, declarations
│   ├── pages/                 # Screen widgets
│   │   ├── router.dart        # go_router config + auth guard
│   │   ├── splash/            # Splash screen
│   │   ├── landing/           # Unauthenticated landing
│   │   ├── login/             # Login page + forgot/reset password
│   │   ├── sign_up/           # Multi-step signup wizard
│   │   ├── home/
│   │   │   ├── applicant/     # Applicant home + role-specific screens
│   │   │   └── advertiser/    # Advertiser home + role-specific screens
│   │   └── logout/            # Logout confirmation
│   ├── ui/                    # Shared UI components
│   │   ├── theme/
│   │   │   ├── app_theme.dart      # Runtime flavor branching for theme
│   │   │   ├── yedi_theme.dart     # Yedi colors, icons, border radius
│   │   │   └── tidal_theme.dart    # Tidal colors, icons, border radius
│   │   ├── auth_providers.dart     # ApplicantAuthProviders, AdvertiserAuthProviders
│   │   ├── inputs/                 # Reusable input widgets (text, date, time, dropdown, etc.)
│   │   ├── adverts/                # Shared advert display widgets
│   │   ├── profile/                # Profile UI components
│   │   ├── settings/               # Settings UI components
│   │   ├── applicant_scaffold.dart # Applicant shell scaffold + bottom nav
│   │   └── advertiser_scaffold.dart# Advertiser shell scaffold + bottom nav
│   └── util/                  # Utilities
│       ├── env.dart           # Env.baseUrl, Env.googleMapsApiKey from --dart-define-from-file
│       ├── firebase.dart      # Firebase utilities + appFlavor detection
│       ├── forms.dart         # Form validation helpers
│       ├── validator.dart     # Field validators (email, phone, etc.)
│       ├── toast.dart         # showErrorToast, showSuccessToast
│       ├── dates.dart         # Date formatting, parsing
│       ├── strings.dart       # String utilities
│       ├── data_types.dart    # Enums, type helpers
│       └── models.dart        # Wrapped<T> for nullable copyWith
├── test/                      # Tests
│   ├── unit_test.dart         # Unit tests
│   └── widget_test.dart       # Widget tests
├── android/                   # Android native config
│   ├── app/
│   │   ├── build.gradle       # Product flavors (yedi, tidal), flutter_env_native integration
│   │   └── src/
│   │       └── main/AndroidManifest.xml
│   └── ...
├── ios/                       # iOS native config
│   ├── Runner.xcodeproj/
│   └── Runner/
├── assets/                    # Flavor-specific assets
│   ├── images/                # Shared images
│   ├── yedi/                  # Yedi brand assets (logo, icons, etc.)
│   └── tidal/                 # Tidal brand assets
├── scripts/                   # Build & generation scripts
│   ├── pre_yedi.sh            # Run flutterfire + l10n for Yedi
│   ├── pre_tidal.sh           # Run flutterfire + l10n for Tidal
│   ├── flutterfire_config_yedi.sh    # Generate firebase_options.dart for Yedi
│   ├── flutterfire_config_tidal.sh   # Generate firebase_options.dart for Tidal
│   ├── generate_localizations_yedi.sh
│   ├── generate_localizations_tidal.sh
│   ├── generate_app_icons.sh  # flutter_launcher_icons
│   └── build/
│       ├── yedi.sh            # Build appbundle for Yedi
│       └── tidal.sh           # Build appbundle for Tidal
├── .env.yedi                  # Yedi: BASE_API_URL, GOOGLE_MAPS_API_KEY
├── .env.tidal                 # Tidal: BASE_API_URL, GOOGLE_MAPS_API_KEY
├── pubspec.yaml               # Package info, dependencies, assets
├── flutter_launcher_icons-yedi.yaml   # Icon config for Yedi
├── flutter_launcher_icons-tidal.yaml  # Icon config for Tidal
├── l10n.yaml                  # (Commented/absent; scripts hardcode args)
├── analysis_options.yaml      # Lints config (avoid_print, constant_identifier_names disabled)
├── CLAUDE.md                  # Developer guide (architecture, commands, conventions)
└── README.md                  # Project intro (to be updated)
```

## Module Breakdown (lib/modules/)

### api/
HTTP client layer. Single `ApiService` (Dio-based) with interceptors.
- `api.dart` — ApiService class, get/post/postFormData/put/patch/delete methods
- `api_exceptions.dart` — APIException, APIValidationException
- `api_responses.dart` — Generic response envelope structures

### authentication/
Auth state & user model.
- `bloc/authentication_bloc.dart` — BLoC managing login, logout, user refresh
- `bloc/authentication_state.dart` — AuthenticationStatus (unknown, authenticated, unauthenticated)
- `models/auth_user_model.dart` — AuthUserModel, AuthUserApplicantModel, AuthUserAdvertiserModel + sub-models
- `services/authentication_service.dart` — API calls for login, signup, logout, getCurrentUser

### adverts/
Two-sided advert/application management.
- `services/advertiser_advert_service.dart` — Advertiser: create, delete, list adverts; manage applications
- `services/applicant_advert_service.dart` — Applicant: list adverts, apply, manage applications, bookings
- `cubits/` — Multiple cubits: apply_application, accept_application, decline_application, rate_application, create_advert, delete_advert, heart_applicant, advert_detail_bloc, list_adverts_cubit, list_applications_cubit, list_bookings_cubit
- `models/` — AdvertModel, ApplicationModel, BookingModel, etc.

### profile/
Profile management for both roles.
- `service/profile_service.dart` — Applicant profile updates
- `service/advertiser_profile_service.dart` — Advertiser profile updates
- `service/references_service.dart` — Manage applicant references
- `models/` — ProfileModel variants

### sign_up/
Multi-step signup & compliance workflow.
- `services/evidence_service.dart` — Manage compliance evidence uploads
- `services/declaration_service.dart` — Manage compliance declarations
- `cubits/` — Signup flow management
- `models/` — DeclarationModel, RequiredEvidenceModel, RightToWorkDeclarationModel, VideoVerificationModel

### common/
Shared services across roles.
- `services/account_service.dart` — Account info retrieval
- `services/change_email_service.dart` — Email change flow
- `services/change_password_service.dart` — Password change flow
- `services/dropdown_service.dart` — Fetch dropdown options (job roles, type of work, etc.)
- `services/settings_service.dart` — App settings (delete account, preferences, etc.)

### Other Modules
- **login/** — Login page & bloc
- **forgot_password/** — Forgot password recovery
- **reset_password/** — Password reset (requires email + token in URL)
- **documents/** — Document upload/storage
- **hearted_applicants/** — Favorites management

## State Management Pattern

**Architecture:** `flutter_bloc` with feature-scoped services.

1. **DI Setup (main.dart, app.dart):**
   - `get_it.registerSingleton<ApiService>()` — HTTP client
   - `get_it.registerSingleton<SharedPreferences>()` — Token cache
   - `get_it.registerSingleton<FirebaseToken>()` — FCM token
   - `RepositoryProvider.value(authenticationService)` — Auth service
   - `RepositoryProvider.value(advertiserAdvertService)` — Advert services
   - All feature services provided via `RepositoryProvider` in `app.dart`

2. **Auth State (always-on):**
   - Single `AuthenticationBloc` in `MultiBlockProvider`
   - Listens for auth changes; refreshes `go_router` on state change
   - Provides user state to all screens

3. **Feature BLOCs/Cubits:**
   - Provided via `BlocProvider` in screen/page level
   - Consume `RepositoryProvider<Service>()` to call business logic
   - Emit state changes to update UI

## Routing (lib/pages/router.dart)

`go_router` with central auth guard in `redirect()`.

**Three navigation zones:**
1. **Unauthenticated** — Landing, login, forgot/reset password, signup
2. **Applicant** — ShellRoute with `ApplicantScaffold`, bottom nav, role-home + detail pages
3. **Advertiser** — ShellRoute with `AdvertiserScaffold`, bottom nav, role-home + detail pages

**Auth Guard Logic:**
- `unknown` status → splash (waiting for auth resolve)
- `unauthenticated` → `/landing`
- `authenticated` but `signUpCompletedAt == null` → `/sign-up`
- `authenticated` + signup complete + unauthenticated route → redirect to role-home
- Cross-role access → error toast + redirect home

## Theming & Branding (lib/ui/theme/)

**Runtime branching on `appFlavor`:**
```dart
final appTheme = appFlavor == 'tidal' ? tidalTheme : yediTheme;
final appColours = appFlavor == 'tidal' ? tidalColours : yediColours;
```

**Per-flavor theme includes:**
- `ThemeData` (Material theme)
- `AppColours` — landingIconBg, splashBackground, background, accent, primary, canvasBackground, bottomNavBackground, success, error
- `AppIcons` — applicant, advertiser icon choices
- `BorderRadius` — tidalBorderRadius vs yediBorderRadius

**Assets:** `assets/$appFlavor/logo.svg`, etc. resolved at runtime.

## Key Design Decisions

1. **Single Codebase, Dual Flavor:** Avoids duplication; branching via `appFlavor` & environment files.
2. **Compliance-First Onboarding:** Rich data model gates profile activation; matches strictness requirements.
3. **Role-Specific Routing:** Separate `ShellRoute`s + navigator keys prevent cross-role contamination.
4. **Feature-Scoped Services:** Each module owns its HTTP calls; promotes isolation & testability.
5. **Centralized Auth Guard:** Single `redirect` function in `go_router` == single source of truth for access control.
6. **Per-Flavor Generated Files:** Firebase config + localization strings regenerated per build to prevent config mismatches.

## File Statistics

- **Dart files:** 295
- **Total LOC:** ~22,400
- **Largest module:** adverts (many cubits, role-specific services)
- **Generated files:** `firebase_options.dart`, `app_localizations.dart` (DO NOT edit; regenerate via scripts)

## Dependencies (pubspec.yaml v1.0.5+26)

| Dependency | Use |
|------------|-----|
| flutter_bloc | State management |
| get_it | Service locator / DI |
| go_router | Navigation + routing |
| dio | HTTP client |
| firebase_core, firebase_messaging | Push notifications, platform config |
| google_maps_flutter | Maps display & candidate search |
| google_fonts | Font rendering |
| flutter_svg | SVG asset support |
| shared_preferences | Auth token persistence |
| camera, image_picker, file_picker | File uploads (compliance docs, photos) |
| video_player | Video playback (video verification) |
| flutter_libphonenumber | Phone number parsing/validation |
| email_validator | Email validation |
| url_launcher | Deep linking |
| fluttertoast | Toast notifications |
| equatable | Value comparison for models |
| skeletonizer, shimmer | Loading placeholders |
| back_button_interceptor | Back navigation handling |

## Unresolved Notes

- Crashlytics commented out in main.dart; consider re-enabling for production error tracking
- Apple Sign-In dependency commented in pubspec; not wired in auth flow
- Only `en_GB` locale active; multi-language support infrastructure exists but not utilized
- Payment integration scope unclear; no Stripe/Polar/SePay wiring in current codebase
