import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/ui/inputs/text_field_input.dart';
import 'package:yedi_app/ui/settings/cubits/change_password_form_cubit.dart';
import 'package:yedi_app/util/toast.dart';

class ChangePasswordForm extends StatefulWidget {
  const ChangePasswordForm({super.key});

  @override
  State<ChangePasswordForm> createState() => _ChangeEmailFormState();
}

class _ChangeEmailFormState extends State<ChangePasswordForm> {
  late final TextEditingController _currentPasswordController;
  late final TextEditingController _passwordController;
  late final TextEditingController _passwordConfirmationController;

  @override
  void initState() {
    super.initState();

    final formState = context.read<ChangePasswordFormCubit>().state;
    _currentPasswordController =
        TextEditingController(text: formState.currentPassword);
    _passwordController = TextEditingController(text: formState.password);
    _passwordConfirmationController =
        TextEditingController(text: formState.passwordConfirmation);

    _currentPasswordController.addListener(() {
      context
          .read<ChangePasswordFormCubit>()
          .setCurrentPassword(_currentPasswordController.text);
    });

    _passwordController.addListener(() {
      context
          .read<ChangePasswordFormCubit>()
          .setPassword(_passwordController.text);
    });

    _passwordConfirmationController.addListener(() {
      context
          .read<ChangePasswordFormCubit>()
          .setPasswordConfirmation(_passwordConfirmationController.text);
    });
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChangePasswordFormCubit, ChangePasswordFormCubitState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == ChangePasswordFormCubitStatus.success) {
            showSuccessToast("Password updated successfully");
            _currentPasswordController.text = state.currentPassword;
            _passwordController.text = state.password;
            _passwordConfirmationController.text = state.passwordConfirmation;
            setState(() {});
          }
        },
        child:
            BlocBuilder<ChangePasswordFormCubit, ChangePasswordFormCubitState>(
          builder: (context, formState) {
            return Column(
              children: [
                TextFieldInput(
                  label: "Current Password",
                  enabled: formState.canInput,
                  controller: _currentPasswordController,
                  keyboardType: TextInputType.visiblePassword,
                  textCapitalization: TextCapitalization.none,
                  textInputAction: TextInputAction.next,
                  obscureText: true,
                  toggleObscureText: true,
                  errorText: formState.errors['current_password'],
                ),
                TextFieldInput(
                  label: "New Password",
                  enabled: formState.canInput,
                  controller: _passwordController,
                  keyboardType: TextInputType.visiblePassword,
                  textCapitalization: TextCapitalization.none,
                  textInputAction: TextInputAction.next,
                  obscureText: true,
                  toggleObscureText: true,
                  errorText: formState.errors['password'],
                ),
                TextFieldInput(
                  label: "New Password Confirmation",
                  enabled: formState.canInput,
                  controller: _passwordConfirmationController,
                  keyboardType: TextInputType.visiblePassword,
                  textCapitalization: TextCapitalization.none,
                  textInputAction: TextInputAction.done,
                  obscureText: true,
                  toggleObscureText: true,
                  errorText: formState.errors['password_confirmation'],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ElevatedButton(
                        onPressed: formState.canSubmit
                            ? () => context
                                .read<ChangePasswordFormCubit>()
                                .submitEmail()
                            : null,
                        child: Text(formState.isSubmitting
                            ? "Submitting..."
                            : "Change Password")),
                  ],
                ),
              ],
            );
          },
        ));
  }
}
