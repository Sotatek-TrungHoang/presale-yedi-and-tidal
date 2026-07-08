import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yedi_app/modules/adverts/bloc/accept_application_cubit.dart';
import 'package:yedi_app/modules/adverts/bloc/decline_application_cubit.dart';
import 'package:yedi_app/modules/adverts/bloc/heart_applicant_cubit.dart';
import 'package:yedi_app/modules/adverts/bloc/list_advert_applications/list_advert_applications_bloc.dart';
import 'package:yedi_app/modules/adverts/bloc/list_advert_applications/list_advert_applications_event.dart';
import 'package:yedi_app/modules/adverts/bloc/list_adverts/list_adverts_bloc.dart';
import 'package:yedi_app/modules/adverts/bloc/list_adverts/list_adverts_event.dart';
import 'package:yedi_app/modules/adverts/bloc/list_applications/list_applications_bloc.dart';
import 'package:yedi_app/modules/adverts/bloc/list_applications/list_applications_event.dart';
import 'package:yedi_app/modules/adverts/bloc/rate_application_cubit.dart';
import 'package:yedi_app/modules/adverts/models/advert_model.dart';
import 'package:yedi_app/modules/adverts/models/application_model.dart';
import 'package:yedi_app/modules/adverts/services/advertiser_advert_service.dart';
import 'package:yedi_app/modules/hearted_applicants/services/hearted_applicants_service.dart';
import 'package:yedi_app/ui/adverts/application_listing.dart';
import 'package:yedi_app/ui/spacer.dart';
import 'package:yedi_app/util/strings.dart';
import 'package:yedi_app/util/toast.dart';
import 'package:yedi_app/l10n/app_localizations.dart';

class AdvertiserListAdvertApplicantsContent extends StatelessWidget {
  const AdvertiserListAdvertApplicantsContent({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ListAdvertApplicationsBloc>().state;

    if (state.applications.isEmpty) {
      return RefreshIndicator(
          onRefresh: () async {
            context
                .read<ListAdvertApplicationsBloc>()
                .add(ListAdvertApplicationsRefreshed());
          },
          child: _NoApplicationsContent());
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        final refresh =
            context.read<ListAdvertApplicationsBloc>().state.refreshAdvertOnPop;
        context.pop<bool>(refresh);
      },
      child: RefreshIndicator(
        onRefresh: () async {
          context
              .read<ListAdvertApplicationsBloc>()
              .add(ListAdvertApplicationsRefreshed());
        },
        child: ListView.separated(
          physics: AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          itemCount: state.applications.length +
              (state.advert!.status == AdvertStatus.approved ? 1 : 0),
          separatorBuilder: (context, index) => const VSpacer(20),
          itemBuilder: (context, index) {
            if (state.advert!.status == AdvertStatus.approved && index == 0) {
              return Column(
                children: [
                  VSpacer(10),
                  Text(
                    "Applications can only be accepted or declined once the advert's application deadline has passed.",
                    textAlign: TextAlign.center,
                  ),
                  VSpacer(10)
                ],
              );
            }

            final application = state.applications[index -
                (state.advert!.status == AdvertStatus.approved ? 1 : 0)];
            return MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => DeclineApplicationCubit(
                      advertService: context.read<AdvertiserAdvertService>(),
                      applicationId: application.id),
                ),
                BlocProvider(
                  create: (context) => AcceptApplicationCubit(
                      advertService: context.read<AdvertiserAdvertService>(),
                      applicationId: application.id),
                ),
                BlocProvider(
                  create: (context) => RateApplicationCubit(
                      advertService: context.read<AdvertiserAdvertService>(),
                      applicationId: application.id),
                ),
                BlocProvider(
                  create: (context) => HeartApplicantCubit(
                      heartedApplicantsService:
                          context.read<HeartedApplicantsService>(),
                      applicantId: application.applicantId),
                ),
              ],
              child: MultiBlocListener(
                  listeners: [
                    BlocListener<DeclineApplicationCubit,
                        DeclineApplicationCubitState>(
                      listener: (context, state) {
                        if (state.error != null) {
                          showErrorToast(state.error!);
                        } else if (state.updatedApplication != null) {
                          showSuccessToast("Application declined");
                          context.read<ListAdvertApplicationsBloc>().add(
                              ListAdvertApplicationsUpdateApplication(
                                  state.updatedApplication!));
                          context
                              .read<ListPendingApplicationsBloc>()
                              .add(ListApplicationsRefreshed());
                        }
                      },
                    ),
                    BlocListener<AcceptApplicationCubit,
                        AcceptApplicationCubitState>(
                      listener: (context, state) {
                        if (state.error != null) {
                          showErrorToast(state.error!);
                        } else if (state.updatedApplication != null) {
                          showSuccessToast("Application accepted");
                          // Update application list
                          context.read<ListAdvertApplicationsBloc>().add(
                              ListAdvertApplicationsApplicationAccepted(
                                  state.updatedApplication!));

                          // Refresh the advert detail on pop
                          context
                              .read<ListAdvertApplicationsBloc>()
                              .add(ListAdvertApplicationsSetRefreshOnPop(true));

                          // Refresh the list adverts blocs
                          context.read<ListAdvertiserDayToDayAdvertsBloc>().add(
                              ListAdvertsRefreshAdvert(application.advertId));
                          context.read<ListAdvertiserLongTermAdvertsBloc>().add(
                              ListAdvertsRefreshAdvert(application.advertId));

                          // Refresh the list applications bloc
                          context
                              .read<ListPendingApplicationsBloc>()
                              .add(ListApplicationsRefreshed());
                          context
                              .read<ListAcceptedApplicationsBloc>()
                              .add(ListApplicationsRefreshed());
                        }
                      },
                    ),
                    BlocListener<RateApplicationCubit,
                        RateApplicationCubitState>(
                      listener: (context, state) {
                        if (state.error != null) {
                          showErrorToast(state.error!);
                        } else if (state.updatedApplication != null) {
                          showSuccessToast(
                              "${AppLocalizations.of(context)!.applicant.toTitleCase()} rated");

                          context.read<ListAdvertApplicationsBloc>().add(
                              ListAdvertApplicationsUpdateApplication(
                                  state.updatedApplication!));
                          context
                              .read<ListPendingApplicationsBloc>()
                              .add(ListApplicationsRefreshed());
                        }
                      },
                    ),
                    BlocListener<HeartApplicantCubit, HeartApplicantState>(
                      listener: (context, state) {
                        if (state.error != null) {
                          showErrorToast(state.error!);
                        } else if (state.success != null) {
                          showSuccessToast(state.success!);
                          context.read<ListPendingApplicationsBloc>().add(
                              ListApplicationsApplicantHearted(
                                  application.applicantId,
                                  state.newHeartedVal!));
                          context.read<ListAcceptedApplicationsBloc>().add(
                              ListApplicationsApplicantHearted(
                                  application.applicantId,
                                  state.newHeartedVal!));
                          context.read<ListAdvertApplicationsBloc>().add(
                              ListAdvertApplicationsApplicantHearted(
                                  application.applicantId,
                                  state.newHeartedVal!));
                          context
                              .read<ListAdvertApplicationsBloc>()
                              .add(ListAdvertApplicationsSetRefreshOnPop(true));
                        }
                      },
                    )
                  ],
                  child: Builder(builder: (context) {
                    final acceptState =
                        context.watch<AcceptApplicationCubit>().state;
                    final declineState =
                        context.watch<DeclineApplicationCubit>().state;
                    final rateState =
                        context.watch<RateApplicationCubit>().state;

                    return ApplicationListing(
                      key: ValueKey(application.id),
                      application: application,
                      isDeclining: declineState.isDeclining,
                      isAccepting: acceptState.isAccepting,
                      isRating: rateState.isRating,
                      showActions:
                          application.status == ApplicationStatus.pending,
                      showAdvertDetails: false,
                      onDeclinePressed: state.advert!.status ==
                              AdvertStatus.pending_allocation
                          ? () => context
                              .read<DeclineApplicationCubit>()
                              .declineApplication()
                          : null,
                      onAcceptPressed: state.advert!.status ==
                              AdvertStatus.pending_allocation
                          ? () => context
                              .read<AcceptApplicationCubit>()
                              .acceptApplication()
                          : null,
                      onRatingPressed: application.canRate
                          ? (rating) => context
                              .read<RateApplicationCubit>()
                              .rateApplication(rating)
                          : null,
                      onHeartPressed: (heart) => context
                          .read<HeartApplicantCubit>()
                          .heartOrUnheartApplicant(heart),
                    );
                  })),
            );
          },
        ),
      ),
    );
  }
}

class _NoApplicationsContent extends StatelessWidget {
  const _NoApplicationsContent();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(20).copyWith(top: 50),
        child: SizedBox(
          height: constraints.maxHeight - 70,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("No Applications",
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 20)),
              VSpacer(20),
              Text(
                "Unfortunately there are no applications for this job.\nPlease return to the job details page.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, height: 24 / 16),
              ),
              VSpacer(28),
              ElevatedButton(
                  onPressed: () => context.pop(),
                  child: Text("Return to Job Details")),
            ],
          ),
        ),
      );
    });
  }
}
