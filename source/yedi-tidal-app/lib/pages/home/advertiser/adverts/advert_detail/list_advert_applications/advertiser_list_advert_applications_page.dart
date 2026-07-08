import 'package:flutter/material.dart';
import 'package:yedi_app/pages/home/advertiser/adverts/advert_detail/list_advert_applications/advertiser_list_advert_applications_view.dart';

class AdvertiserListAdvertApplicationsPage extends StatelessWidget {
  const AdvertiserListAdvertApplicationsPage(
      {required this.advertId, super.key});

  final int advertId;

  static const name = 'advertiser-list-advert-applications';

  @override
  Widget build(BuildContext context) {
    return AdvertiserListAdvertApplicationsView(advertId: advertId);
  }
}
