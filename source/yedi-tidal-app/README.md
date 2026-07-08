# Yedi+Tidal App — Flutter Two-Sided Marketplace

A Flutter-based mobile marketplace app connecting **applicants** (job seekers) and **advertisers** (employers) with compliance-first onboarding. Shipped as two branded flavors: **Yedi** (education focus) and **Tidal** (general staffing).

**Current Version:** 1.0.5+26 | **Status:** Stable | **SDK:** ^3.5.2

## Quick Start

### Prerequisites
- Flutter ^3.5.2
- Dart 3.5+
- iOS 12+ / Android API 21+
- Xcode 14+ (for iOS builds)
- Android Studio + SDK (for Android builds)

### Setup & Run (Yedi)

```bash
# Clone & install dependencies
git clone <repo-url>
cd yedi-tidal-app
flutter pub get

# Prepare flavor (regenerates Firebase config + strings)
./scripts/pre_yedi.sh

# Run on connected device/emulator
flutter run --flavor yedi --dart-define-from-file .env.yedi
```

**For Tidal:** Replace `yedi` with `tidal` in commands above.

### Key Commands

```bash
# Validate setup
flutter doctor
flutter analyze     # Static analysis (must pass)
flutter test        # Unit & widget tests

# Run (development)
flutter run --flavor yedi --dart-define-from-file .env.yedi

# Build for release
./scripts/build/yedi.sh      # Builds AAB + IPA
./scripts/build/tidal.sh     # Builds AAB + IPA

# Regenerate icons from assets
./scripts/generate_app_icons.sh

# Check specific test file
flutter test test/unit_test.dart
```

## Architecture Overview

**4-layer architecture:**

```
UI Layer (Screens, Widgets, Theme)
       ↓
State Management (BLoCs, Cubits)
       ↓
Business Logic (Services, Validation)
       ↓
Data Access (HTTP, SharedPreferences, Firebase)
```

**Key Patterns:**
- `flutter_bloc` for state management
- `go_router` with centralized auth guard
- `get_it` + `RepositoryProvider` for dependency injection
- Feature-scoped services (api, authentication, adverts, profile, etc.)
- Runtime flavor branching (theme, colors, assets, strings)

**Generated files (regenerate per build):**
- `lib/firebase_options.dart` — Firebase config per flavor
- `lib/l10n/app_localizations.dart` — Localization strings from `.arb` files

See `docs/system-architecture.md` for detailed diagrams and flows.

## Project Structure

```
lib/
├── main.dart                  # App bootstrap
├── app.dart                   # Root widget, DI setup
├── modules/                   # Feature modules
│   ├── api/                   # HTTP client (Dio + interceptors)
│   ├── authentication/        # Auth state, login/signup, user model
│   ├── adverts/              # Advert CRUD, applications, bookings
│   ├── profile/              # Profile management
│   ├── sign_up/              # Onboarding workflow
│   ├── documents/            # File uploads
│   ├── common/               # Shared services (account, settings, email, password)
│   └── ...
├── pages/                     # Screen widgets
│   ├── router.dart           # go_router config + auth guard
│   ├── splash/               # Splash screen
│   ├── landing/              # Unauthenticated landing
│   ├── login/                # Login + password recovery
│   ├── sign_up/              # Multi-step signup wizard
│   └── home/
│       ├── applicant/        # Applicant screens
│       └── advertiser/       # Advertiser screens
├── ui/                        # Shared components
│   ├── theme/                # AppTheme, colors, branding per flavor
│   ├── inputs/               # Reusable input widgets
│   ├── scaffolds/            # Role-specific shells
│   └── ...
└── util/                      # Helpers (env, firebase, forms, dates, strings)
```

See `docs/codebase-summary.md` for detailed module breakdown.

## User Roles & Flows

### Applicant (Job Seeker)
1. Sign up → compliance onboarding (evidence, references, video verification)
2. Browse & search adverts
3. Apply for adverts
4. Manage bookings
5. Rate advertisers

### Advertiser (Employer)
1. Sign up → compliance review
2. Create adverts
3. Review & rate applications
4. Manage bookings & candidates
5. Heart (favorite) top applicants

### Compliance Gating
- Applicants & advertisers must complete signup before accessing marketplace
- Applicants provide: references, evidence, video verification, right-to-work declaration
- Backend reviews compliance; status tracked in `ApplicantComplianceStatus` / `AdvertiserComplianceStatus`
- Profile activation blocked until compliant

See `docs/project-overview-pdr.md` for full product details.

## Development Workflow

### Before Implementing
1. Read `docs/` directory (architecture, standards, roadmap)
2. Check `lib/modules/` for existing patterns
3. Use feature-scoped modules: services + BLOCs/Cubits + models

### Code Standards
- `flutter analyze` must pass (flutter_lints + custom_lint)
- `flutter test` must pass before push
- Follow `docs/code-standards.md` (naming, patterns, DI, error handling)
- No hardcoded strings; use `AppLocalizations.of(context)!.key`
- All services, BLOCs, models use typed exceptions (APIException, APIValidationException)

### Testing
```bash
# All tests
flutter test

# Single file
flutter test test/unit_test.dart

# With coverage (requires package install)
flutter test --coverage
```

### Running Locally with Hot Reload
```bash
# Yedi
./scripts/pre_yedi.sh
flutter run --flavor yedi --dart-define-from-file .env.yedi

# Tidal
./scripts/pre_tidal.sh
flutter run --flavor tidal --dart-define-from-file .env.tidal
```

**⚠️ Switching flavors?** Always run `pre_<flavor>.sh` to avoid stale Firebase config & strings.

## Deployment

### Building for Release

```bash
# Android (builds to build/app/outputs/bundle/)
./scripts/build/yedi.sh
./scripts/build/tidal.sh

# iOS (builds to build/ios/ipa/)
./scripts/pre_yedi.sh
flutter build ipa --flavor yedi --dart-define-from-file .env.yedi
```

### Release Checklist
- [ ] Version bumped in `pubspec.yaml`
- [ ] `flutter analyze` passes
- [ ] `flutter test` passes
- [ ] Both flavors tested on device
- [ ] `docs/project-changelog.md` updated
- [ ] Git tagged: `git tag v<version>`
- [ ] Uploaded to Play Store / App Store

See `docs/deployment-guide.md` for detailed instructions, CI/CD setup, and rollback procedures.

## Theming & Branding

Both flavors share code; runtime branding via:
- **Theme:** Primary/secondary colors, typography, border radius
- **Assets:** `assets/yedi/` vs `assets/tidal/`
- **Strings:** `lib/l10n/yedi/intl_en.arb` vs `lib/l10n/tidal/intl_en.arb`

| Brand | Primary Color | API | Firebase Project |
|-------|---------------|-----|------------------|
| Yedi | #5B63D3 | admin.yedi.group | yedi-dev-801c4 |
| Tidal | #2563EB | admin.tidalagency.co.uk | tidal-dev |

See `docs/design-guidelines.md` for complete color palettes, typography, component guidelines.

## Documentation

| Document | Purpose |
|----------|---------|
| `docs/project-overview-pdr.md` | Product overview, scope, PDR, acceptance criteria |
| `docs/codebase-summary.md` | File map, module structure, dependency overview |
| `docs/code-standards.md` | Naming, patterns, validation, error handling, testing |
| `docs/system-architecture.md` | Layered architecture, data flow, routing, compliance state machine |
| `docs/project-roadmap.md` | Current status, completed phases, roadmap items, known issues |
| `docs/deployment-guide.md` | Build commands, release procedure, CI/CD, troubleshooting |
| `docs/design-guidelines.md` | Colors, typography, components, responsive design |
| `CLAUDE.md` | Developer guide (flavor system, commands, conventions) |

**Start here:** Read `CLAUDE.md` for development context, then dive into `docs/system-architecture.md`.

## Key Features

- ✅ Dual-flavor branding (Yedi + Tidal)
- ✅ Two-sided marketplace (applicants + advertisers)
- ✅ Compliance-first onboarding (documents, video verification, approval gate)
- ✅ Advert management (create, list, filter, apply)
- ✅ Application lifecycle (apply, accept, decline, rate)
- ✅ Bookings & scheduling
- ✅ Push notifications (FCM per flavor)
- ✅ Maps integration (Google Maps)
- ✅ Role-based routing with auth guard
- ✅ Persistent auth (SharedPreferences)

## Known Limitations

- 🔲 **No multi-language:** Only `en_GB` enabled; infrastructure exists
- 🔲 **No realtime messaging:** Applicant/advertiser chat not implemented
- 🔲 **No payment integration:** Stripe/Polar/SePay not wired
- 🔲 **No offline mode:** All features require network
- 🔲 **No Apple Sign-In:** Dependency commented; not integrated
- 🔲 **No Crashlytics:** Error tracking disabled; commented in main.dart

See `docs/project-roadmap.md` for roadmap + candidate features.

## Dependencies (Highlights)

| Package | Version | Use |
|---------|---------|-----|
| flutter_bloc | ^9.0.0 | State management |
| go_router | ^14.2.7 | Navigation + routing |
| dio | ^5.7.0 | HTTP client |
| firebase_core, firebase_messaging | ^3.10.1, ^15.2.1 | Push notifications |
| google_maps_flutter | ^2.10.0 | Maps |
| google_fonts | ^6.2.1 | Typography |
| flutter_svg | ^2.0.15 | SVG rendering |
| shared_preferences | ^2.3.2 | Persistent storage |
| get_it | ^8.0.3 | Dependency injection |

See `pubspec.yaml` for complete list.

## Troubleshooting

### Firebase config mismatch error
```bash
# Switched flavors without regenerating config?
./scripts/pre_<current-flavor>.sh
flutter run --flavor <flavor> --dart-define-from-file .env.<flavor>
```

### Localization strings showing "???"
```bash
# app_localizations.dart not regenerated
./scripts/pre_<flavor>.sh
flutter run --flavor <flavor> --dart-define-from-file .env.<flavor>
```

### CocoaPods errors (iOS)
```bash
cd ios
rm -rf Pods/ Podfile.lock
pod repo update
cd ..
flutter pub get
flutter build ios --flavor <flavor> --dart-define-from-file .env.<flavor>
```

See `docs/deployment-guide.md` troubleshooting section for more.

## Contributing

1. Create feature branch: `git checkout -b feature/my-feature`
2. Read `docs/code-standards.md` before implementing
3. Implement feature following architecture patterns
4. Run `flutter analyze && flutter test` — must pass
5. Commit with descriptive message (no plan references)
6. Open PR; wait for review
7. Merge after approval

## License

[TBD — Add license information if applicable]

## Contact

**Questions?** Refer to:
- Developer guide: `CLAUDE.md`
- Architecture details: `docs/system-architecture.md`
- Code patterns: `docs/code-standards.md`

---

**Last Updated:** Dec 1, 2025 | **Maintained by:** Yedi+Tidal Team
