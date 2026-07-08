import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/authentication/bloc/authentication_bloc.dart';
import 'package:yedi_app/modules/authentication/bloc/authentication_event.dart';
import 'package:yedi_app/modules/sign_up/bloc/compliance/compliance_form_bloc.dart';
import 'package:yedi_app/modules/sign_up/bloc/compliance/compliance_form_event.dart';
import 'package:yedi_app/modules/sign_up/bloc/compliance/compliance_form_state.dart';
import 'package:yedi_app/modules/sign_up/bloc/pages/sign_up_pages_bloc.dart';
import 'package:yedi_app/modules/sign_up/bloc/pages/sign_up_pages_event.dart';
import 'package:yedi_app/modules/sign_up/bloc/pages/sign_up_pages_state.dart';
import 'package:yedi_app/modules/sign_up/services/sign_up_service.dart';
import 'package:yedi_app/modules/sign_up/services/video_verification_service.dart';
import 'package:yedi_app/pages/sign_up/steps/ui/photo_upload_widget.dart';
import 'package:yedi_app/pages/sign_up/steps/ui/step_page_title.dart';
import 'package:yedi_app/pages/sign_up/steps/ui/video_verification_widget.dart';
import 'package:yedi_app/ui/spacer.dart';
import 'package:yedi_app/ui/theme/app_theme.dart';

class SignUpComplianceStep extends StatelessWidget {
  const SignUpComplianceStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => ComplianceFormBloc(
              signUpService: SignUpService(),
              videoVerificationService: VideoVerificationService(),
            )..add(ComplianceFormInitialised(
                context.read<AuthenticationBloc>().state.user)),
        child: BlocListener<ComplianceFormBloc, ComplianceFormState>(
          listenWhen: (previous, current) =>
              current.status == ComplianceFormStatus.success,
          listener: (context, state) {
            context
                .read<AuthenticationBloc>()
                .add(ReplaceUserModel(state.updatedUser!));
            context
                .read<SignUpPagesBloc>()
                .add(SignUpPagesComplianceCompleted());
          },
          child: _SignUpComplianceStepWidget(),
        ));
  }
}

class _SignUpComplianceStepWidget extends StatelessWidget {
  const _SignUpComplianceStepWidget();

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

            return Column(
              children: [
                StepPageTitle(title: currentPage.title),
                VSpacer(20),
                BlocBuilder<ComplianceFormBloc, ComplianceFormState>(
                  buildWhen: (previous, current) =>
                      previous.photograph != current.photograph ||
                      previous.status != current.status,
                  builder: (context, state) => PhotoUploadWidget(
                      uploadModel: state.photograph,
                      onUploaded: state.isSubmitting
                          ? null
                          : (upload) => context
                              .read<ComplianceFormBloc>()
                              .add(ComplianceFormPhotographChanged(upload)),
                      incompleteButtonText: "Upload Your Photograph",
                      completeButtonText: "Retake Photo",
                      label: "Your Photograph",
                      errorText: state.errors['photograph_id']),
                ),
                VSpacer(26),
                BlocBuilder<ComplianceFormBloc, ComplianceFormState>(
                    buildWhen: (previous, current) =>
                        previous.evidenceOfId != current.evidenceOfId ||
                        previous.status != current.status,
                    builder: (context, state) => PhotoUploadWidget(
                          uploadModel: state.evidenceOfId,
                          onUploaded: state.isSubmitting
                              ? null
                              : (upload) => context
                                  .read<ComplianceFormBloc>()
                                  .add(ComplianceFormEvidenceOfIdChanged(
                                      upload)),
                          incompleteButtonText: "Evidence of I.D",
                          completeButtonText: "Retake Photo",
                          label: "Upload Evidence of I.D",
                          infoText: "(Passport or Driving Licence)",
                          errorText: state.errors['evidence_of_id_id'],
                        )),
                VSpacer(26),
                BlocBuilder<ComplianceFormBloc, ComplianceFormState>(
                    buildWhen: (previous, current) =>
                        previous.videoVerification !=
                            current.videoVerification ||
                        previous.status != current.status,
                    builder: (context, state) => VideoVerificationWidget(
                        videoVerification: state.videoVerification,
                        onSubmit: state.isSubmitting
                            ? null
                            : (videoVerification) => context
                                .read<ComplianceFormBloc>()
                                .add(ComplianceFormVideoVerificationChanged(
                                    videoVerification)))),
                VSpacer(20),
                BlocBuilder<ComplianceFormBloc, ComplianceFormState>(
                  buildWhen: (previous, current) =>
                      previous.error != current.error,
                  builder: (context, state) => state.error != null
                      ? Text(
                          state.error!,
                          style: TextStyle(color: appColours.error),
                        )
                      : Container(),
                ),
                VSpacer(20),
                Row(
                  children: [
                    BlocBuilder<ComplianceFormBloc, ComplianceFormState>(
                      builder: (context, state) => Expanded(
                          child: ElevatedButton(
                              onPressed: !state.canSubmit
                                  ? null
                                  : () {
                                      context
                                          .read<ComplianceFormBloc>()
                                          .add(ComplianceFormSubmitted());
                                    },
                              child: Text(state.isSubmitting
                                  ? "Submitting..."
                                  : "Next Step"))),
                    )
                  ],
                )
              ],
            );
          },
        ));
  }
}
