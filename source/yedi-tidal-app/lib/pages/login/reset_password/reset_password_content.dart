import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:yedi_app/modules/reset_password/bloc/reset_password_cubit.dart';
import 'package:yedi_app/ui/inputs/text_field_input.dart';
import 'package:yedi_app/ui/spacer.dart';
import 'package:yedi_app/ui/theme/app_theme.dart';

class ResetPasswordContent extends StatefulWidget {
  const ResetPasswordContent({super.key});

  @override
  State<ResetPasswordContent> createState() => _ResetPasswordContentState();
}

class _ResetPasswordContentState extends State<ResetPasswordContent> {
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() => context
        .read<ResetPasswordCubit>()
        .fieldUpdated('password', _passwordController.text));
    _passwordConfirmationController.addListener(() => context
        .read<ResetPasswordCubit>()
        .fieldUpdated(
            'password_confirmation', _passwordConfirmationController.text));
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = context.watch<ResetPasswordCubit>().state;
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
                  "Reset Password",
                  style: TextStyle(fontSize: 24),
                ),
                VSpacer(52),
                TextFieldInput(
                    label: "New Password",
                    controller: _passwordController,
                    errorText: formState.errors['password'],
                    textCapitalization: TextCapitalization.none,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.next,
                    obscureText: true,
                    toggleObscureText: true,
                    enabled: formState.isIdle),
                TextFieldInput(
                    label: "New Password Confirmation",
                    controller: _passwordConfirmationController,
                    errorText: formState.errors['password_confirmation'],
                    textCapitalization: TextCapitalization.none,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.next,
                    obscureText: true,
                    toggleObscureText: true,
                    enabled: formState.isIdle),
                Row(
                  children: [
                    Expanded(
                        child: ElevatedButton(
                            onPressed: formState.isIdle &&
                                    formState.data['password'].isNotEmpty &&
                                    formState.data['password_confirmation']
                                        .isNotEmpty
                                ? () {
                                    context.read<ResetPasswordCubit>().submit();
                                  }
                                : null,
                            child: Text("Reset Password"))),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
