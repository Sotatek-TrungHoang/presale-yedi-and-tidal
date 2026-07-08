import 'package:flutter/material.dart';
import 'package:yedi_app/modules/adverts/models/advert_model.dart';
import 'package:yedi_app/ui/adverts/advert_detail.dart';
import 'package:yedi_app/ui/spacer.dart';

class AdvertContactDetails extends StatelessWidget {
  const AdvertContactDetails({required this.advert, super.key});

  final AdvertModel advert;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Key Contact Details",
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        VSpacer(8),
        if (advert.contactName != null) ...[
          AdvertDetail(
            icon: Icons.person_outline,
            label: advert.contactName! +
                (advert.contactPosition != null
                    ? " (${advert.contactPosition})"
                    : ""),
          ),
          VSpacer(6),
        ],
        if (advert.contactEmail != null) ...[
          AdvertDetail(icon: Icons.email_outlined, label: advert.contactEmail!),
          VSpacer(6),
        ],
        if (advert.contactTelephone != null) ...[
          AdvertDetail(
              icon: Icons.phone_outlined, label: advert.contactTelephone!),
        ]
      ],
    );
  }
}
