import 'package:flutter/material.dart';

class Spacer extends StatelessWidget {
  const Spacer(this.size, {this.vertical = true, super.key});

  final double size;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: vertical ? size : null,
      width: vertical ? null : size,
    );
  }
}

class VSpacer extends Spacer {
  const VSpacer(super.size, {super.key}) : super(vertical: true);
}

class HSpacer extends Spacer {
  const HSpacer(super.size, {super.key}) : super(vertical: false);
}
