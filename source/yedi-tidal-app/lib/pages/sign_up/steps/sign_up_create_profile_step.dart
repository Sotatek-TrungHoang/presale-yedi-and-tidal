import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:yedi_app/modules/authentication/bloc/authentication_bloc.dart';
import 'package:yedi_app/modules/authentication/bloc/authentication_event.dart';
import 'package:yedi_app/modules/authentication/models/auth_user_model.dart';
import 'package:yedi_app/modules/common/services/dropdown_service.dart';
import 'package:yedi_app/modules/sign_up/bloc/create_profile/create_profile_bloc.dart';
import 'package:yedi_app/modules/sign_up/bloc/create_profile/create_profile_event.dart';
import 'package:yedi_app/modules/sign_up/bloc/create_profile/create_profile_state.dart';
import 'package:yedi_app/modules/sign_up/bloc/pages/sign_up_pages_bloc.dart';
import 'package:yedi_app/modules/sign_up/bloc/pages/sign_up_pages_event.dart';
import 'package:yedi_app/modules/sign_up/bloc/pages/sign_up_pages_state.dart';
import 'package:yedi_app/modules/sign_up/services/sign_up_service.dart';
import 'package:yedi_app/pages/sign_up/steps/ui/step_page_title.dart';
import 'package:yedi_app/ui/inputs/date_input.dart';
import 'package:yedi_app/ui/inputs/dropdown_input.dart';
import 'package:yedi_app/ui/inputs/text_field_input.dart';
import 'package:yedi_app/ui/page_error.dart';
import 'package:yedi_app/ui/spacer.dart';
import 'package:yedi_app/l10n/app_localizations.dart';
import 'package:yedi_app/ui/theme/app_theme.dart';
import 'package:yedi_app/util/strings.dart';

class SignUpCreateProfileStep extends StatelessWidget {
  const SignUpCreateProfileStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => CreateProfileBloc(
              signUpService: SignUpService(),
              dropdownService: DropdownService(),
              userType:
                  (context.read<SignUpPagesBloc>().state as SignUpPagesLoaded)
                      .userType,
            )..add(CreateProfileInitialised(
                context.read<AuthenticationBloc>().state.user)),
        child: BlocConsumer<CreateProfileBloc, CreateProfileState>(
          listenWhen: (previous, current) =>
              previous.status != current.status &&
              current.status == CreateProfileStatus.success,
          listener: (context, state) {
            final successResponse = state.successResponse;
            if (successResponse == null) {
              return;
            }

            context.read<AuthenticationBloc>().add(
                ReplaceUserModel(successResponse.user, successResponse.token));
            context
                .read<SignUpPagesBloc>()
                .add(SignUpPagesCreateProfileCompleted());
          },
          builder: (context, state) {
            if (state.status == CreateProfileStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.status == CreateProfileStatus.error) {
              return PageError(
                error: state.error ?? "An error occurred",
              );
            }
            return _SignUpCreateProfileStepLoadedWidget();
          },
        ));
  }
}

class _SignUpCreateProfileStepLoadedWidget extends StatefulWidget {
  const _SignUpCreateProfileStepLoadedWidget();

  @override
  State<_SignUpCreateProfileStepLoadedWidget> createState() =>
      _SignUpCreateProfileStepLoadedWidgetState();
}

class _SignUpCreateProfileStepLoadedWidgetState
    extends State<_SignUpCreateProfileStepLoadedWidget> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _dateOfBirthController;
  late final TextEditingController _telephoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _passwordConfirmationController;
  late final TextEditingController _advertiserNameController;
  late final TextEditingController _advertiserTelephoneController;
  late final TextEditingController _advertiserEmailController;
  late final TextEditingController _advertiserBioController;
  late final TextEditingController _advertiserAdditionalInfoController;

  @override
  void initState() {
    super.initState();

    final formState = context.read<CreateProfileBloc>().state;

    _firstNameController = TextEditingController(text: formState.firstName);
    _lastNameController = TextEditingController(text: formState.lastName);
    _dateOfBirthController = TextEditingController(
      text: formState.dateOfBirth != null
          ? DateFormat('dd/MM/yyyy').format(formState.dateOfBirth!)
          : null,
    );

    _telephoneController = TextEditingController(text: formState.telephone);
    _emailController = TextEditingController(text: formState.email);
    _passwordController = TextEditingController(text: formState.password);
    _passwordConfirmationController =
        TextEditingController(text: formState.passwordConfirmation);

    _advertiserNameController =
        TextEditingController(text: formState.advertiserName);
    _advertiserTelephoneController =
        TextEditingController(text: formState.advertiserTelephone);
    _advertiserEmailController =
        TextEditingController(text: formState.advertiserEmail);
    _advertiserBioController =
        TextEditingController(text: formState.advertiserBio);
    _advertiserAdditionalInfoController =
        TextEditingController(text: formState.advertiserAdditionalInfo);

    _firstNameController.addListener(() {
      context
          .read<CreateProfileBloc>()
          .add(CreateProfileFirstNameChanged(_firstNameController.text));
    });
    _lastNameController.addListener(() {
      context
          .read<CreateProfileBloc>()
          .add(CreateProfileLastNameChanged(_lastNameController.text));
    });

    _telephoneController.addListener(() {
      context
          .read<CreateProfileBloc>()
          .add(CreateProfileTelephoneChanged(_telephoneController.text));
    });

    _emailController.addListener(() {
      context
          .read<CreateProfileBloc>()
          .add(CreateProfileEmailChanged(_emailController.text));
    });

    _passwordController.addListener(() {
      context
          .read<CreateProfileBloc>()
          .add(CreateProfilePasswordChanged(_passwordController.text));
    });

    _passwordConfirmationController.addListener(() {
      context.read<CreateProfileBloc>().add(
          CreateProfilePasswordConfirmationChanged(
              _passwordConfirmationController.text));
    });

    _advertiserNameController.addListener(() => context
        .read<CreateProfileBloc>()
        .add(CreateProfileAdvertiserNameChanged(
            _advertiserNameController.text)));
    _advertiserTelephoneController.addListener(() => context
        .read<CreateProfileBloc>()
        .add(CreateProfileAdvertiserTelephoneChanged(
            _advertiserTelephoneController.text)));
    _advertiserEmailController.addListener(() => context
        .read<CreateProfileBloc>()
        .add(CreateProfileAdvertiserEmailChanged(
            _advertiserEmailController.text)));
    _advertiserBioController.addListener(() => context
        .read<CreateProfileBloc>()
        .add(CreateProfileAdvertiserBioChanged(_advertiserBioController.text)));
    _advertiserAdditionalInfoController.addListener(() => context
        .read<CreateProfileBloc>()
        .add(CreateProfileAdvertiserAdditionalInfoChanged(
            _advertiserAdditionalInfoController.text)));
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    _dateOfBirthController.dispose();
    _advertiserNameController.dispose();
    _advertiserTelephoneController.dispose();
    _advertiserEmailController.dispose();
    _advertiserBioController.dispose();
    _advertiserAdditionalInfoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<SignUpPagesBloc>().state;
    if (state is! SignUpPagesLoaded) {
      throw Exception("Unknown state: $state");
    }

    final currentPage = state.currentPage;

    return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: BlocBuilder<CreateProfileBloc, CreateProfileState>(
            builder: (context, formState) {
          return Column(
            children: [
              StepPageTitle(title: currentPage.title),
              VSpacer(20),
              DropdownInput<String>(
                  items: formState.titleItems,
                  label: "Title",
                  errorText: formState.errors['title'],
                  value: formState.title,
                  onChanged: formState.isSubmitting
                      ? null
                      : (value) {
                          context
                              .read<CreateProfileBloc>()
                              .add(CreateProfileTitleChanged(value));
                        }),
              TextFieldInput(
                label: "First Name",
                controller: _firstNameController,
                errorText: formState.errors['first_name'],
                textCapitalization: TextCapitalization.words,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                enabled: !formState.isSubmitting,
              ),
              TextFieldInput(
                label: "Last Name",
                controller: _lastNameController,
                errorText: formState.errors['last_name'],
                textCapitalization: TextCapitalization.words,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                enabled: !formState.isSubmitting,
              ),
              DateInput(
                label: "D.O.B",
                controller: _dateOfBirthController,
                errorText: formState.errors['date_of_birth'],
                initialDate: formState.dateOfBirth,
                onChanged: (date) {
                  context
                      .read<CreateProfileBloc>()
                      .add(CreateProfileDateOfBirthChanged(date));
                },
                enabled: !formState.isSubmitting,
              ),
              TextFieldInput(
                label: "Telephone Number",
                controller: _telephoneController,
                errorText: formState.errors['telephone'],
                textCapitalization: TextCapitalization.none,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                enabled: !formState.isSubmitting,
              ),
              if (state.userType == UserType.advertiser) ...[
                Divider(),
                VSpacer(20),
                TextFieldInput(
                  label:
                      "${AppLocalizations.of(context)!.advertiser.toTitleCase()} Name",
                  controller: _advertiserNameController,
                  enabled: !formState.isSubmitting,
                  errorText: formState.errors['advertiser.name'],
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                ),
                TextFieldInput(
                  label:
                      "${AppLocalizations.of(context)!.advertiser.toTitleCase()} Email",
                  controller: _advertiserEmailController,
                  enabled: !formState.isSubmitting,
                  errorText: formState.errors['advertiser.email'],
                  keyboardType: TextInputType.emailAddress,
                  textCapitalization: TextCapitalization.none,
                  textInputAction: TextInputAction.next,
                ),
                TextFieldInput(
                  label:
                      "${AppLocalizations.of(context)!.advertiser.toTitleCase()} Telephone",
                  controller: _advertiserTelephoneController,
                  enabled: !formState.isSubmitting,
                  errorText: formState.errors['advertiser.telephone'],
                  keyboardType: TextInputType.phone,
                  textCapitalization: TextCapitalization.none,
                  textInputAction: TextInputAction.next,
                ),
                TextFieldInput(
                  label:
                      "${AppLocalizations.of(context)!.advertiser.toTitleCase()} Bio",
                  controller: _advertiserBioController,
                  enabled: !formState.isSubmitting,
                  errorText: formState.errors['advertiser.bio'],
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.newline,
                  maxLines: 8,
                ),
                TextFieldInput(
                  label:
                      "${AppLocalizations.of(context)!.advertiser.toTitleCase()} Additional Info",
                  controller: _advertiserAdditionalInfoController,
                  enabled: !formState.isSubmitting,
                  errorText: formState.errors['advertiser.additional_info'],
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.newline,
                  maxLines: 8,
                ),
              ],
              if (state.userType == UserType.applicant) ...[
                Divider(),
                VSpacer(20),
                DropdownInput<int>(
                    items: formState.jobRoleItems,
                    label: "Job Role",
                    errorText: formState.errors['job_role_id'],
                    value: formState.jobRole,
                    onChanged: formState.isSubmitting
                        ? null
                        : (value) {
                            context
                                .read<CreateProfileBloc>()
                                .add(CreateProfileJobRoleChanged(value));
                          }),
                DropdownInput<int>(
                    items: formState.typeOfWorkItems,
                    label: "Type of Work",
                    errorText: formState.errors['type_of_work_id'],
                    value: formState.typeOfWork,
                    onChanged: formState.isSubmitting
                        ? null
                        : (value) {
                            context
                                .read<CreateProfileBloc>()
                                .add(CreateProfileTypeOfWorkChanged(value));
                          }),
              ],
              Divider(),
              VSpacer(20),
              TextFieldInput(
                label: "Account Email Address",
                controller: _emailController,
                errorText: formState.errors['email'],
                textCapitalization: TextCapitalization.none,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                enabled: !formState.isSubmitting,
              ),
              TextFieldInput(
                label: "Account Password",
                controller: _passwordController,
                errorText: formState.errors['password'],
                obscureText: true,
                toggleObscureText: true,
                textCapitalization: TextCapitalization.none,
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.next,
                enabled: !formState.isSubmitting,
              ),
              TextFieldInput(
                label: "Verify Account Password",
                controller: _passwordConfirmationController,
                errorText: formState.errors['password_confirmation'],
                obscureText: true,
                toggleObscureText: true,
                textCapitalization: TextCapitalization.none,
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.done,
                enabled: !formState.isSubmitting,
              ),
              if (formState.error != null) ...[
                Text(
                  formState.error!,
                  style: TextStyle(color: appColours.error),
                  textAlign: TextAlign.center,
                ),
                VSpacer(20),
              ],
              Row(
                children: [
                  Expanded(
                      child: ElevatedButton(
                          onPressed: formState.isSubmitting
                              ? null
                              : () {
                                  context
                                      .read<CreateProfileBloc>()
                                      .add(CreateProfileSubmitted());
                                },
                          child: Text(formState.isSubmitting
                              ? "Processing..."
                              : "Next Step"))),
                ],
              ),
            ],
          );
        }));
  }
}
