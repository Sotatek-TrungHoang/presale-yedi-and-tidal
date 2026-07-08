import 'package:flutter/material.dart';
import 'package:yedi_app/ui/theme/app_theme.dart';

class InputLabel extends StatelessWidget {
  const InputLabel({required this.label, this.errorText, super.key});

  final String label;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: TextStyle(
            fontSize: 14,
            color: errorText != null ? appColours.error : Colors.black,
            fontWeight: errorText != null ? FontWeight.w600 : FontWeight.w500));
  }
}
