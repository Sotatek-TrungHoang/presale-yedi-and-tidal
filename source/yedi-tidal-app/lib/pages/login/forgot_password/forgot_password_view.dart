import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/authentication/services/authentication_service.dart';
import 'package:yedi_app/modules/forgot_password/bloc/forgot_password_cubit.dart';
import 'package:yedi_app/pages/login/forgot_password/forgot_password_content.dart';

class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ForgotPasswordCubit(
        authenticationService: context.read<AuthenticationService>(),
      ),
      child: ForgotPasswordContent(),
    );
  }
}
