import 'package:flutter/material.dart';
import 'package:yedi_app/ui/spacer.dart';
import 'package:yedi_app/ui/theme/app_theme.dart';

class PageError extends StatelessWidget {
  final String error;
  final IconData icon;
  final EdgeInsets padding;
  final Color? iconColour;

  const PageError(
      {super.key,
      required this.error,
      this.icon = Icons.error,
      this.padding = const EdgeInsets.all(24),
      this.iconColour});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(icon, color: iconColour ?? appColours.error, size: 48),
          const VSpacer(24),
          Text(error, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
