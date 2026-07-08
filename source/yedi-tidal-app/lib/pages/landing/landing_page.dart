import 'package:flutter/material.dart';
import 'package:yedi_app/pages/landing/landing_view.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  static const name = 'landing';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: LandingView(),
    );
  }
}
