import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/authentication/bloc/authentication_bloc.dart';
import 'package:yedi_app/modules/authentication/bloc/authentication_event.dart';
import 'package:yedi_app/modules/common/services/dropdown_service.dart';
import 'package:yedi_app/modules/sign_up/bloc/pages/sign_up_pages_bloc.dart';
import 'package:yedi_app/modules/sign_up/bloc/pages/sign_up_pages_event.dart';
import 'package:yedi_app/modules/sign_up/bloc/pages/sign_up_pages_state.dart';
import 'package:yedi_app/modules/sign_up/bloc/qualifications/qualifications_bloc.dart';
import 'package:yedi_app/modules/sign_up/bloc/qualifications/qualifications_event.dart';
import 'package:yedi_app/modules/sign_up/bloc/qualifications/qualifications_state.dart';
import 'package:yedi_app/modules/sign_up/services/sign_up_service.dart';
import 'package:yedi_app/pages/sign_up/steps/ui/step_page_title.dart';
import 'package:yedi_app/ui/inputs/dropdown_input.dart';
import 'package:yedi_app/ui/inputs/text_field_input.dart';
import 'package:yedi_app/ui/page_error.dart';
import 'package:yedi_app/ui/spacer.dart';

class SignUpQualificationsStep extends StatelessWidget {
  const SignUpQualificationsStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => QualificationsBloc(
              signUpService: SignUpService(),
              dropdownService: DropdownService(),
            )..add(QualificationsInitialised(
                context.read<AuthenticationBloc>().state.user)),
        child: BlocConsumer<QualificationsBloc, QualificationsState>(
          listenWhen: (previous, current) =>
              previous.status != current.status &&
              current.status == QualificationsStatus.success,
          listener: (context, state) {
            final updatedUser = state.updatedUser;
            if (updatedUser == null) {
              return;
            }

            context
                .read<AuthenticationBloc>()
                .add(ReplaceUserModel(updatedUser));
            context.read<SignUpPagesBloc>().add(SignUpPagesAddressCompleted());
          },
          builder: (context, state) {
            if (state.status == QualificationsStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.status == QualificationsStatus.error) {
              return PageError(
                error: state.error ?? "An error occurred",
              );
            }
            return _SignUpQualificationsStepWidget();
          },
        ));
  }
}

class _SignUpQualificationsStepWidget extends StatefulWidget {
  const _SignUpQualificationsStepWidget();

  @override
  State<_SignUpQualificationsStepWidget> createState() =>
      _SignUpCreateProfileStepLoadedWidgetState();
}

class _SignUpCreateProfileStepLoadedWidgetState
    extends State<_SignUpQualificationsStepWidget> {
  late final TextEditingController _teacherNumberController;

  @override
  void initState() {
    super.initState();

    final formState = context.read<QualificationsBloc>().state;
    _teacherNumberController =
        TextEditingController(text: formState.teacherNumber);

    _teacherNumberController.addListener(() => context
        .read<QualificationsBloc>()
        .add(
            QualificationsTeacherNumberChanged(_teacherNumberController.text)));
  }

  @override
  void dispose() {
    _teacherNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: BlocBuilder<SignUpPagesBloc, SignUpPagesState>(
          buildWhen: (previous, current) => false,
          builder: (context, state) {
            if (state is! SignUpPagesLoaded) {
              throw Exception("Unknown state: $state");
            }

            final currentPage = state.currentPage;

            return BlocBuilder<QualificationsBloc, QualificationsState>(
                builder: (context, formState) {
              return Column(
                children: [
                  StepPageTitle(title: currentPage.title),
                  VSpacer(20),
                  if (currentPage.requireTeacherNumber == true)
                    TextFieldInput(
                      label: "Teacher Number",
                      controller: _teacherNumberController,
                      errorText: formState.errors['teacher_number'],
                      textCapitalization: TextCapitalization.characters,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      enabled: !formState.isSubmitting,
                    ),
                  DropdownInput<String>(
                      items: formState.qualificationItems,
                      label: "Qualification",
                      errorText: formState.errors['qualification'],
                      value: formState.qualification,
                      onChanged: formState.isSubmitting
                          ? null
                          : (value) {
                              context.read<QualificationsBloc>().add(
                                  QualificationsQualificationChanged(value));
                            }),
                  Row(
                    children: [
                      Expanded(
                          child: ElevatedButton(
                              onPressed: formState.isSubmitting
                                  ? null
                                  : () {
                                      context
                                          .read<QualificationsBloc>()
                                          .add(QualificationsSubmitted());
                                    },
                              child: Text(formState.isSubmitting
                                  ? "Processing..."
                                  : "Next Step"))),
                    ],
                  )
                ],
              );
            });
          },
        ));
  }
}
