import 'package:flutter/material.dart';
import 'package:yedi_app/modules/adverts/models/advert_model.dart';
import 'package:yedi_app/ui/spacer.dart';

class AdvertDescription extends StatelessWidget {
  const AdvertDescription({required this.advert, super.key});

  final AdvertModel advert;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Job Description",
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        VSpacer(8),
        Text(
          advert.description,
        ),
      ],
    );
  }
}
