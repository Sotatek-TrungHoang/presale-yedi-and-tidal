import 'package:flutter/material.dart';
import 'package:yedi_app/ui/theme/app_theme.dart';

class InputError extends StatelessWidget {
  const InputError({required this.errorText, super.key});

  final String errorText;

  @override
  Widget build(BuildContext context) {
    return Text(
      errorText,
      style: TextStyle(
        color: appColours.error,
        fontSize: 12,
      ),
    );
  }
}
