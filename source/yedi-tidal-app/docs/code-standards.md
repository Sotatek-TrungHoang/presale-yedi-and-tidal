# Code Standards & Conventions — Yedi+Tidal App

## Naming Conventions

### Files
- **Dart files:** `snake_case.dart` (e.g., `authentication_bloc.dart`, `auth_user_model.dart`)
- **Screens/Pages:** `*_page.dart` pattern (e.g., `login_page.dart`, `advertiser_home_page.dart`)
- **Content widgets:** `*_content.dart` pattern (e.g., `sign_up_content.dart`)
- **Service files:** `*_service.dart` (e.g., `authentication_service.dart`, `applicant_advert_service.dart`)
- **BLoC files:** `*_bloc.dart` (e.g., `authentication_bloc.dart`)
- **Cubit files:** `*_cubit.dart` (e.g., `apply_application_cubit.dart`)
- **Model files:** `*_model.dart` (e.g., `auth_user_model.dart`, `advert_model.dart`)
- **State files:** `*_state.dart` (e.g., `authentication_state.dart`)
- **Event files:** `*_event.dart` (e.g., `authentication_event.dart`)

### Classes & Enums
- **Class names:** `PascalCase` (e.g., `AuthenticationBloc`, `AuthUserModel`, `APIException`)
- **Enum names:** `PascalCase` (e.g., `UserType`, `ApplicantComplianceStatus`, `AuthenticationStatus`)
- **Enum values:** `lowercase_or_snake_case` matching API response format (e.g., `pending_approval`, `non_compliant`)
- **Private classes/methods:** Leading underscore (e.g., `_handleException`, `_initFirebase`)

### Constants & Variables
- **Constants:** `CONSTANT_CASE` if truly immutable config; otherwise `camelCase`
- **Variables:** `camelCase` (e.g., `authUserModel`, `fcmToken`)
- **Boolean prefixes:** `is`, `has`, `can`, `should` (e.g., `isLoading`, `hasError`, `canApply`)

### Route Constants
All routes defined in `lib/pages/router.dart` under `abstract class Routes`:
```dart
static const String applicantHome = '/applicant';
static const String advertiserHome = '/advertiser';
```
Usage: `Routes.applicantHome` instead of hardcoded strings.

### Package Imports
- Feature imports: `package:yedi_app/modules/<feature>/...`
- Page imports: `package:yedi_app/pages/...`
- UI imports: `package:yedi_app/ui/...`
- Util imports: `package:yedi_app/util/...`
- Relative imports within same directory: OK for brevity

## Architecture & Structure

### Feature Module Layout
Every feature in `lib/modules/<feature>/` follows this structure:

```
lib/modules/adverts/
├── bloc/
│   ├── advert_detail_bloc.dart
│   ├── advert_detail_event.dart
│   ├── advert_detail_state.dart
│   └── ...
├── cubits/
│   ├── apply_application_cubit.dart
│   ├── apply_application_state.dart
│   └── ...
├── models/
│   ├── advert_model.dart
│   ├── application_model.dart
│   └── booking_model.dart
├── services/
│   ├── advertiser_advert_service.dart
│   ├── applicant_advert_service.dart
│   └── ...
└── (no pages; pages live in lib/pages/home/applicant|advertiser/adverts/)
```

**Rationale:** Services handle API calls; BLOCs/Cubits manage state; models define data shapes.

### BLoC vs Cubit
- **BLoC:** Complex state machines with explicit events (e.g., `authentication_bloc.dart` handles LoginEvent, LogoutEvent)
- **Cubit:** Simpler state, method-driven (e.g., `apply_application_cubit.dart` with `applyForAdvert()` method)

Choose based on complexity; both are interoperable via `RepositoryProvider`.

### Separation by Role
Many adverts services are split by user role:
- `advertiser_advert_service.dart` — Create, list, delete adverts; review applications
- `applicant_advert_service.dart` — List adverts, apply, manage bookings

**Why:** Prevents accidental cross-role data mutations. Each role calls its own service.

### Dependency Injection (DI)

**Get It (Global Singletons):**
```dart
// In main.dart
getIt.registerSingleton<ApiService>(ApiService());
getIt.registerSingleton<SharedPreferences>(await SharedPreferences.getInstance());
getIt.registerSingleton<FirebaseToken>(FirebaseToken(token: fcmToken));

// In BLoC/Cubit
final apiService = getIt<ApiService>();
```

**RepositoryProvider (Scoped Services):**
```dart
// In app.dart
RepositoryProvider.value(value: authenticationService),
RepositoryProvider.value(value: AdvertiserAdvertService()),
...

// In BLoC/Cubit
final authService = RepositoryProvider.of<AuthenticationService>(context);
```

**Pattern:** Get_it for low-level (HTTP, cache); RepositoryProvider for feature services. Avoids tight coupling.

### State Management Flow

```
Screen (Widget)
  └─ BlocConsumer / BlocBuilder
      └─ BLoC / Cubit
          └─ RepositoryProvider<Service>
              └─ ApiService (get_it singleton)
                  └─ Dio HTTP + interceptors
```

1. Screen triggers BLoC event or Cubit method
2. BLoC/Cubit fetches RepositoryProvider<Service>
3. Service calls ApiService.get/post/etc
4. ApiService injects bearer token + FCM token from get_it
5. Response parsed to Model or thrown as APIException
6. BLoC/Cubit emits new state
7. Widget rebuilds

## Error Handling

### Exception Hierarchy
```
DioException (thrown by Dio)
  └─ caught in ApiService._handleException()
      ├─ 422 Validation Error
      │   └─ APIValidationException { field: message map }
      ├─ Auth Error (401)
      │   └─ APIException with isAuthError=true
      ├─ Server Error (5xx)
      │   └─ APIException with isServerError=true
      └─ Generic
          └─ APIException
```

**Usage in BLoCs/Cubits:**
```dart
try {
  final result = await service.fetchAdvert(id);
  emit(state.copyWith(advert: result, status: AdvertStatus.success));
} on APIValidationException catch (e) {
  // Field-level errors; emit validation state
  emit(state.copyWith(validationErrors: e.errors, status: AdvertStatus.validationError));
} on APIException catch (e) {
  emit(state.copyWith(error: e.message, status: AdvertStatus.error));
}
```

### Never Ignore Exceptions
Always catch & emit appropriate state. Never silent failures; users must see errors.

## Validation

### Input Validators (lib/util/validator.dart)
- `isValidEmail(String email)` — Uses `email_validator`
- `isValidPhone(String phone)` — Uses `flutter_libphonenumber`
- Custom validators for business logic (e.g., password strength, terms acceptance)

### Form Validation Pattern
```dart
// In signup form cubit
bool _validateStep1() {
  if (firstName.isEmpty) {
    validationErrors['firstName'] = 'First name required';
    return false;
  }
  if (!Validator.isValidEmail(email)) {
    validationErrors['email'] = 'Invalid email';
    return false;
  }
  return true;
}
```

## Async Pattern (Futures & Error Recovery)

### Always Use Try-Catch
```dart
Future<void> loginUser(String email, String password) async {
  emit(state.copyWith(status: AuthenticationStatus.loading));
  try {
    final user = await authService.login(email, password);
    emit(state.copyWith(user: user, status: AuthenticationStatus.authenticated));
  } catch (e) {
    emit(state.copyWith(error: _mapErrorToMessage(e), status: AuthenticationStatus.unauthenticated));
  }
}
```

### Token Refresh Flow
If auth token expires, interceptor does NOT auto-refresh; explicit logout is required. User redirected to login.

## Linting & Analysis

### Configuration (analysis_options.yaml)
- **Base:** `flutter_lints` + `custom_lint` plugin
- **Disabled rules:** `avoid_print`, `constant_identifier_names`
  - `print()` intentional for debugging (e.g., `Env.print()` in main.dart)
  - Enum value snake_case required for API compatibility
- **Enabled:** All other lints (null safety, widget naming, performance, etc.)

### Running Checks
```bash
flutter analyze
```
Must pass before commit.

## Localization (i18n)

### ARB Files
Strings are defined in **per-flavor** ARB files:
- `lib/l10n/yedi/intl_en.arb` — Yedi brand strings
- `lib/l10n/tidal/intl_en.arb` — Tidal brand strings

**When adding strings:**
1. Add to BOTH ARB files (unless intentionally brand-specific)
2. Run `./scripts/generate_localizations_<flavor>.sh`
3. Import & use: `AppLocalizations.of(context)!.fieldName`

### No Hardcoded Strings
Always use `AppLocalizations.of(context)!.<key>` for user-facing text. Never hardcode.

### Currently Enabled Locale
Only `en_GB` is supported in `AppView` `supportedLocales`. Multi-language infrastructure exists but not active.

## Comments & Documentation

### Code Comments
- **Why, not what:** Comment business logic, constraints, workarounds
- **TODO/FIXME:** Use sparingly; prefer issues/PRs
- **Complex algorithms:** Explain invariants & edge cases
- **Flavor-specific code:** Note why branching exists

Example:
```dart
// Applicant compliance gate: signup incomplete until all required evidence uploaded
if (applicant?.signUpCompletedAt == null) {
  return Routes.signUp;
}
```

### Public API Documentation
Document public methods/classes intended for other modules:
```dart
/// Fetches all adverts visible to applicant.
/// Returns active adverts within applicant's job role + location.
Future<List<AdvertModel>> listAdverts({
  String? location,
  int? roleId,
}) async {
  // ...
}
```

### NO Plan/Issue References in Code
Do not embed plan artifact references (e.g., "FR-10", "phase-02") in code. Code should be self-contained.

## Platform-Specific Code

### Android (android/app/build.gradle)
- **Flavor dimensions:** `flavorDimensions "default"`
- **Flavor configs:** `yedi`, `tidal` — each sets `applicationId`, `resValue`, manifest host
- **Env binding:** `flutter_env_native` bridge wires `--dart-define-from-file` into native build

### iOS (ios/Runner/)
- **Schemes:** Generated per flavor (or manual setup required)
- **Env binding:** Dart `--dart-define-from-file` available; native iOS code accesses via `Info.plist` if needed

**Dart side:** Use `String.fromEnvironment('VAR_NAME')` to access `--dart-define-from-file` values.

## Testing

### Test Files Location
- Unit tests: `test/unit_test.dart`
- Widget tests: `test/widget_test.dart`

### Run Tests
```bash
flutter test                           # All tests
flutter test test/unit_test.dart      # Specific file
```

### Test Patterns
- **Mocking services:** Use `mockito` or manual `FakeService` extending real Service
- **BLoC testing:** Emit test events, assert state changes
- **Widget testing:** Use `WidgetTester` to pump widgets, find, tap, verify

## Secrets & Configuration

### .env Files (COMMITTED)
- `.env.yedi` — BASE_API_URL, GOOGLE_MAPS_API_KEY for Yedi
- `.env.tidal` — BASE_API_URL, GOOGLE_MAPS_API_KEY for Tidal
- **Note:** Maps API key is a real secret; treat carefully. Don't add other secrets to .env.

### Sensitive Data
- Auth tokens stored in `SharedPreferences` (encrypted on device by OS)
- No passwords/secrets hardcoded in source

### Per-Flavor Firebase Config
- `firebase_options.dart` regenerated per flavor via `./scripts/flutterfire_config_<flavor>.sh`
- Checked-in default points to `tidal-dev` Firebase project; Yedi override via pre_yedi.sh

## Performance & Optimization

### State Management
- Only rebuild affected widgets via `BlocBuilder` / `BlocConsumer` (not rebuilding entire tree)
- Use `where` filters on BLoC listeners to avoid redundant rebuilds

### Network Requests
- Cache user profile in `SharedPreferences` to avoid refetch on app resume
- Use pagination for lists (adverts, applications)
- Load images with caching (handled by Flutter's Image.network)

### UI Performance
- Use `Skeletonizer` or `Shimmer` for loading states (not full-screen blocks)
- Lazy load nested lists (e.g., application details within advert detail)
- Avoid deep widget hierarchies; prefer composition

## Best Practices Checklist

- [ ] Use `const` constructors where possible (performance + clarity)
- [ ] Use `Equatable` for model comparison (avoids manual == overrides)
- [ ] Keep BLoCs/Cubits stateless logic; all state via emit()
- [ ] Use `copyWith` for immutable state updates
- [ ] Never call `context.read()` in build; only in listeners/events
- [ ] Use `FutureBuilder` / `BlocBuilder` instead of setState
- [ ] Always handle exceptions; never swallow errors silently
- [ ] Use `named routes` (Routes.xxx constants) instead of hardcoded strings
- [ ] Keep screens under 300 lines; extract widgets to separate files
- [ ] Document complex business logic with comments

## Unresolved Questions

- Migration to Dart 4.x timeline unclear; currently ^3.5.2
- Payment integration architecture not yet defined
- Realtime messaging requirements TBD
