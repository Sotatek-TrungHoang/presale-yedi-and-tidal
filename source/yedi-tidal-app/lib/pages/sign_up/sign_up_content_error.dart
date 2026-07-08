import 'package:flutter/material.dart';
import 'package:yedi_app/ui/page_error.dart';

class SignUpContentError extends StatelessWidget {
  const SignUpContentError(this.error, {super.key});
  final String error;

  @override
  Widget build(BuildContext context) {
    return PageError(error: error);
  }
}
