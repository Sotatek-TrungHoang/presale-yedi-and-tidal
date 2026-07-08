import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:yedi_app/modules/login/bloc/login_bloc.dart';
import 'package:yedi_app/modules/login/bloc/login_event.dart';
import 'package:yedi_app/modules/login/bloc/login_state.dart';
import 'package:yedi_app/pages/login/forgot_password/forgot_password_page.dart';
import 'package:yedi_app/ui/inputs/text_field_input.dart';
import 'package:yedi_app/ui/spacer.dart';
import 'package:yedi_app/ui/theme/app_theme.dart';
import 'package:flutter/services.dart';

class LoginContent extends StatefulWidget {
  const LoginContent({super.key});

  @override
  State<LoginContent> createState() => _LoginContentState();
}

class _LoginContentState extends State<LoginContent> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    final state = context.read<LoginBloc>().state;
    _emailController = TextEditingController(text: state.email);
    _passwordController = TextEditingController(text: state.password);

    _emailController.addListener(() => context
        .read<LoginBloc>()
        .add(LoginEmailChanged(_emailController.text)));
    _passwordController.addListener(() => context
        .read<LoginBloc>()
        .add(LoginPasswordChanged(_passwordController.text)));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(builder: (context, formState) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Container(
                    width: 92,
                    height: 92,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: appColours.landingIconBg,
                        borderRadius: BorderRadius.circular(8)),
                    child: SvgPicture.asset(
                      "assets/$appFlavor/logo.svg",
                      theme: SvgTheme(currentColor: Colors.white),
                    ),
                  ),
                  const VSpacer(36),
                  Text(
                    "Welcome back!",
                    style: TextStyle(fontSize: 24),
                  ),
                  VSpacer(52),
                  TextFieldInput(
                    label: "Email Address",
                    controller: _emailController,
                    errorText: formState.error,
                    textCapitalization: TextCapitalization.none,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    // enabled: !hasUser && !formState.isSubmitting,
                  ),
                  TextFieldInput(
                    label: "Password",
                    controller: _passwordController,
                    obscureText: true,
                    toggleObscureText: true,
                    textCapitalization: TextCapitalization.none,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.done,
                    // enabled: !formState.isSubmitting,
                  ),
                  if (kDebugMode) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _emailController.text =
                                "matthew.woodley+applicant@ne6.studio";
                            _passwordController.text = "password";
                          },
                          child: Text("Applicant"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _emailController.text =
                                "matthew.woodley+advertiser@ne6.studio";
                            _passwordController.text = "password";
                          },
                          child: Text("Advertiser"),
                        ),
                      ],
                    ),
                    VSpacer(20),
                  ],
                  Row(
                    children: [
                      Expanded(
                          child: ElevatedButton(
                              onPressed: formState.canSubmit
                                  ? () {
                                      context
                                          .read<LoginBloc>()
                                          .add(LoginSubmitted());
                                    }
                                  : null,
                              child: Text("Sign In"))),
                    ],
                  ),
                  VSpacer(20),
                  TextButton(
                      onPressed: () => context.goNamed(ForgotPasswordPage.name),
                      child: Text("Forgot Password?")),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
