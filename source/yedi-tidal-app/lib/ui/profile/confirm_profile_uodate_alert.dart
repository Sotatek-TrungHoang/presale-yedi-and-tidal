import 'package:flutter/material.dart';

class ConfirmProfileUpdateAlert extends StatelessWidget {
  const ConfirmProfileUpdateAlert({
    super.key,
    this.title = "Confirm Update",
    required this.content,
    required this.dialogContext,
    required this.onConfirm,
  });

  final BuildContext dialogContext;
  final void Function() onConfirm;
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        OutlinedButton(
          onPressed: () {
            Navigator.of(dialogContext).pop(); // Close the dialog
          },
          child: Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(dialogContext).pop(); // Close the dialog
            onConfirm();
          },
          child: Text("Update"),
        ),
      ],
    );
  }
}
