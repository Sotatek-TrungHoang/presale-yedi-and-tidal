import 'package:flutter/material.dart';
import 'package:yedi_app/ui/spacer.dart';
import 'package:yedi_app/ui/theme/app_theme.dart';

class AccountTypeSelector extends StatelessWidget {
  const AccountTypeSelector(
      {super.key,
      required this.label,
      required this.icon,
      required this.selected,
      this.onPressed});

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          // color: appColours.canvasBackground,
          borderRadius: BorderRadius.all(Radius.circular(themeBorderRadius)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
            color: selected
                ? appColours.canvasBackground
                : appColours.canvasBackground,
            child: InkWell(
              onTap: onPressed,
              splashColor: appColours.accent.withValues(alpha: 0.2),
              borderRadius:
                  BorderRadius.all(Radius.circular(themeBorderRadius)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      icon,
                      size: 46,
                      color: selected ? appColours.accent : Color(0xFF000000),
                    ),
                    const VSpacer(12),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14,
                          color:
                              selected ? appColours.accent : Color(0xFF000000),
                          fontWeight: FontWeight.w600),
                    )
                  ],
                ),
              ),
            )));
  }
}
