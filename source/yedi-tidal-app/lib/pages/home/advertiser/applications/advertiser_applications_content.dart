import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/adverts/bloc/accept_application_cubit.dart';
import 'package:yedi_app/modules/adverts/bloc/decline_application_cubit.dart';
import 'package:yedi_app/modules/adverts/bloc/heart_applicant_cubit.dart';
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

class AdvertiserApplicationsContent<T extends ListApplicationsBloc>
    extends StatelessWidget {
  const AdvertiserApplicationsContent({super.key});

  @override
  Widget build(BuildContext context) {
    final applications = context.select((T bloc) => bloc.state.applications);

    return RefreshIndicator(
      onRefresh: () async => context.read<T>().add(ListApplicationsRefreshed()),
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        physics: AlwaysScrollableScrollPhysics(),
        itemCount: applications.length,
        separatorBuilder: (context, index) => const VSpacer(20),
        itemBuilder: (context, index) {
          final application = applications.elementAt(index);
          return MultiBlocProvider(
            key: ValueKey(application.id),
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
                        context.read<T>().add(ListApplicationsUpdateApplication(
                            state.updatedApplication!));
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
                        context.read<ListPendingApplicationsBloc>().add(
                            ListApplicationsApplicationAccepted(
                                state.updatedApplication!));
                        context
                            .read<ListAcceptedApplicationsBloc>()
                            .add(ListApplicationsRefreshed());

                        context.read<ListAdvertiserDayToDayAdvertsBloc>().add(
                            ListAdvertsRefreshAdvert(application.advertId));
                        context.read<ListAdvertiserLongTermAdvertsBloc>().add(
                            ListAdvertsRefreshAdvert(application.advertId));
                      }
                    },
                  ),
                  BlocListener<RateApplicationCubit, RateApplicationCubitState>(
                    listener: (context, state) {
                      if (state.error != null) {
                        showErrorToast(state.error!);
                      } else if (state.updatedApplication != null) {
                        showSuccessToast(
                            "${AppLocalizations.of(context)!.applicant.toTitleCase()} rated");
                        context.read<T>().add(ListApplicationsUpdateApplication(
                            state.updatedApplication!));
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
                                application.applicantId, state.newHeartedVal!));
                        context.read<ListAcceptedApplicationsBloc>().add(
                            ListApplicationsApplicantHearted(
                                application.applicantId, state.newHeartedVal!));
                      }
                    },
                  ),
                ],
                child: Builder(builder: (context) {
                  final acceptState =
                      context.watch<AcceptApplicationCubit>().state;
                  final declineState =
                      context.watch<DeclineApplicationCubit>().state;
                  final rateState = context.watch<RateApplicationCubit>().state;

                  return ApplicationListing(
                    application: application,
                    isDeclining: declineState.isDeclining,
                    isAccepting: acceptState.isAccepting,
                    isRating: rateState.isRating,
                    showActions:
                        application.status == ApplicationStatus.pending,
                    showAdvertDetails: true,
                    onDeclinePressed: application.advert?.status ==
                            AdvertStatus.pending_allocation
                        ? () => context
                            .read<DeclineApplicationCubit>()
                            .declineApplication()
                        : null,
                    onAcceptPressed: application.advert?.status ==
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
                    onHeartPressed: (hearting) => context
                        .read<HeartApplicantCubit>()
                        .heartOrUnheartApplicant(hearting),
                  );
                })),
          );
        },
      ),
    );
  }
}
