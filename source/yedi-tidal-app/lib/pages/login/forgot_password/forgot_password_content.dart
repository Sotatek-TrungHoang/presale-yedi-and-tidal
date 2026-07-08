import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:yedi_app/modules/forgot_password/bloc/forgot_password_cubit.dart';
import 'package:yedi_app/ui/inputs/text_field_input.dart';
import 'package:yedi_app/ui/page_error.dart';
import 'package:yedi_app/ui/spacer.dart';
import 'package:yedi_app/ui/theme/app_theme.dart';

class ForgotPasswordContent extends StatefulWidget {
  const ForgotPasswordContent({super.key});

  @override
  State<ForgotPasswordContent> createState() => _ForgotPasswordContentState();
}

class _ForgotPasswordContentState extends State<ForgotPasswordContent> {
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() => context
        .read<ForgotPasswordCubit>()
        .fieldUpdated('email', _emailController.text));
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = context.watch<ForgotPasswordCubit>().state;
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
                  "Forgot Password",
                  style: TextStyle(fontSize: 24),
                ),
                if (formState.isSuccess) ...[
                  PageError(
                    error:
                        "Password reset link sent successfully.\nPlease check your emails.",
                    icon: Icons.check,
                    iconColour: appColours.success,
                  ),
                ] else ...[
                  VSpacer(26),
                  Text(
                    "Enter your email address below to receive a password reset link.",
                    textAlign: TextAlign.center,
                  ),
                  VSpacer(26),
                  TextFieldInput(
                      label: "Email Address",
                      controller: _emailController,
                      errorText: formState.error,
                      textCapitalization: TextCapitalization.none,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      enabled: formState.isIdle),
                  Row(
                    children: [
                      Expanded(
                          child: ElevatedButton(
                              onPressed: formState.isIdle &&
                                      formState.data['email'].isNotEmpty
                                  ? () {
                                      context
                                          .read<ForgotPasswordCubit>()
                                          .submit();
                                    }
                                  : null,
                              child: Text("Send Reset Link"))),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
