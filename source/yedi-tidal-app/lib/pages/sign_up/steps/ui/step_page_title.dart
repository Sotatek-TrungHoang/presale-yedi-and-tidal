import 'package:flutter/material.dart';

class StepPageTitle extends StatelessWidget {
  const StepPageTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 20),
    );
  }
}
