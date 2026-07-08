import 'package:flutter/material.dart';
import 'package:yedi_app/ui/spacer.dart';
import 'package:yedi_app/ui/theme/app_theme.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ProfileButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool required;
  final void Function()? onTap;

  const ProfileButton(
      {super.key,
      required this.label,
      required this.icon,
      this.onTap,
      this.required = false});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          // color: appColours.canvasBackground,
          borderRadius: BorderRadius.all(Radius.circular(themeBorderRadius)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
            color: appColours.canvasBackground,
            child: InkWell(
              onTap: onTap,
              splashColor: appColours.accent.withValues(alpha: 0.2),
              borderRadius:
                  BorderRadius.all(Radius.circular(themeBorderRadius)),
              child: Padding(
                padding: const EdgeInsets.only(left: 12, right: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 36,
                      color: required ? appColours.error : Color(0xFF000000),
                    ),
                    const VSpacer(8),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14,
                          color:
                              required ? appColours.error : Color(0xFF000000),
                          fontWeight:
                              required ? FontWeight.w600 : FontWeight.w400),
                    )
                  ],
                ),
              ),
            )));
  }
}

class ProfileButtonSkeleton extends StatelessWidget {
  const ProfileButtonSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
        enabled: true,
        child: ProfileButton(
          label: BoneMock.name,
          icon: Icons.refresh,
        ));
  }
}
