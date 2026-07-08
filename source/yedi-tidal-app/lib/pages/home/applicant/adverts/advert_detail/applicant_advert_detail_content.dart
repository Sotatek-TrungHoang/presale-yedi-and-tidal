import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/adverts/bloc/advert_detail/advert_detail_bloc.dart';
import 'package:yedi_app/modules/adverts/bloc/advert_detail/advert_detail_state.dart';
import 'package:yedi_app/modules/adverts/bloc/apply_to_advert_cubit.dart';
import 'package:yedi_app/modules/adverts/bloc/cancel_application_cubit.dart';
import 'package:yedi_app/modules/adverts/models/advert_model.dart';
import 'package:yedi_app/modules/adverts/models/application_model.dart';
import 'package:yedi_app/ui/adverts/advert_contact_details.dart';
import 'package:yedi_app/ui/adverts/advert_description.dart';
import 'package:yedi_app/ui/adverts/advert_location.dart';
import 'package:yedi_app/ui/adverts/advert_photograph.dart';
import 'package:yedi_app/ui/adverts/advert_selling_points.dart';
import 'package:yedi_app/ui/spacer.dart';

class ApplicantAdvertDetailContent extends StatelessWidget {
  const ApplicantAdvertDetailContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ApplicantAdvertDetailBloc, AdvertDetailState>(
      buildWhen: (previous, current) => previous.advert != current.advert,
      builder: (context, state) {
        final advert = state.advert!;

        return SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AdvertPhotograph(uploadModel: advert.advertiser?.photograph),
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AdvertSellingPoints(advert: advert),
                    VSpacer(12),
                    Divider(),
                    VSpacer(12),
                    AdvertDescription(advert: advert),
                    if (advert.application?.status ==
                        ApplicationStatus.accepted) ...[
                      VSpacer(12),
                      if (advert.hasContactInfo) ...[
                        Divider(),
                        VSpacer(12),
                        AdvertContactDetails(advert: advert),
                        VSpacer(12),
                      ],
                      Divider(),
                      VSpacer(12),
                      AdvertLocation(advert: advert),
                      VSpacer(12),
                    ],
                    if (advert.applyAction == ApplyAction.apply) ...[
                      VSpacer(32),
                      BlocBuilder<ApplyToAdvertCubit, ApplyToAdvertCubitState>(
                          builder: (context, state) {
                        return ElevatedButton(
                          onPressed: state.isApplying
                              ? null
                              : () {
                                  context.read<ApplyToAdvertCubit>().apply();
                                },
                          child: Text(
                              state.isApplying ? "Applying..." : "Apply Now"),
                        );
                      }),
                    ] else if (advert.applyAction == ApplyAction.cancel) ...[
                      VSpacer(20),
                      Divider(),
                      VSpacer(20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline,
                              color: Color(0xFF10C800)),
                          HSpacer(8),
                          Text("Application Sent"),
                        ],
                      ),
                      VSpacer(20),
                      BlocBuilder<CancelApplicationCubit,
                              CancelApplicationCubitState>(
                          builder: (context, state) {
                        return ElevatedButton(
                          onPressed: state.isCancelling
                              ? null
                              : () {
                                  context
                                      .read<CancelApplicationCubit>()
                                      .cancel();
                                },
                          child: Text(state.isCancelling
                              ? "Cancelling Application..."
                              : "Cancel Application"),
                        );
                      }),
                    ],
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
