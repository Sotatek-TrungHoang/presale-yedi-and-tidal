import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yedi_app/modules/adverts/bloc/list_adverts/list_adverts_state.dart';
import 'package:yedi_app/pages/home/applicant/adverts/advert_detail/applicant_advert_detail_page.dart';
import 'package:yedi_app/ui/adverts/advert_listing.dart';
import 'package:yedi_app/ui/spacer.dart';

class ApplicantBookingsContent<T extends StateStreamable<ListAdvertsState>>
    extends StatelessWidget {
  const ApplicantBookingsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<T, ListAdvertsState>(builder: (context, state) {
      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        physics: NeverScrollableScrollPhysics(),
        itemCount: state.adverts.length,
        separatorBuilder: (context, index) => const VSpacer(20),
        itemBuilder: (context, index) {
          final advert = state.adverts[index];
          return AdvertListing(
            advert: advert,
            onTap: () {
              context.pushNamed(ApplicantAdvertDetailPage.name,
                  pathParameters: {"id": advert.id.toString()});
            },
            showStatus: false,
            showApplicationStatus: true,
          );
        },
      );
    });
  }
}
