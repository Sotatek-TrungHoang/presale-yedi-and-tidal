import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yedi_app/ui/theme/app_theme.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  static const name = 'splash';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(preferredSize: Size.zero, child: Container()),
      backgroundColor: appColours.splashBackground,
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            "assets/$appFlavor/logo.svg",
            height: 84,
            theme: SvgTheme(
              currentColor: appColours.accent,
            ),
          ),
        ],
      )),
    );
  }
}
