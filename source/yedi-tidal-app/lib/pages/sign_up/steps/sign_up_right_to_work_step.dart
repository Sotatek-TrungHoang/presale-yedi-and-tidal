import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/authentication/bloc/authentication_bloc.dart';
import 'package:yedi_app/modules/authentication/bloc/authentication_event.dart';
import 'package:yedi_app/modules/sign_up/bloc/pages/sign_up_pages_bloc.dart';
import 'package:yedi_app/modules/sign_up/bloc/pages/sign_up_pages_event.dart';
import 'package:yedi_app/modules/sign_up/bloc/pages/sign_up_pages_state.dart';
import 'package:yedi_app/modules/sign_up/bloc/right_to_work/right_to_work_bloc.dart';
import 'package:yedi_app/modules/sign_up/bloc/right_to_work/right_to_work_event.dart';
import 'package:yedi_app/modules/sign_up/bloc/right_to_work/right_to_work_state.dart';
import 'package:yedi_app/modules/sign_up/services/sign_up_service.dart';
import 'package:yedi_app/pages/sign_up/steps/ui/step_page_title.dart';
import 'package:yedi_app/ui/inputs/input_error.dart';
import 'package:yedi_app/ui/inputs/input_label.dart';
import 'package:yedi_app/ui/inputs/yes_no_input.dart';
import 'package:yedi_app/ui/page_error.dart';
import 'package:yedi_app/ui/spacer.dart';

class SignUpRightToWorkStep extends StatelessWidget {
  const SignUpRightToWorkStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => RightToWorkBloc(
              signUpService: SignUpService(),
            )..add(RightToWorkInitialised(
                context.read<AuthenticationBloc>().state.user)),
        child: BlocConsumer<RightToWorkBloc, RightToWorkState>(
          listenWhen: (previous, current) =>
              previous.status != current.status &&
              current.status == RightToWorkStatus.success,
          listener: (context, state) {
            final updatedUser = state.updatedUser;
            if (updatedUser == null) {
              return;
            }

            context
                .read<AuthenticationBloc>()
                .add(ReplaceUserModel(updatedUser));
            context
                .read<SignUpPagesBloc>()
                .add(SignUpPagesRightToWorkDeclarationCompleted());
          },
          builder: (context, state) {
            if (state.status == RightToWorkStatus.error) {
              return PageError(
                error: state.error ?? "An error occurred",
              );
            }
            return _SignUpRightToWorkStepWidget();
          },
        ));
  }
}

class _SignUpRightToWorkStepWidget extends StatelessWidget {
  const _SignUpRightToWorkStepWidget();

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

            return BlocBuilder<RightToWorkBloc, RightToWorkState>(
                builder: (context, formState) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  StepPageTitle(
                    title: currentPage.title,
                  ),
                  VSpacer(20),
                  InputLabel(label: "Do you have the right to work in the UK?"),
                  VSpacer(6),
                  Row(
                    children: [
                      Expanded(
                          child: YesNoInput(
                        text: "Yes",
                        value: formState.rightToWorkUk == true,
                        onChanged: (_) => context
                            .read<RightToWorkBloc>()
                            .add(RightToWorkRightToWorkUkChanged(true)),
                      )),
                      HSpacer(20),
                      Expanded(
                          child: YesNoInput(
                        text: "No",
                        value: formState.rightToWorkUk == false,
                        onChanged: (_) => context
                            .read<RightToWorkBloc>()
                            .add(RightToWorkRightToWorkUkChanged(false)),
                      )),
                    ],
                  ),
                  if (formState.errors['right_to_work_uk'] != null) ...[
                    VSpacer(6),
                    InputError(
                        errorText: formState.errors['right_to_work_uk']!),
                  ],
                  VSpacer(24),
                  InputLabel(label: "Do you require a visa to work in the UK?"),
                  VSpacer(6),
                  Row(
                    children: [
                      Expanded(
                          child: YesNoInput(
                        text: "Yes",
                        value: formState.requireVisaToWorkUk == true,
                        onChanged: (_) => context
                            .read<RightToWorkBloc>()
                            .add(RightToWorkRequireVisaToWorkUkChanged(true)),
                      )),
                      HSpacer(20),
                      Expanded(
                          child: YesNoInput(
                        text: "No",
                        value: formState.requireVisaToWorkUk == false,
                        onChanged: (_) => context
                            .read<RightToWorkBloc>()
                            .add(RightToWorkRequireVisaToWorkUkChanged(false)),
                      )),
                    ],
                  ),
                  if (formState.errors['require_visa_to_work_uk'] != null) ...[
                    VSpacer(6),
                    InputError(
                        errorText:
                            formState.errors['require_visa_to_work_uk']!),
                  ],
                  VSpacer(24),
                  InputLabel(
                      label:
                          "Have you lived or worked outside of the UK for more than 6 months in the past 5 years?"),
                  VSpacer(6),
                  Row(
                    children: [
                      Expanded(
                          child: YesNoInput(
                        text: "Yes",
                        value: formState.livedOrWorkedOutsideUk6Months == true,
                        onChanged: (_) => context.read<RightToWorkBloc>().add(
                            RightToWorkLivedOrWorkedOutsideUk6MonthsChanged(
                                true)),
                      )),
                      HSpacer(20),
                      Expanded(
                          child: YesNoInput(
                        text: "No",
                        value: formState.livedOrWorkedOutsideUk6Months == false,
                        onChanged: (_) => context.read<RightToWorkBloc>().add(
                            RightToWorkLivedOrWorkedOutsideUk6MonthsChanged(
                                false)),
                      )),
                    ],
                  ),
                  if (formState.errors['lived_or_worked_outside_uk_6_months'] !=
                      null) ...[
                    VSpacer(6),
                    InputError(
                        errorText: formState
                            .errors['lived_or_worked_outside_uk_6_months']!),
                  ],
                  VSpacer(24),
                  InputLabel(
                      label:
                          "As you are applying to work in a regulated activity (working with children), please confirm, subject to filtering, if you have any spent or unspent criminal convictions or prosecutions pending?"),
                  VSpacer(6),
                  Row(
                    children: [
                      Expanded(
                          child: YesNoInput(
                        text: "Yes",
                        value: formState
                                .hasCriminalConvictionsOrProsecutionsPending ==
                            true,
                        onChanged: (_) => context.read<RightToWorkBloc>().add(
                            RightToWorkHasCriminalConvictionsOrProsecutionsPendingChanged(
                                true)),
                      )),
                      HSpacer(20),
                      Expanded(
                          child: YesNoInput(
                        text: "No",
                        value: formState
                                .hasCriminalConvictionsOrProsecutionsPending ==
                            false,
                        onChanged: (_) => context.read<RightToWorkBloc>().add(
                            RightToWorkHasCriminalConvictionsOrProsecutionsPendingChanged(
                                false)),
                      )),
                    ],
                  ),
                  if (formState.errors[
                          'has_criminal_convictions_or_prosecutions_pending'] !=
                      null) ...[
                    VSpacer(6),
                    InputError(
                        errorText: formState.errors[
                            'has_criminal_convictions_or_prosecutions_pending']!),
                  ],
                  VSpacer(56),
                  Row(
                    children: [
                      Expanded(
                          child: ElevatedButton(
                              onPressed: !formState.canSubmit
                                  ? null
                                  : () {
                                      context
                                          .read<RightToWorkBloc>()
                                          .add(RightToWorkSubmitted());
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
