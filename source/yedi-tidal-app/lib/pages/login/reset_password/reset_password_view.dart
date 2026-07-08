import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yedi_app/modules/authentication/services/authentication_service.dart';
import 'package:yedi_app/modules/common/cubits/generic_form_state.dart';
import 'package:yedi_app/modules/reset_password/bloc/reset_password_cubit.dart';
import 'package:yedi_app/pages/login/login_page.dart';
import 'package:yedi_app/pages/login/reset_password/reset_password_content.dart';
import 'package:yedi_app/util/toast.dart';

class ResetPasswordView extends StatelessWidget {
  const ResetPasswordView(
      {required this.email, required this.token, super.key});

  final String email;
  final String token;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ResetPasswordCubit(
        email: email,
        token: token,
        authenticationService: context.read<AuthenticationService>(),
      ),
      child: MultiBlocListener(
        listeners: [
          BlocListener<ResetPasswordCubit, ResetPasswordState>(
            listenWhen: (previous, current) {
              return previous.status != current.status &&
                  current.status == FormStatus.success;
            },
            listener: (context, state) {
              showSuccessToast("Password reset successfully");
              context.goNamed(LoginPage.name);
            },
          ),
          BlocListener<ResetPasswordCubit, ResetPasswordState>(
            listenWhen: (previous, current) {
              return previous.error == null && current.error != null;
            },
            listener: (context, state) {
              showErrorToast(state.error!);
            },
          ),
        ],
        child: ResetPasswordContent(),
      ),
    );
  }
}
