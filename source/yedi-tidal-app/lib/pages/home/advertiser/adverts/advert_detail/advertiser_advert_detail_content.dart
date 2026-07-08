import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:yedi_app/modules/adverts/bloc/advert_detail/advert_detail_bloc.dart';
import 'package:yedi_app/modules/adverts/bloc/advert_detail/advert_detail_event.dart';
import 'package:yedi_app/modules/adverts/bloc/advert_detail/advert_detail_state.dart';
import 'package:yedi_app/modules/adverts/bloc/heart_applicant_cubit.dart';
import 'package:yedi_app/modules/adverts/bloc/list_applications/list_applications_bloc.dart';
import 'package:yedi_app/modules/adverts/bloc/list_applications/list_applications_event.dart';
import 'package:yedi_app/modules/adverts/bloc/rate_application_cubit.dart';
import 'package:yedi_app/modules/adverts/models/advert_model.dart';
import 'package:yedi_app/modules/adverts/services/advertiser_advert_service.dart';
import 'package:yedi_app/modules/hearted_applicants/services/hearted_applicants_service.dart';
import 'package:yedi_app/pages/home/advertiser/adverts/advert_detail/list_advert_applications/advertiser_list_advert_applications_page.dart';
import 'package:yedi_app/ui/adverts/advert_contact_details.dart';
import 'package:yedi_app/ui/adverts/advert_description.dart';
import 'package:yedi_app/ui/adverts/advert_documents_List.dart';
import 'package:yedi_app/ui/adverts/advert_location.dart';
import 'package:yedi_app/ui/adverts/advert_photograph.dart';
import 'package:yedi_app/ui/adverts/advert_selling_points.dart';
import 'package:yedi_app/ui/adverts/application_listing.dart';
import 'package:yedi_app/ui/spacer.dart';
import 'package:yedi_app/util/strings.dart';
import 'package:yedi_app/util/toast.dart';

class AdvertiserAdvertDetailContent extends StatelessWidget {
  const AdvertiserAdvertDetailContent({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context
            .read<AdvertiserAdvertDetailBloc>()
            .add(AdvertDetailRefreshed(null));
      },
      child: BlocBuilder<AdvertiserAdvertDetailBloc, AdvertDetailState>(
        buildWhen: (previous, current) => previous.advert != current.advert,
        builder: (context, state) {
          final advert = state.advert!;

          return SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (advert.status != AdvertStatus.pending_approval &&
                    advert.status != AdvertStatus.rejected)
                  Padding(
                      padding: EdgeInsets.all(20),
                      child: ElevatedButton(
                          onPressed: () {
                            context.pushNamed<bool>(
                                AdvertiserListAdvertApplicationsPage.name,
                                pathParameters: {
                                  'id': advert.id.toString(),
                                }).then((refreshAdvert) {
                              if (refreshAdvert == true && context.mounted) {
                                context
                                    .read<AdvertiserAdvertDetailBloc>()
                                    .add(AdvertDetailRefreshed(null));
                              }
                            });
                          },
                          child: Text(advert.applicationsCount != null
                              ? "View Applications (${advert.applicationsCount})"
                              : "View Applications"))),
                AdvertPhotograph(uploadModel: advert.advertiser?.photograph),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AdvertSellingPoints(advert: advert),
                      VSpacer(12),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("${advert.applyByLabel()}: "),
                          Text(advert.applyByLabelValue(),
                              style: TextStyle(fontWeight: FontWeight.w600))
                        ],
                      ),
                      VSpacer(12),
                      Row(
                        children: [
                          Text("Status: ", style: TextStyle(fontSize: 16)),
                          Text(advert.statusLabel,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 16))
                        ],
                      ),
                      VSpacer(12),
                      if (advert.acceptedApplication != null) ...[
                        Text(
                            "${AppLocalizations.of(context)!.applicant.toTitleCase()}: ",
                            style: TextStyle(fontSize: 16)),
                        VSpacer(6),
                        MultiBlocProvider(
                            providers: [
                              BlocProvider(
                                  create: (context) => RateApplicationCubit(
                                      advertService: context
                                          .read<AdvertiserAdvertService>(),
                                      applicationId:
                                          advert.acceptedApplication!.id)),
                              BlocProvider(
                                create: (context) => HeartApplicantCubit(
                                    heartedApplicantsService: context
                                        .read<HeartedApplicantsService>(),
                                    applicantId: advert
                                        .acceptedApplication!.applicantId),
                              ),
                            ],
                            child: MultiBlocListener(
                              listeners: [
                                BlocListener<RateApplicationCubit,
                                    RateApplicationCubitState>(
                                  listener: (context, state) {
                                    if (state.error != null) {
                                      showErrorToast(state.error!);
                                    } else if (state.updatedApplication !=
                                        null) {
                                      showSuccessToast(
                                          "${AppLocalizations.of(context)!.applicant.toTitleCase()} rated");
                                      context
                                          .read<ListPendingApplicationsBloc>()
                                          .add(
                                              ListApplicationsUpdateApplication(
                                                  state.updatedApplication!));
                                      context
                                          .read<ListAcceptedApplicationsBloc>()
                                          .add(
                                              ListApplicationsUpdateApplication(
                                                  state.updatedApplication!));
                                      context
                                          .read<AdvertiserAdvertDetailBloc>()
                                          .add(
                                              AdvertDetailUpdateAcceptedApplication(
                                                  state.updatedApplication!));
                                    }
                                  },
                                ),
                                BlocListener<HeartApplicantCubit,
                                    HeartApplicantState>(
                                  listener: (context, state) {
                                    if (state.error != null) {
                                      showErrorToast(state.error!);
                                    } else if (state.success != null) {
                                      showSuccessToast(state.success!);
                                      context
                                          .read<ListPendingApplicationsBloc>()
                                          .add(ListApplicationsApplicantHearted(
                                              advert.acceptedApplication!
                                                  .applicantId,
                                              state.newHeartedVal!));
                                      context
                                          .read<ListAcceptedApplicationsBloc>()
                                          .add(ListApplicationsApplicantHearted(
                                              advert.acceptedApplication!
                                                  .applicantId,
                                              state.newHeartedVal!));
                                      context
                                          .read<AdvertiserAdvertDetailBloc>()
                                          .add(AdvertDetailApplicantHearted(
                                              state.newHeartedVal!));
                                    }
                                  },
                                )
                              ],
                              child: Builder(
                                builder: (context) {
                                  final rateState = context
                                      .watch<RateApplicationCubit>()
                                      .state;
                                  return ApplicationListing(
                                    application: advert.acceptedApplication!,
                                    showActions: false,
                                    showAdvertDetails: false,
                                    isRating: rateState.isRating,
                                    onRatingPressed: (rating) => context
                                        .read<RateApplicationCubit>()
                                        .rateApplication(rating),
                                    onHeartPressed: (hearting) => context
                                        .read<HeartApplicantCubit>()
                                        .heartOrUnheartApplicant(hearting),
                                  );
                                },
                              ),
                            )),
                        VSpacer(12),
                      ],
                      // description
                      Divider(),
                      VSpacer(12),
                      AdvertDescription(advert: advert),
                      VSpacer(12),
                      // contact details
                      if (advert.hasContactInfo) ...[
                        Divider(),
                        VSpacer(12),
                        AdvertContactDetails(advert: advert),
                        VSpacer(12),
                      ],
                      // documents
                      if (advert.documents.isNotEmpty) ...[
                        Divider(),
                        VSpacer(12),
                        AdvertDocumentsList(documents: advert.documents),
                        VSpacer(12),
                      ],
                      // location
                      Divider(),
                      VSpacer(12),
                      AdvertLocation(advert: advert),
                      VSpacer(12),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
