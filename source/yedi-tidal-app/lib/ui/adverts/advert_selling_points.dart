import 'package:flutter/material.dart';
import 'package:yedi_app/modules/adverts/models/advert_model.dart';
import 'package:yedi_app/ui/adverts/advert_detail.dart';
import 'package:yedi_app/ui/spacer.dart';
import 'package:yedi_app/util/dates.dart';

class AdvertSellingPoints extends StatelessWidget {
  const AdvertSellingPoints({required this.advert, super.key});

  final AdvertModel advert;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          advert.title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        VSpacer(6),
        Text(
          advert.address.townCity,
          style: TextStyle(fontSize: 14, color: Color(0xFF555555)),
        ),
        VSpacer(12),
        if (advert.startsAt.isSameDay(advert.endsAt)) ...[
          AdvertDetail(
              icon: Icons.calendar_month_outlined,
              label: advert.startsAt.formatDate())
        ] else ...[
          AdvertDetail(
              icon: Icons.calendar_month_outlined,
              label:
                  "${advert.startsAt.formatDate()} - ${advert.endsAt.formatDate()}"),
        ],
        VSpacer(6),
        AdvertDetail(
            icon: Icons.access_time,
            label: "${advert.shiftStartTime} - ${advert.shiftEndTime}"),
        if (advert.applicantPayRate != null) ...[
          VSpacer(6),
          AdvertDetail(
            icon: Icons.currency_pound,
            label:
                "${advert.applicantPayRate!.display} per ${advert.advertiserPayRateType.unit()}",
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("${advert.applyByLabel()}: "),
                Text(advert.applyByLabelValue(),
                    style: TextStyle(fontWeight: FontWeight.w600))
              ],
            ),
          ),
        ],
      ],
    );
  }
}
