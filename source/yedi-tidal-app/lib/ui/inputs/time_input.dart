import 'package:flutter/material.dart';
import 'package:yedi_app/ui/inputs/input_layout.dart';

class TimeInput extends StatelessWidget {
  const TimeInput(
      {required this.label,
      required this.controller,
      this.initialTime,
      this.onChanged,
      this.marginBottom = 20,
      this.errorText,
      this.enabled = true,
      super.key});

  final TextEditingController controller;
  final String label;
  final String? errorText;
  final double marginBottom;
  final TimeOfDay? initialTime;
  final void Function(TimeOfDay)? onChanged;

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
                TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: initialTime ?? TimeOfDay.now(),
                    initialEntryMode: TimePickerEntryMode.inputOnly);
                if (pickedTime != null && context.mounted) {
                  onChanged?.call(pickedTime);
                  controller.text =
                      "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";
                }
              }
            : null,
      ),
      errorText: errorText,
      marginBottom: marginBottom,
    );
  }
}
