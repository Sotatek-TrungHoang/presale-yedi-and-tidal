import 'package:flutter/material.dart';
import 'package:yedi_app/ui/inputs/input_error.dart';
import 'package:yedi_app/ui/inputs/input_label.dart';
import 'package:yedi_app/ui/spacer.dart';

class InputLayout extends StatelessWidget {
  const InputLayout(
      {required this.input,
      required this.label,
      this.marginBottom = 20,
      this.errorText,
      super.key});

  final Widget input;
  final String label;
  final String? errorText;
  final double marginBottom;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        InputLabel(
          label: label,
          errorText: errorText,
        ),
        VSpacer(6),
        input,
        if (errorText != null) ...[
          VSpacer(6),
          InputError(errorText: errorText!)
        ],
        VSpacer(marginBottom),
      ],
    );
  }
}
