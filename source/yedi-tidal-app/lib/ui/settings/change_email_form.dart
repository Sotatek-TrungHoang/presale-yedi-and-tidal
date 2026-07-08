import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/authentication/bloc/authentication_bloc.dart';
import 'package:yedi_app/modules/authentication/bloc/authentication_event.dart';
import 'package:yedi_app/modules/authentication/bloc/authentication_state.dart';
import 'package:yedi_app/ui/inputs/text_field_input.dart';
import 'package:yedi_app/ui/settings/cubits/change_email_form_cubit.dart';
import 'package:yedi_app/ui/spacer.dart';
import 'package:yedi_app/ui/theme/app_theme.dart';
import 'package:yedi_app/util/toast.dart';

class ChangeEmailForm extends StatefulWidget {
  const ChangeEmailForm({super.key});

  @override
  State<ChangeEmailForm> createState() => _ChangeEmailFormState();
}

class _ChangeEmailFormState extends State<ChangeEmailForm> {
  late final TextEditingController _currentEmailController;
  late final TextEditingController _newEmailController;
  late final TextEditingController _codeController;

  @override
  void initState() {
    super.initState();

    final formState = context.read<ChangeEmailFormCubit>().state;
    final currentEmail = context.read<AuthenticationBloc>().state.user?.email;
    _currentEmailController = TextEditingController(text: currentEmail);
    _newEmailController = TextEditingController(text: formState.email);
    _codeController = TextEditingController(text: formState.code);

    _newEmailController.addListener(() {
      context.read<ChangeEmailFormCubit>().setEmail(_newEmailController.text);
    });

    _codeController.addListener(() {
      context.read<ChangeEmailFormCubit>().setCode(_codeController.text);
    });
  }

  @override
  void dispose() {
    _currentEmailController.dispose();
    _newEmailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
        listeners: [
          BlocListener<AuthenticationBloc, AuthenticationState>(
            listenWhen: (previous, current) =>
                previous.user?.email != current.user?.email,
            listener: (context, state) {
              _currentEmailController.text = state.user?.email ?? "";
              setState(() {});
            },
          ),
          BlocListener<ChangeEmailFormCubit, ChangeEmailFormCubitState>(
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: (context, state) {
              _newEmailController.text = state.email;
              _codeController.text = state.code;

              if (state.status == ChangeEmailFormCubitStatus.initial &&
                  state.updatedUser != null) {
                showSuccessToast("Email updated successfully");
                context
                    .read<AuthenticationBloc>()
                    .add(ReplaceUserModel(state.updatedUser!));
              }
            },
            child: Container(),
          )
        ],
        child: BlocBuilder<ChangeEmailFormCubit, ChangeEmailFormCubitState>(
          builder: (context, formState) {
            return Column(
              children: [
                TextFieldInput(
                  label: "Current Email Address",
                  enabled: false,
                  controller: _currentEmailController,
                ),
                TextFieldInput(
                  label: "New Email Address",
                  enabled: formState.isInitial,
                  controller: _newEmailController,
                  keyboardType: TextInputType.emailAddress,
                  textCapitalization: TextCapitalization.none,
                  textInputAction: TextInputAction.done,
                ),
                if (formState.isInputtingCode || formState.isVerifyingCode) ...[
                  Text(
                      "A verification code has been sent to ${formState.email}.\nPlease enter the code below to confirm your new email address."),
                  VSpacer(20),
                  TextFieldInput(
                    label: "Verification Code",
                    enabled: formState.isInputtingCode,
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    maxLength: 6,
                  ),
                ],
                if (formState.error != null) ...[
                  Text(
                    formState.error!,
                    style: TextStyle(color: appColours.error),
                  ),
                  VSpacer(20),
                ],
                Row(
                  children: [
                    if (formState.isInitial || formState.isSubmittingEmail) ...[
                      ElevatedButton(
                          onPressed: formState.canRequestChange
                              ? () => context
                                  .read<ChangeEmailFormCubit>()
                                  .submitEmail()
                              : null,
                          child: Text(formState.isInitial
                              ? "Change Email Address"
                              : "Submitting...")),
                      HSpacer(10),
                    ],
                    if (formState.isInputtingCode ||
                        formState.isVerifyingCode) ...[
                      ElevatedButton(
                          onPressed: formState.canVerifyCode
                              ? () => context
                                  .read<ChangeEmailFormCubit>()
                                  .verifyEmail()
                              : null,
                          child: Text("Verify Email")),
                      HSpacer(10),
                      OutlinedButton(
                          onPressed: formState.isInputtingCode
                              ? () =>
                                  context.read<ChangeEmailFormCubit>().cancel()
                              : null,
                          child: Text("Cancel")),
                    ],
                  ],
                ),
              ],
            );
          },
        ));
  }
}
