import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/authentication/bloc/authentication_bloc.dart';
import 'package:yedi_app/modules/authentication/bloc/authentication_event.dart';
import 'package:yedi_app/modules/login/bloc/login_bloc.dart';
import 'package:yedi_app/modules/login/bloc/login_state.dart';
import 'package:yedi_app/pages/login/login_content.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocListener<LoginBloc, LoginState>(
          listenWhen: (previous, current) =>
              current.status == LoginStatus.success,
          listener: (context, state) {
            final successResponse = state.successResponse!;
            context.read<AuthenticationBloc>().add(
                ReplaceUserModel(successResponse.user, successResponse.token));
          },
          child: LoginContent()),
    );
  }
}
