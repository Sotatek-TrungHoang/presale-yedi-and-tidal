# Deployment Guide — Yedi+Tidal App

## Prerequisites

Ensure you have:
- Flutter SDK ^3.5.2 installed (`flutter --version`)
- Android Studio + Android SDK (API 21+) for Android builds
- Xcode 14+ for iOS builds
- CocoaPods installed for iOS dependencies
- `flutterfire_cli` (`dart pub global activate flutterfire_cli`)
- Git configured with SSH (for native dependencies)

## Build Environment Setup

### 1. Clone & Prepare Repo
```bash
git clone <repo-url>
cd yedi-tidal-app
flutter pub get
```

### 2. Validate Environment
```bash
flutter doctor                     # Check all dependencies
flutter analyze                    # Static analysis (must pass)
flutter test                       # Unit & widget tests (must pass)
```

## Running Locally (Development)

### Running Yedi Flavor

```bash
# Step 1: Prepare flavor (regenerate Firebase config + localizations)
./scripts/pre_yedi.sh

# Step 2: Run on connected device/emulator
flutter run --flavor yedi --dart-define-from-file .env.yedi

# Or specify device:
flutter run --flavor yedi --dart-define-from-file .env.yedi -d <device-id>
```

**What pre_yedi.sh does:**
- Calls `flutterfire_config_yedi.sh` → regenerates `lib/firebase_options.dart` for yedi-dev-801c4 Firebase project
- Calls `generate_localizations_yedi.sh` → regenerates `lib/l10n/app_localizations.dart` from `lib/l10n/yedi/intl_en.arb`

### Running Tidal Flavor

```bash
# Step 1: Prepare flavor
./scripts/pre_tidal.sh

# Step 2: Run
flutter run --flavor tidal --dart-define-from-file .env.tidal
```

### Switching Flavors

**IMPORTANT:** Always run `pre_<flavor>.sh` before switching to avoid stale Firebase config + localization strings.

```bash
# Currently on Yedi
./scripts/pre_tidal.sh
flutter run --flavor tidal --dart-define-from-file .env.tidal

# Later, switch back to Yedi
./scripts/pre_yedi.sh
flutter run --flavor yedi --dart-define-from-file .env.yedi
```

## Build Commands (Release Builds)

### Android Build (Yedi)

```bash
# Build AAB (App Bundle) for Play Store
./scripts/build/yedi.sh

# Output: build/app/outputs/bundle/yediRelease/app-yedi-release.aab
```

### Android Build (Tidal)

```bash
# Build AAB for Play Store
./scripts/build/tidal.sh

# Output: build/app/outputs/bundle/tidalRelease/app-tidal-release.aab
```

### iOS Build (Yedi)

```bash
# Build IPA for TestFlight / App Store
./scripts/build/yedi.sh --ios

# Or manually:
./scripts/pre_yedi.sh
flutter build ipa --flavor yedi --dart-define-from-file .env.yedi

# Output: build/ios/ipa/
```

### iOS Build (Tidal)

```bash
./scripts/pre_tidal.sh
flutter build ipa --flavor tidal --dart-define-from-file .env.tidal
```

## Flavor Configurations

### Yedi Configuration
| Setting | Value |
|---------|-------|
| **Bundle ID (iOS)** | `com.ne6.yedi` |
| **Package ID (Android)** | `com.ne6.yedi` |
| **API Base URL** | `https://admin.yedi.group/` |
| **App Host** | `app.yedi.group` |
| **Firebase Project** | `yedi-dev-801c4` |
| **Env File** | `.env.yedi` |
| **Assets** | `assets/yedi/` |
| **Strings** | `lib/l10n/yedi/intl_en.arb` |
| **App Name** | Yedi Education (set in manifest/Info.plist) |

### Tidal Configuration
| Setting | Value |
|---------|-------|
| **Bundle ID (iOS)** | `com.ne6.tidal` |
| **Package ID (Android)** | `com.ne6.tidal` |
| **API Base URL** | `https://admin.tidalagency.co.uk/` |
| **App Host** | `app.tidalagency.co.uk` |
| **Firebase Project** | `tidal-dev` |
| **Env File** | `.env.tidal` |
| **Assets** | `assets/tidal/` |
| **Strings** | `lib/l10n/tidal/intl_en.arb` |
| **App Name** | Tidal (set in manifest/Info.plist) |

## Environment Variables

Both `.env.yedi` and `.env.tidal` are committed to the repo and contain:

```
BASE_API_URL=https://admin.<host>/
GOOGLE_MAPS_API_KEY=<api-key>
```

**Security Note:** `GOOGLE_MAPS_API_KEY` is a real secret; treat carefully. Do not add other secrets to .env files. Use secure vaults for production keys.

### Updating Env Variables

If API URL or Maps key changes:
1. Update `.env.yedi` and/or `.env.tidal`
2. Commit to git
3. Re-run build (new `--dart-define-from-file` will inject updated values)

## Version Management

### Bumping Version (pubspec.yaml)

Current: `version: 1.0.5+26`

Format: `major.minor.patch+build`

To bump:
```yaml
# Before
version: 1.0.5+26

# After (patch + build increment)
version: 1.0.6+27
```

- **major.minor.patch** — User-facing version
- **+build** — Internal build number (incremented per release)

Update in `pubspec.yaml`, commit, tag:
```bash
git tag -a v1.0.6 -m "Release v1.0.6"
git push origin v1.0.6
```

## Generating App Icons

Icon designs for both flavors stored in `flutter_launcher_icons-<flavor>.yaml`.

```bash
# Generate icons from source images
./scripts/generate_app_icons.sh

# This runs flutter_launcher_icons for both flavors
# Updates: android/app/src/main/res/mipmap-*/ and ios/Runner/Assets.xcassets/
```

Ensure source icon images exist and are correctly referenced in the YAML files.

## CI/CD Pipeline (Recommended)

Currently no automated CI/CD; recommend setting up:

### GitHub Actions (Recommended)

Create `.github/workflows/build.yml`:

```yaml
name: Build & Test

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.5.2'
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test

  build-yedi:
    runs-on: ubuntu-latest
    needs: test
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.5.2'
      - run: ./scripts/pre_yedi.sh
      - run: flutter build appbundle --flavor yedi --dart-define-from-file .env.yedi
      - uses: actions/upload-artifact@v3
        with:
          name: yedi-aab
          path: build/app/outputs/bundle/yediRelease/app-yedi-release.aab

  build-tidal:
    runs-on: ubuntu-latest
    needs: test
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.5.2'
      - run: ./scripts/pre_tidal.sh
      - run: flutter build appbundle --flavor tidal --dart-define-from-file .env.tidal
      - uses: actions/upload-artifact@v3
        with:
          name: tidal-aab
          path: build/app/outputs/bundle/tidalRelease/app-tidal-release.aab
```

## Deployment Checklists

### Pre-Release Checks (Before Any Build)

- [ ] Ensure `flutter doctor` passes
- [ ] Ensure `flutter analyze` passes
- [ ] Ensure `flutter test` passes
- [ ] Bump version in `pubspec.yaml`
- [ ] Update `docs/project-changelog.md` with release notes
- [ ] Commit all changes to git
- [ ] Tag commit with version: `git tag v<version>`

### Android Release

- [ ] Run `./scripts/pre_<flavor>.sh`
- [ ] Run `./scripts/build/<flavor>.sh`
- [ ] Verify AAB output: `build/app/outputs/bundle/<flavorRelease>/app-<flavor>-release.aab`
- [ ] Test on Android device (if possible)
- [ ] Upload to Google Play Store (via Play Console)
- [ ] Set rollout percentage (5% → 25% → 100%)
- [ ] Monitor crash reports for 24h before full rollout

### iOS Release

- [ ] Run `./scripts/pre_<flavor>.sh`
- [ ] Run `flutter build ipa --flavor <flavor> --dart-define-from-file .env.<flavor>`
- [ ] Verify IPA: `build/ios/ipa/`
- [ ] Upload to TestFlight (via Xcode or transporter)
- [ ] Test on TestFlight devices for 3-5 days
- [ ] Submit to App Store (via App Store Connect)
- [ ] Wait for review (typically 24-48h)
- [ ] Release when approved

## Monitoring Post-Release

### Firebase Console
- **Yedi:** https://console.firebase.google.com/project/yedi-dev-801c4
- **Tidal:** https://console.firebase.google.com/project/tidal-dev

Check:
- Crash Insights (once Crashlytics enabled)
- FCM delivery rates
- App performance metrics

### App Store / Play Store
- Monitor user ratings & reviews
- Check analytics dashboards for crash trends
- Respond to user feedback

## Rollback Procedure

If a release has critical issues:

### Android
1. Go to Google Play Console → Yedi/Tidal app → Release
2. Create new release with previous stable version
3. Set rollout to 100%
4. Mark broken release as "Paused"

### iOS
1. Go to App Store Connect → Yedi/Tidal → TestFlight
2. Reject current review (if in review)
3. Or submit previous version for review
4. Once approved, release to App Store

## Troubleshooting

### "Firebase config mismatch" error
**Cause:** Switched flavors without running `pre_<flavor>.sh`
**Fix:**
```bash
./scripts/pre_<current-flavor>.sh
flutter run --flavor <current-flavor> --dart-define-from-file .env.<flavor>
```

### "Localization strings missing" (UI shows ???)
**Cause:** app_localizations.dart not regenerated
**Fix:**
```bash
./scripts/pre_<flavor>.sh
flutter run --flavor <flavor> --dart-define-from-file .env.<flavor>
```

### Build fails with "Invalid Dart version"
**Cause:** Flutter SDK version mismatch
**Fix:**
```bash
flutter downgrade  # Or upgrade to ^3.5.2
flutter pub get
flutter pub global activate flutterfire_cli
```

### CocoaPods errors on iOS build
**Cause:** iOS dependencies outdated
**Fix:**
```bash
cd ios
rm -rf Pods/ Podfile.lock
pod repo update
cd ..
flutter pub get
flutter build ios --flavor <flavor> --dart-define-from-file .env.<flavor>
```

## Notes & Best Practices

1. **Always run pre_<flavor>.sh:** This is the most common source of issues. Make it a habit.
2. **Test both flavors before release:** Don't assume one flavor works means both do.
3. **Keep .env files committed:** These are safe; API keys are non-sensitive endpoints.
4. **Tag releases:** Use semantic versioning (v1.0.5, v1.1.0, v2.0.0).
5. **Document breaking changes:** Update CHANGELOG.md before releasing.
6. **Monitor staged rollouts:** Don't jump to 100% immediately; watch for crashes.
7. **Backup Firebase projects:** Ensure both Firebase projects have enabled backups.

## Unresolved Questions

1. Should we set up automated CI/CD via GitHub Actions? (Currently manual builds)
2. What's the promotion path from staging (tidal-dev, yedi-dev-801c4) to production Firebase projects?
3. Are there production API endpoints different from dev? (Currently using dev URLs in .env files)
4. Code signing certificates for iOS — where are they stored and managed?
5. Google Play Store signing — are keys managed securely?
