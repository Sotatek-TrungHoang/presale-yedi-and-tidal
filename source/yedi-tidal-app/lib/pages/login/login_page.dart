import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/authentication/services/authentication_service.dart';
import 'package:yedi_app/modules/login/bloc/login_bloc.dart';
import 'package:yedi_app/pages/login/login_view.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static const name = 'login';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: BlocProvider(
          create: (context) => LoginBloc(context.read<AuthenticationService>()),
          child: const LoginView(),
        ));
  }
}
