import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/authentication/bloc/authentication_bloc.dart';
import 'package:yedi_app/modules/authentication/bloc/authentication_event.dart';
import 'package:yedi_app/modules/sign_up/bloc/evidence/evidence_bloc.dart';
import 'package:yedi_app/modules/sign_up/bloc/evidence/evidence_event.dart';
import 'package:yedi_app/modules/sign_up/bloc/evidence/evidence_state.dart';
import 'package:yedi_app/modules/sign_up/bloc/pages/sign_up_pages_bloc.dart';
import 'package:yedi_app/modules/sign_up/bloc/pages/sign_up_pages_event.dart';
import 'package:yedi_app/modules/sign_up/bloc/pages/sign_up_pages_state.dart';
import 'package:yedi_app/modules/sign_up/services/evidence_service.dart';
import 'package:yedi_app/modules/sign_up/services/sign_up_service.dart';
import 'package:yedi_app/pages/sign_up/steps/ui/step_page_title.dart';
import 'package:yedi_app/ui/inputs/file_upload_input.dart';
import 'package:yedi_app/ui/page_error.dart';
import 'package:yedi_app/ui/spacer.dart';

class SignUpEvidenceStep extends StatelessWidget {
  const SignUpEvidenceStep({required this.requiredEvidenceId, super.key});

  final int requiredEvidenceId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => EvidenceBloc(
              requiredEvidenceId: requiredEvidenceId,
              signUpService: SignUpService(),
              evidenceService: EvidenceService(),
            )..add(EvidenceInitialised(
                context.read<AuthenticationBloc>().state.user)),
        child: BlocConsumer<EvidenceBloc, EvidenceState>(
          listenWhen: (previous, current) =>
              previous.status != current.status &&
              current.status == EvidenceStatus.success,
          listener: (context, state) {
            final updatedUser = state.updatedUser;
            if (updatedUser == null) {
              return;
            }

            context
                .read<AuthenticationBloc>()
                .add(ReplaceUserModel(updatedUser));
            context.read<SignUpPagesBloc>().add(SignUpPagesEvidenceCompleted());
          },
          builder: (context, state) {
            if (state.status == EvidenceStatus.error) {
              return PageError(
                error: state.error ?? "An error occurred",
              );
            }
            return _SignUpEvidenceStepWidget();
          },
        ));
  }
}

class _SignUpEvidenceStepWidget extends StatefulWidget {
  const _SignUpEvidenceStepWidget();

  @override
  State<_SignUpEvidenceStepWidget> createState() =>
      _SignUpCreateProfileStepLoadedWidgetState();
}

class _SignUpCreateProfileStepLoadedWidgetState
    extends State<_SignUpEvidenceStepWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<SignUpPagesBloc>().state;
    if (state is! SignUpPagesLoaded) {
      throw Exception("Unknown state: $state");
    }

    final currentPage = state.currentPage;
    final requiredEvidence = currentPage.requiredEvidence!;

    return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: BlocBuilder<EvidenceBloc, EvidenceState>(
          builder: (context, formState) {
            return Column(
              children: [
                StepPageTitle(title: currentPage.title),
                VSpacer(20),
                FileUploadInput(
                  buttonText: "Upload ${requiredEvidence.title}",
                  errorText: formState.errors["upload_id"],
                  uploadModel: formState.upload,
                  onUploaded: (upload) => context
                      .read<EvidenceBloc>()
                      .add(EvidenceUploadChanged(upload)),
                ),
                VSpacer(56),
                Row(
                  children: [
                    Expanded(
                        child: ElevatedButton(
                            onPressed: !formState.canSubmit
                                ? null
                                : () {
                                    context
                                        .read<EvidenceBloc>()
                                        .add(EvidenceSubmitted());
                                  },
                            child: Text(formState.isSubmitting
                                ? "Processing..."
                                : "Next Step"))),
                  ],
                )
              ],
            );
          },
        ));
  }
}
