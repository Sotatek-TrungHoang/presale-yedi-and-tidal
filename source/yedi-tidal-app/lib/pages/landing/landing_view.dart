import 'package:flutter/material.dart';
import 'package:yedi_app/pages/landing/landing_content.dart';

class LandingView extends StatelessWidget {
  const LandingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(child: LandingContent());
  }
}
