import 'package:flutter/material.dart';
import 'package:yedi_app/ui/spacer.dart';

class AdvertDetail extends StatelessWidget {
  const AdvertDetail(
      {required this.icon, required this.label, this.trailing, super.key});

  final IconData icon;
  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 24,
        ),
        HSpacer(10),
        Expanded(
          child: Text(label, style: TextStyle(fontSize: 16)),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
