import 'package:flutter/material.dart';
import 'package:yedi_app/pages/login/forgot_password/forgot_password_view.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  static const name = 'forgot-password';

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(), body: const ForgotPasswordView());
  }
}
