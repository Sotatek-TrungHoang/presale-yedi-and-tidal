# Design Guidelines — Yedi+Tidal App

## Brand Identity

The app is branded as two distinct products:

| Brand | Focus | Audience | Tone |
|-------|-------|----------|------|
| **Yedi** | Education sector staffing | Teachers, schools, education agencies | Professional, trustworthy, educational |
| **Tidal** | General agency staffing | Job seekers, recruitment agencies | Dynamic, modern, professional |

Both share the same codebase and core experience; visual identity differs via theme, colors, and assets.

## Design System Architecture

### Runtime Theming

Flavor is determined at startup and never changes during the session.

```dart
// lib/ui/theme/app_theme.dart
final appTheme = appFlavor == 'tidal' ? tidalTheme : yediTheme;
final appColours = appFlavor == 'tidal' ? tidalColours : yediColours;
final appIcons = appFlavor == 'tidal' ? tidalIcons : yediIcons;
```

**Why:** Avoids conditional theme-switching logic throughout the app. Single build = single theme.

### Theme Components

#### 1. Material Theme (ThemeData)
Located: `lib/ui/theme/yedi_theme.dart` and `tidal_theme.dart`

Each flavor defines a complete `ThemeData` object:

```dart
const yediTheme = ThemeData(
  useMaterial3: true,
  primary: Color(0xFF...), // Yedi primary
  surface: Color(0xFF...), // Yedi surface
  // ... complete Material design tokens
);
```

**Includes:**
- Primary & secondary colors
- Surface & background colors
- Typography (fonts, sizes, weights)
- Component styles (buttons, inputs, cards, etc.)
- Dark mode (if supported)

#### 2. AppColours (Custom Color Palette)
Custom enum of semantic colors beyond Material defaults:

```dart
class AppColours {
  final Color landingIconBg;       // Background for landing page icons
  final Color splashBackground;    // Splash screen background
  final Color background;          // Main app background
  final Color accent;              // Accent color for CTAs
  final Color primary;             // Primary brand color
  final Color canvasBackground;    // Card/canvas backgrounds
  final Color bottomNavBackground; // Bottom nav bar background
  final Color success;             // Success feedback color
  final Color error;               // Error feedback color
}
```

**Usage:**
```dart
import 'package:yedi_app/ui/theme/app_theme.dart';

final backgroundColor = appColours.background;
final accentColor = appColours.accent;
```

#### 3. AppIcons (Role-Specific Icons)
Custom enum for role-specific iconography:

```dart
class AppIcons {
  final IconData applicant;   // Icon for applicant role
  final IconData advertiser;  // Icon for advertiser role
}
```

Concrete per-flavor values (Material `Icons`), reflecting each brand's domain:

| Role | Yedi (`yediIcons`) | Tidal (`tidalIcons`) |
|------|--------------------|-----------------------|
| `applicant` | `Icons.school` (education) | `Icons.person` (generic) |
| `advertiser` | `Icons.apartment` (school/employer) | `Icons.store` (agency) |

Used in role-aware navigation/branding. When adding a new brand, provide both icons.

#### 4. Border Radius
Each flavor exposes a single `double` radius (currently **both `8.0`**), selected via `themeBorderRadius` in `app_theme.dart`:

```dart
// lib/ui/theme/yedi_theme.dart
double yediBorderRadius = 8.0;
// lib/ui/theme/tidal_theme.dart
double tidalBorderRadius = 8.0;
// lib/ui/theme/app_theme.dart
final themeBorderRadius = appFlavor == 'tidal' ? tidalBorderRadius : yediBorderRadius;
```

Wrapped as `BorderRadius.all(Radius.circular(themeBorderRadius))` and applied to inputs, buttons, cards, and the bottom-sheet top corners. The two values are independent, so a brand can diverge here later without code changes elsewhere.

## Color Palettes

Values below are the source of truth — read directly from `lib/ui/theme/yedi_theme.dart` and `lib/ui/theme/tidal_theme.dart` (`AppColours` instances). Both brands share `success` `#1EA043` and `error` `#C62828`. The two palettes are deliberately different in character: **Yedi = warm amber on cream**, **Tidal = high-contrast black/white with an indigo accent**.

### Yedi Color Palette (`yediColours`)

| AppColours field | Hex (ARGB `Color(...)`) | Usage |
|------------------|--------------------------|-------|
| `landingIconBg` | `#EF9F1F` | Landing page icon backgrounds |
| `splashBackground` | `#F0E4D4` | Splash screen background (cream) |
| `background` | `#F0E4D4` | Main app / scaffold background (cream) |
| `accent` | `#EF9F1F` | CTAs, progress, focused input border (amber) |
| `primary` | `#000000` | Primary brand color / ColorScheme primary (black) |
| `canvasBackground` | `#FFFFFF` | Cards / canvas / input fill |
| `bottomNavBackground` | `#000000` | Bottom nav bar background |
| `success` | `#1EA043` | Success feedback |
| `error` | `#C62828` | Error / destructive feedback |

### Tidal Color Palette (`tidalColours`)

| AppColours field | Hex (ARGB `Color(...)`) | Usage |
|------------------|--------------------------|-------|
| `landingIconBg` | `#000000` | Landing page icon backgrounds |
| `splashBackground` | `#000000` | Splash screen background (black) |
| `background` | `#FFFFFF` | Main app / scaffold background (white) |
| `accent` | `#3E4DB0` (`Color.fromARGB(255, 62, 77, 176)`) | CTAs, progress, focused input border (indigo) |
| `primary` | `#000000` | Primary brand color / ColorScheme primary (black) |
| `canvasBackground` | `#F3F3F3` | Cards / canvas / input fill (light grey) |
| `bottomNavBackground` | `#000000` | Bottom nav bar background |
| `success` | `#1EA043` | Success feedback |
| `error` | `#C62828` | Error / destructive feedback |

> Note: shared `ThemeData` also hardcodes a few non-`AppColours` values in both theme files — unselected bottom-nav item `#8C8C8C`, and progress track `#CCB79A`. There is no separate "text" token in `AppColours`; text color comes from the Material `ColorScheme` (`onPrimary: white`, primary/secondary = `primary`).

## Typography

Both flavors use the **Sora** typeface via `google_fonts`, applied with `GoogleFonts.soraTextTheme(...)` in each theme file. Bottom-nav labels also use `GoogleFonts.sora(...)`. The two flavors currently share identical typography.

### Font

- Family: **Sora** (Google Fonts). No custom bundled font files.
- The base `TextTheme` passed to `soraTextTheme` explicitly overrides only two roles (all other roles inherit Material defaults, re-styled in Sora):

| TextTheme role | Size | Weight | Color |
|----------------|------|--------|-------|
| `bodyMedium` | 16 | `w400` | black |
| `titleMedium` | 18 | `w600` | black |

Practical implication: most text picks up `bodyMedium`/`titleMedium`; when you need other sizes, prefer defining them on the theme's `TextTheme` rather than ad-hoc inline styles, so both flavors stay consistent.

### Implementation

Use Material `TextStyle` roles from the theme:

```dart
// In a widget
Text(
  'Welcome',
  style: Theme.of(context).textTheme.titleMedium,
);

Text(
  'Apply now',
  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
    color: appColours.primary,
  ),
);
```

## Asset Management

### Asset Directory Structure

Actual tree (declared in `pubspec.yaml` under `flutter/assets:` as `assets/images/`, `assets/yedi/`, `assets/tidal/`). The critical convention is that every flavor provides a `logo.svg` at `assets/<flavor>/logo.svg`, since that path is resolved at runtime as `"assets/$appFlavor/logo.svg"` (splash, landing, login, forgot/reset password). Note Yedi currently ships fewer variants than Tidal.

```
assets/
├── images/                              # Shared, neutral (Flutter starter placeholder)
│   ├── flutter_logo.png
│   ├── 2.0x/flutter_logo.png
│   └── 3.0x/flutter_logo.png
├── yedi/
│   ├── logo.svg                         # REQUIRED — runtime-resolved brand logo
│   └── icon/
│       ├── app-icon.png
│       ├── app-icon-transparent.png
│       └── app-icon-orange-transparent.png
└── tidal/
    ├── logo.svg                         # REQUIRED — runtime-resolved brand logo
    ├── logo.png
    ├── logo-white.svg / logo-white.png
    ├── logo-splash.svg / logo-splash.png
    └── icon/
        ├── app-icon.png
        └── app-icon-transparent.png
```

App launcher icons are generated (not runtime-loaded) from `flutter_launcher_icons-<flavor>.yaml` via `./scripts/generate_app_icons.sh`, sourcing the `assets/<flavor>/icon/` images.

### Asset Resolution at Runtime

```dart
// Flavor-specific asset
final logoAsset = 'assets/$appFlavor/logo.svg';

// Usage in Image widget
Image.asset(logoAsset, width: 200);
```

### Adding New Assets

1. Place in appropriate directory (`assets/images/`, `assets/yedi/`, or `assets/tidal/`)
2. Update `pubspec.yaml` `assets:` section (already configured to include all)
3. Reference via `Image.asset()` or `SvgPicture.asset()`

## Component Guidelines

### Buttons

All buttons use Material `ElevatedButton`, `OutlinedButton`, or `TextButton`.

**Primary Button (CTA):**
- Background: `appColours.primary`
- Text: `Color.white`
- Border Radius: `themeBorderRadius`
- Padding: 16px horizontal, 12px vertical

```dart
ElevatedButton(
  onPressed: () { },
  style: ElevatedButton.styleFrom(
    backgroundColor: appColours.primary,
    shape: RoundedRectangleBorder(borderRadius: themeBorderRadius),
  ),
  child: const Text('Apply Now'),
)
```

**Secondary Button:**
- Background: `appColours.canvasBackground` or transparent
- Border: 1px `appColours.border`
- Text: `appColours.primary`

**Disabled State:**
- Opacity: 50%
- Cursor: not-allowed

### Input Fields

Consistent text input styling:

```dart
TextField(
  decoration: InputDecoration(
    labelText: 'Email',
    hintText: 'your@email.com',
    border: OutlineInputBorder(
      borderRadius: themeBorderRadius,
      borderSide: BorderSide(color: appColours.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: themeBorderRadius,
      borderSide: BorderSide(color: appColours.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: themeBorderRadius,
      borderSide: BorderSide(color: appColours.error),
    ),
  ),
)
```

**Focus state:** Thicker border, primary color.
**Error state:** Red border + error message below.
**Disabled state:** Grayed out, opacity 50%.

### Cards

Raised cards with shadow + border radius:

```dart
Card(
  shape: RoundedRectangleBorder(borderRadius: themeBorderRadius),
  elevation: 2,
  margin: const EdgeInsets.all(16),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      // Card content
    ),
  ),
)
```

### Lists & Tiles

ListTile for consistent list items:

```dart
ListTile(
  leading: CircleAvatar(
    backgroundImage: NetworkImage(imageUrl),
  ),
  title: Text('John Doe'),
  subtitle: Text('Applied on Dec 1'),
  trailing: Icon(Icons.arrow_forward_ios),
  onTap: () { },
)
```

**Dividers:** Use `Divider` between tiles. Border color: `appColours.border`.

### Navigation

**Bottom Navigation (Applicant & Advertiser):**
- Uses `BottomNavigationBar` from Material
- Background: `appColours.bottomNavBackground`
- Active color: `appColours.primary`
- Inactive color: `appColours.textSecondary`
- Items: 4-5 tabs (Home, Search/Adverts, Bookings/Applications, Settings)

**Tab Bar (within screens):**
- Underline style: 2px `appColours.primary`
- Text: `appColours.textPrimary` / `appColours.textSecondary`

## Responsive Design

### Breakpoints

| Device | Width | Usage |
|--------|-------|-------|
| **Small Phone** | < 400dp | iPhone SE, older Androids |
| **Phone** | 400-600dp | Most phones |
| **Tablet** | 600+ dp | iPads, large Androids |

**Current app focus:** Phone-first design. Tablet support optional.

### Responsive Layout Patterns

```dart
// Single column on phone, two columns on tablet
Widget build(BuildContext context) {
  final isTablet = MediaQuery.of(context).size.width > 600;
  
  return isTablet
    ? Row(children: [sidebar, mainContent])
    : Column(children: [mainContent]);
}
```

**Avoid:** Hardcoded screen dimensions. Use `MediaQuery` and flexible layouts.

## Accessibility (A11y)

### Semantic Labels
All interactive elements must have readable labels:

```dart
IconButton(
  onPressed: () { },
  icon: Icon(Icons.add),
  tooltip: 'Add new advert',  // Screen reader label
  semanticLabel: 'Add new advert',
)
```

### Color Contrast
Ensure WCAG AA compliance (4.5:1 for text):
- Text on primary background: white text
- Text on light background: dark gray or black

### Text Scaling
Respect system font size; use `MediaQuery.textScaleFactor`.

## Dark Mode (Future)

Currently not implemented. To add:

1. Define dark theme variants in `yedi_theme.dart` + `tidal_theme.dart`
2. Use `MediaQuery.platformBrightness` to detect system preference
3. Wrap `MaterialApp.router()` with conditional theme
4. Update all color references to be brightness-aware

## Motion & Animations

### Micro-animations
- Button press: 100-200ms fade + scale
- Page transition: 300-400ms slide/fade
- Loading spinner: Continuous rotation (smooth)

Use Flutter's built-in `AnimatedContainer`, `AnimationController`, `Tween` for consistency.

```dart
// Simple fade
AnimatedOpacity(
  opacity: isLoading ? 0.5 : 1.0,
  duration: Duration(milliseconds: 300),
  child: Button(),
)
```

### Avoid:
- Lengthy animations (>500ms) for common interactions
- Jank (frame drops); profile with Flutter DevTools

## Icons

Both flavors use **Material Icons** (Flutter default) + custom SVGs.

**SVG assets:** Rendered via `flutter_svg` package.

```dart
SvgPicture.asset(
  'assets/$appFlavor/logo.svg',
  width: 200,
  height: 200,
  colorFilter: ColorFilter.mode(
    appColours.primary,
    BlendMode.srcIn,
  ),
)
```

## Design Tokens (Summary)

Store reusable values as constants:

```dart
// In a constants file or theme file
const edgeInsets16 = EdgeInsets.all(16);
const edgeInsets8 = EdgeInsets.all(8);

const durationFast = Duration(milliseconds: 200);
const durationMedium = Duration(milliseconds: 300);
```

Use throughout to maintain consistency.

## Theming Best Practices

1. **Always use appColours:** Never hardcode hex values in widgets
2. **Prefer theme properties:** Use `Theme.of(context).xxx` where possible
3. **Test both flavors:** Visual differences must be intentional
4. **Use MediaQuery sparingly:** Prefer flexible layouts + constraints
5. **Document color intent:** Use semantic names (not "blue_1", use "primary")
6. **Icon consistency:** Use Material Icons; custom SVGs for branding only

## Unresolved Design Decisions

1. Should dark mode be supported? (Currently light-only)
2. Tablet layout strategy? (Currently phone-optimized)
3. Animation budget? (How much motion is acceptable?)
4. Haptic feedback? (Vibration on button tap?)
5. Accessibility targets? (WCAG AA or AAA?)
