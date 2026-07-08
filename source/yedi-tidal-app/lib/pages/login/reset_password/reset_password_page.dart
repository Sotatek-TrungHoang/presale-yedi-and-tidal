import 'package:flutter/material.dart';
import 'package:yedi_app/pages/login/reset_password/reset_password_view.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage(
      {required this.email, required this.token, super.key});

  final String email;
  final String token;

  static const name = 'reset-password';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(), body: ResetPasswordView(token: token, email: email));
  }
}
