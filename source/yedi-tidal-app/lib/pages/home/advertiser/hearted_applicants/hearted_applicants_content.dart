import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/adverts/bloc/heart_applicant_cubit.dart';
import 'package:yedi_app/modules/adverts/bloc/list_applications/list_applications_bloc.dart';
import 'package:yedi_app/modules/adverts/bloc/list_applications/list_applications_event.dart';
import 'package:yedi_app/modules/hearted_applicants/bloc/hearted_applicants_bloc.dart';
import 'package:yedi_app/modules/hearted_applicants/bloc/hearted_applicants_event.dart';
import 'package:yedi_app/modules/hearted_applicants/models/hearted_applicant_model.dart';
import 'package:yedi_app/modules/hearted_applicants/services/hearted_applicants_service.dart';
import 'package:yedi_app/ui/spacer.dart';
import 'package:yedi_app/ui/theme/app_theme.dart';
import 'package:yedi_app/util/dates.dart';
import 'package:yedi_app/util/toast.dart';

class HeartedApplicantsContent extends StatelessWidget {
  const HeartedApplicantsContent({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HeartedApplicantsBloc>().state;
    return RefreshIndicator(
      onRefresh: () async => context.read<HeartedApplicantsBloc>().add(
            HeartedApplicantsRefreshed(),
          ),
      child: ListView.separated(
        padding: EdgeInsets.all(20),
        physics: AlwaysScrollableScrollPhysics(),
        itemCount: state.heartedApplicants.length,
        separatorBuilder: (context, index) => VSpacer(20),
        itemBuilder: (context, index) {
          final heartedApplicant = state.heartedApplicants[index];
          return BlocProvider(
            key: ValueKey(heartedApplicant.id),
            create: (context) => HeartApplicantCubit(
              applicantId: heartedApplicant.applicant.id,
              heartedApplicantsService:
                  context.read<HeartedApplicantsService>(),
            ),
            child: BlocListener<HeartApplicantCubit, HeartApplicantState>(
              listener: (context, state) {
                if (state.error != null) {
                  showErrorToast(state.error!);
                } else if (state.success != null) {
                  showSuccessToast(state.success!);
                  context.read<ListPendingApplicationsBloc>().add(
                      ListApplicationsApplicantHearted(
                          heartedApplicant.applicant.id, state.newHeartedVal!));
                  context.read<ListAcceptedApplicationsBloc>().add(
                      ListApplicationsApplicantHearted(
                          heartedApplicant.applicant.id, state.newHeartedVal!));
                  context.read<HeartedApplicantsBloc>().add(
                      HeartedApplicantsApplicantHearted(
                          heartedApplicant.id, state.newHeartedVal!));
                }
              },
              child: _HeartedApplicantListing(
                heartedApplicant: heartedApplicant,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HeartedApplicantListing extends StatelessWidget {
  final HeartedApplicantModel heartedApplicant;

  const _HeartedApplicantListing({required this.heartedApplicant});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HeartApplicantCubit>().state;

    return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(themeBorderRadius)),
          color: appColours.canvasBackground,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: appColours.accent,
              foregroundColor: Colors.white,
              foregroundImage: heartedApplicant.applicant.photograph != null
                  ? NetworkImage(heartedApplicant
                          .applicant.photograph!.imageConversions?.small?.url ??
                      heartedApplicant.applicant.photograph!.url)
                  : null,
              child: Text(
                heartedApplicant.applicant.user?.initials ?? "",
                style: TextStyle(fontSize: 16),
              ),
            ),
            HSpacer(20),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      heartedApplicant.applicant.user?.name ?? "-",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    if (heartedApplicant.applicant.rating != null) ...[
                      HSpacer(5),
                      Icon(
                        Icons.star,
                        color: appColours.accent,
                        size: 16,
                      ),
                      HSpacer(2),
                      Text(
                        heartedApplicant.applicant.rating?.toStringAsFixed(1) ??
                            "-",
                        style: TextStyle(fontSize: 12),
                      ),
                    ]
                  ],
                ),
                VSpacer(1),
                Text(heartedApplicant.updatedAt.formatDateTime()),
              ],
            )),
            if (heartedApplicant.applicant.hearted != null) ...[
              HSpacer(20),
              IconButton(
                  onPressed: state.isHearting
                      ? null
                      : () {
                          context
                              .read<HeartApplicantCubit>()
                              .heartOrUnheartApplicant(
                                  !heartedApplicant.applicant.hearted!);
                        },
                  color: heartedApplicant.applicant.hearted!
                      ? Colors.red
                      : Colors.black,
                  icon: Icon(
                    heartedApplicant.applicant.hearted!
                        ? Icons.favorite
                        : Icons.favorite_border,
                  ))
            ],
          ],
        ));
  }
}
