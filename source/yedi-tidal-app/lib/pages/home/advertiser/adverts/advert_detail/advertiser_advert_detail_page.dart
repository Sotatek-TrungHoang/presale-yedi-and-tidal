import 'package:flutter/material.dart';
import 'package:yedi_app/pages/home/advertiser/adverts/advert_detail/advertiser_advert_detail_view.dart';

class AdvertiserAdvertDetailPage extends StatelessWidget {
  const AdvertiserAdvertDetailPage({required this.id, super.key});

  final int id;

  static const name = 'advertiser-advert-detail';

  @override
  Widget build(BuildContext context) {
    return AdvertiserAdvertDetailView(id: id);
  }
}
