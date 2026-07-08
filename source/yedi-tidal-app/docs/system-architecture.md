# System Architecture — Yedi+Tidal App

## Layered Architecture

The app follows a classic **4-layer architecture** with clear separation of concerns:

```
┌─────────────────────────────────────────────┐
│         UI Layer (lib/pages, lib/ui)        │
│  Pages, Screens, Reusable Widgets, Theming │
└────────────────┬────────────────────────────┘
                 │ BlocBuilder / BlocConsumer
                 ↓
┌─────────────────────────────────────────────┐
│    State Management (flutter_bloc)          │
│  BLOCs, Cubits, Events, States              │
└────────────────┬────────────────────────────┘
                 │ RepositoryProvider, emit()
                 ↓
┌─────────────────────────────────────────────┐
│    Business Logic (lib/modules/*/services) │
│  Service classes, validation, transformation│
└────────────────┬────────────────────────────┘
                 │ HTTP calls
                 ↓
┌─────────────────────────────────────────────┐
│   Data Access (lib/modules/api/)            │
│  ApiService (Dio), interceptors, exceptions │
│  SharedPreferences (cache, tokens)          │
└────────────────┬────────────────────────────┘
                 │ HTTP/Storage
                 ↓
┌─────────────────────────────────────────────┐
│      External (Backend API, Firebase)       │
└─────────────────────────────────────────────┘
```

## High-Level Data Flow

```
User Action (tap button)
  ↓
Page triggers BLoC/Cubit event or method
  ↓
BLoC/Cubit receives RepositoryProvider<Service>
  ↓
Service calls ApiService.get/post/etc
  ↓
ApiService interceptor injects:
  - Authorization: Bearer <token> (from SharedPreferences)
  - X-FCM-Token: <token> (from get_it singleton)
  ↓
Dio sends HTTP request to API
  ↓
Response parsed to Model or caught as APIException
  ↓
BLoC/Cubit emits new state
  ↓
BlocBuilder/BlocConsumer rebuilds UI
```

## Dependency Injection (DI) Layers

### Layer 1: Global Singletons (get_it)
Initialized in `main.dart`:
```
get_it
├── ApiService — HTTP client (Dio) with interceptors
├── SharedPreferences — Token cache, local storage
└── FirebaseToken — Current FCM token (refreshed by Firebase)
```

**Why:** These are truly global, never recreated, needed everywhere. No context needed.

### Layer 2: Feature Services (RepositoryProvider)
Registered in `app.dart`:
```
RepositoryProvider
├── AuthenticationService — Login, logout, user resolution
├── AdvertiserAdvertService — Advert CRUD (advertiser view)
├── ApplicantAdvertService — Advert browsing (applicant view)
├── ProfileService — Profile updates
├── DocumentService — File uploads
├── EvidenceService — Compliance evidence management
├── ReferencesService — Reference management
├── ChangePasswordService — Password update
├── ChangeEmailService — Email update
├── SettingsService — App settings
├── DropdownService — Fetch option lists (job roles, types of work)
├── AccountService — Account info
├── HeartedApplicantsService — Favorites management
└── DeclarationService — Compliance declarations
```

**Why:** Feature-scoped; multiple instances OK; injected into BLOCs/Cubits via `RepositoryProvider.of()`.

### Layer 3: State Management (BloC/Cubit)
Provided at page level via `BlocProvider`:
```
BlocProvider<ApplyApplicationCubit>()
  ├── depends on RepositoryProvider<ApplicantAdvertService>()
  ├── calls ApiService via service
  └── emits ApplyApplicationState (loading, success, error)
```

## Authentication & Authorization Flow (go_router)

The app uses a central **auth guard** via `go_router`'s `redirect()` function:

```
┌──────────────────────────────┐
│  User navigates to route     │
└──────────────┬───────────────┘
               ↓
        ┌──────────────────┐
        │ read AuthBloc    │
        │ state            │
        └────────┬─────────┘
                 ↓
        ┌─────────────────────────────────────┐
        │ if status == unknown:               │
        │   → show splash, wait for resolution│
        └────┬────────────────────────────────┘
             │ else
             ↓
   ┌─────────────────────────────────────────┐
   │ if unauthenticated:                     │
   │   → redirect to /landing                │
   └────┬────────────────────────────────────┘
        │ else (authenticated)
        ↓
   ┌────────────────────────────────────────────────┐
   │ if signUpCompletedAt == null (both roles):     │
   │   → redirect to /sign-up                       │
   └────┬───────────────────────────────────────────┘
        │ else (signup complete)
        ↓
   ┌──────────────────────────────────────────────────────┐
   │ if on unauthenticated route (landing, login):        │
   │   → redirect to /applicant or /advertiser home       │
   └────┬───────────────────────────────────────────────────┘
        │ else (on home or detail route)
        ↓
   ┌────────────────────────────────────────┐
   │ Check cross-role access:               │
   │   user navigating to wrong role home?  │
   │   → show error toast + redirect home   │
   └────┬───────────────────────────────────┘
        │
        ↓
   ┌────────────────────────────────┐
   │ Allow navigation (return null)  │
   └────────────────────────────────┘
```

**Key Guard Points:**
1. **Splash hold** — Unknown auth status blocks all navigation
2. **Unauthenticated gate** — No access without login
3. **Signup completion gate** — Both roles must complete signup before role-home access
4. **Role isolation** — Applicants can't see advertiser routes (except via cross-role detection + redirect)
5. **Reset-password validation** — Requires email + token query params; invalid → error + redirect to landing

**Implementation:** `lib/pages/router.dart` line ~107 in `redirect:` callback.

## Runtime Flavor Branching

Flavor is chosen at build time via `--flavor yedi|tidal` and `--dart-define-from-file .env.<flavor>`.

At runtime, `appFlavor` (from `flutter/services.dart`) controls:

```
┌──────────────────────────────────┐
│   App Startup (app.dart)         │
└────────────┬─────────────────────┘
             ↓
     ┌───────────────────────┐
     │ if appFlavor=='tidal' │
     │   use tidalTheme,     │
     │   tidalColours,       │
     │   tidalIcons          │
     │ else (yedi)           │
     │   use yediTheme, etc  │
     └────────┬──────────────┘
              ↓
     ┌───────────────────────────────┐
     │ Asset resolution:             │
     │ assets/$appFlavor/logo.svg    │
     │ assets/$appFlavor/...         │
     └────────┬──────────────────────┘
              ↓
     ┌───────────────────────────────┐
     │ i18n strings:                 │
     │ AppLocalizations.of(ctx)!.key │
     │ (from generated .arb per      │
     │  flavor)                      │
     └────────────────────────────────┘
```

**Generated Per-Flavor (must regenerate on flavor switch):**
- `lib/firebase_options.dart` — Firebase project config (yedi-dev-801c4 vs tidal-dev)
- `lib/l10n/app_localizations.dart` — Localization strings (from yedi/intl_en.arb vs tidal/intl_en.arb)

**Run pre-script before building:** `./scripts/pre_<flavor>.sh` regenerates both.

## Navigation Zones

The router defines three distinct navigation zones:

### Zone 1: Unauthenticated
**Routes:** `/landing`, `/landing/login`, `/landing/sign-up`, `/landing/login/forgot-password`, `/landing/login/reset-password`

**Accessible:** Anyone without auth token.

**Navigator:** Root navigator (no shell).

**Components:** Landing page, login page, signup wizard, password recovery flows.

### Zone 2: Applicant
**Shell route:** `/applicant`

**Sub-routes:** `/applicant/adverts`, `/applicant/adverts/:id`, `/applicant/bookings`, `/applicant/settings`, `/applicant/address`, `/applicant/qualifications`, etc.

**Accessible:** `user.type == UserType.applicant` AND `applicant.signUpCompletedAt != null`

**Navigator:** Dedicated `_applicantNavigatorKey` for nested navigation.

**Shell scaffold:** `ApplicantScaffold` — bottom nav, header, shared layout.

**Bottom nav tabs:** Adverts, Bookings, Profile, Settings.

### Zone 3: Advertiser
**Shell route:** `/advertiser`

**Sub-routes:** `/advertiser/adverts`, `/advertiser/adverts/create`, `/advertiser/applications`, `/advertiser/settings`, `/advertiser/update-profile`, etc.

**Accessible:** `user.type == UserType.advertiser` AND `advertiser.signUpCompletedAt != null`

**Navigator:** Dedicated `_advertiserNavigatorKey` for nested navigation.

**Shell scaffold:** `AdvertiserScaffold` — bottom nav, header, shared layout.

**Bottom nav tabs:** Adverts, Applications, Hearted Applicants, Settings.

## Feature Module Architecture (Example: Adverts)

```
lib/modules/adverts/
├── services/
│   ├── advertiser_advert_service.dart
│   │   ├── createAdvert(data) → AdvertModel
│   │   ├── deleteAdvert(id) → void
│   │   ├── listAdverts() → List<AdvertModel>
│   │   ├── getAdvertDetail(id) → AdvertModel
│   │   ├── listApplications(advertId) → List<ApplicationModel>
│   │   ├── acceptApplication(appId, data) → void
│   │   ├── declineApplication(appId) → void
│   │   └── rateApplicant(appId, rating) → void
│   └── applicant_advert_service.dart
│       ├── listAdverts() → List<AdvertModel>
│       ├── getAdvertDetail(id) → AdvertModel
│       ├── applyForAdvert(advertId, data) → ApplicationModel
│       ├── listApplications() → List<ApplicationModel>
│       ├── cancelApplication(appId) → void
│       ├── listBookings() → List<BookingModel>
│       └── heartApplicant(advertId) → void
│
├── models/
│   ├── advert_model.dart
│   ├── application_model.dart
│   └── booking_model.dart
│
├── cubits/
│   ├── apply_application_cubit.dart
│   ├── accept_application_cubit.dart
│   ├── decline_application_cubit.dart
│   ├── rate_applicant_cubit.dart
│   ├── create_advert_cubit.dart
│   ├── delete_advert_cubit.dart
│   ├── heart_applicant_cubit.dart
│   ├── advert_detail_bloc.dart
│   ├── list_adverts_cubit.dart
│   ├── list_applications_cubit.dart
│   └── list_bookings_cubit.dart
└── (no pages here; pages in lib/pages/home/applicant|advertiser/adverts/)
```

**Data flow for "Apply for Advert":**
```
ApplicantAdvertDetailPage
  ↓ [Apply button tap]
BlocProvider<ApplyApplicationCubit>
  ↓ [applyForAdvert(advertId, data)]
ApplyApplicationCubit
  ↓ [RepositoryProvider.of<ApplicantAdvertService>()]
ApplicantAdvertService.applyForAdvert()
  ↓ [calls ApiService.postData('/applications', data)]
ApiService
  ↓ [interceptor injects Bearer + FCM-Token]
Dio HTTP POST to /applications
  ↓ [API returns ApplicationModel JSON]
ApiService parses response → ApplicationModel
  ↓ [returns to cubit]
ApplyApplicationCubit emits ApplyApplicationState(status: success, application: model)
  ↓
BlocListener rebuilds page
  ↓
Show success toast + navigate to bookings
```

## Compliance & Onboarding State Machine

Applicants & advertisers both go through compliance gates:

```
Signup Created
  ↓
ApplicantComplianceStatus: incomplete
  ↓
Upload evidence, references, video verification
  ↓
ApplicantComplianceStatus: pending_approval
  ↓
Backend reviews (not shown in app)
  ↓
ApplicantComplianceStatus: compliant OR non_compliant
  ↓
ProfileStatus: active (if compliant)
  ↓
signUpCompletedAt: set to current timestamp
  ↓
Redirect from /sign-up to /applicant
```

The auth guard checks `signUpCompletedAt == null` to hold users on signup flow.

## Error Handling Architecture

All HTTP errors flow through a single exception hierarchy:

```
Dio.get/post/etc throws DioException
  ↓
ApiService._handleException(DioException)
  ↓
  ├─ DioExceptionType.response (status code)
  │   ├─ 422 → APIValidationException { field: message map }
  │   ├─ 401 → APIException { isAuthError: true }
  │   ├─ 5xx → APIException { isServerError: true }
  │   └─ other → APIException { message: statusMessage }
  │
  └─ DioExceptionType.connectionTimeout/receiveTimeout
      └─ APIException { message: "Network timeout" }
```

**Catching in BLOCs:**
```dart
try {
  await service.call();
} on APIValidationException catch (e) {
  // e.errors is Map<String, String>
  emit(state.copyWith(validationErrors: e.errors));
} on APIException catch (e) {
  emit(state.copyWith(error: e.message));
}
```

## Multi-Threading & Concurrency

- **Async/await:** All API calls are async; no blocking.
- **Isolates:** Not used; Flutter's event loop handles concurrency.
- **State locks:** BLOCs emit atomically; no race conditions on state.
- **Optimistic updates:** Some screens (e.g., heart applicant) emit optimistic state, revert on error.

## Performance Considerations

| Aspect | Strategy |
|--------|----------|
| **Large lists** | Pagination; lazy load on scroll |
| **Image caching** | Flutter Image.network (automatic) |
| **Loading states** | Skeletonizer / Shimmer (not full-screen blocks) |
| **Token refresh** | No auto-refresh; explicit logout on 401 |
| **Rebuilds** | BlocBuilder limits rebuild scope |
| **Network** | Single ApiService instance (singleton) reuses Dio client |

## Unresolved Architectural Questions

- Real-time messaging layer (not currently in app; future roadmap?)
- Payment gateway integration (Stripe/Polar/SePay) — architecture TBD
- Caching strategy for user profile (currently refetch on resume)
- Multi-language support infrastructure exists but not active; rollout timeline unclear
