import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yedi_app/ui/inputs/input_layout.dart';

class DateInput extends StatelessWidget {
  const DateInput(
      {required this.label,
      required this.controller,
      this.initialDate,
      this.onChanged,
      this.marginBottom = 20,
      this.errorText,
      this.enabled = true,
      this.firstDate,
      this.lastDate,
      super.key});

  final TextEditingController controller;
  final String label;
  final String? errorText;
  final double marginBottom;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final void Function(DateTime)? onChanged;

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return InputLayout(
      label: label,
      input: TextFormField(
        enabled: enabled,
        readOnly: true,
        controller: controller,
        onTap: enabled
            ? () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: initialDate ?? DateTime.now(),
                  firstDate: firstDate ?? DateTime(1900),
                  lastDate: lastDate ?? DateTime.now(),
                );
                if (pickedDate != null && context.mounted) {
                  onChanged?.call(pickedDate);
                  controller.text = DateFormat('dd/MM/yyyy').format(pickedDate);
                }
              }
            : null,
      ),
      errorText: errorText,
      marginBottom: marginBottom,
    );
  }
}
