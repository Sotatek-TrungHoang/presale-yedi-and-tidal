import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:yedi_app/ui/theme/tidal_theme.dart';
import 'package:yedi_app/ui/theme/yedi_theme.dart';

final appTheme = appFlavor == 'tidal' ? tidalTheme : yediTheme;
final appColours = appFlavor == 'tidal' ? tidalColours : yediColours;
final appIcons = appFlavor == 'tidal' ? tidalIcons : yediIcons;
final themeBorderRadius =
    appFlavor == 'tidal' ? tidalBorderRadius : yediBorderRadius;

class AppIcons {
  final IconData applicant;
  final IconData advertiser;

  AppIcons({required this.applicant, required this.advertiser});
}

class AppColours {
  final Color landingIconBg;
  final Color splashBackground;
  final Color background;
  final Color accent;
  final Color primary;
  final Color canvasBackground;
  final Color bottomNavBackground;
  final Color success;
  final Color error;

  AppColours(
      {required this.landingIconBg,
      required this.splashBackground,
      required this.background,
      required this.accent,
      required this.primary,
      required this.canvasBackground,
      required this.bottomNavBackground,
      required this.success,
      required this.error});
}
