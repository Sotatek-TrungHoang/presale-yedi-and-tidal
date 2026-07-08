import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yedi_app/modules/adverts/bloc/list_adverts/list_adverts_state.dart';
import 'package:yedi_app/modules/adverts/models/advert_model.dart';
import 'package:yedi_app/pages/home/advertiser/adverts/advert_detail/advertiser_advert_detail_page.dart';
import 'package:yedi_app/ui/adverts/advert_listing.dart';
import 'package:yedi_app/ui/spacer.dart';

class AdvertiserAdvertsContent<T extends StateStreamable<ListAdvertsState>>
    extends StatelessWidget {
  final AdvertType advertType;

  const AdvertiserAdvertsContent({required this.advertType, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<T, ListAdvertsState>(builder: (context, state) {
      return ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: state.adverts.length,
        separatorBuilder: (context, index) => const VSpacer(20),
        itemBuilder: (context, index) {
          final advert = state.adverts[index];
          return AdvertListing(
            advert: advert,
            onTap: () {
              context.pushNamed(AdvertiserAdvertDetailPage.name,
                  pathParameters: {"id": advert.id.toString()});
            },
            showStatus: true,
            showApplicationStatus: false,
          );
        },
      );
    });
  }
}
