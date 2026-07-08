import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yedi_app/modules/authentication/bloc/authentication_bloc.dart';
import 'package:yedi_app/modules/authentication/bloc/authentication_event.dart';
import 'package:yedi_app/modules/profile/bloc/profile_blocks_cubit.dart';
import 'package:yedi_app/modules/profile/bloc/update_evidence_cubit.dart';
import 'package:yedi_app/modules/profile/service/profile_service.dart';
import 'package:yedi_app/modules/sign_up/services/evidence_service.dart';
import 'package:yedi_app/pages/home/applicant/profile/evidence/applicant_update_evidence_content.dart';
import 'package:yedi_app/ui/page_error.dart';
import 'package:yedi_app/util/toast.dart';

class ApplicantUpdateEvidenceView extends StatelessWidget {
  const ApplicantUpdateEvidenceView(
      {super.key, required this.requiredEvidenceId});

  final int requiredEvidenceId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Update Evidence"),
        ),
        body: BlocProvider(
          create: (context) {
            final user = context.read<AuthenticationBloc>().state.user;
            return UpdateEvidenceCubit(
                requiredEvidenceId: requiredEvidenceId,
                evidenceService: context.read<EvidenceService>(),
                profileService: context.read<ApplicantProfileService>(),
                user: user!)
              ..init();
          },
          child: BlocConsumer<UpdateEvidenceCubit, UpdateEvidenceState>(
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: (context, state) {
              if (state.isSuccess) {
                showSuccessToast("Evidence Updated");
                context.read<AuthenticationBloc>().add(RefreshUser());
                context.read<ProfileBlocksCubit>().loadBlocks();
                context.pop();
              }
            },
            buildWhen: (previous, current) => previous.status != current.status,
            builder: (context, state) {
              switch (state.status) {
                case UpdateEvidenceStatus.loading:
                  return const Center(child: CircularProgressIndicator());
                case UpdateEvidenceStatus.error:
                  return PageError(error: state.error ?? "An error occurred");
                default:
                  return ApplicantUpdateEvidenceContent();
              }
            },
          ),
        ));
  }
}
