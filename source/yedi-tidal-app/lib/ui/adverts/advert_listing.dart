import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yedi_app/modules/adverts/models/advert_model.dart';
import 'package:yedi_app/ui/adverts/advert_detail.dart';
import 'package:yedi_app/ui/spacer.dart';
import 'package:yedi_app/ui/theme/app_theme.dart';

class AdvertListing extends StatefulWidget {
  const AdvertListing(
      {required this.advert,
      this.onTap,
      this.showStatus = false,
      this.showApplicationStatus = false,
      super.key});

  final AdvertModel advert;
  final void Function()? onTap;
  final bool showStatus;
  final bool showApplicationStatus;

  @override
  State<AdvertListing> createState() => _AdvertListingState();
}

class _AdvertListingState extends State<AdvertListing> {
  late final Timer _timer;
  String? _previousLabel;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      if (mounted && _previousLabel != widget.advert.applyByLabelValue()) {
        setState(() {
          _previousLabel = widget.advert.applyByLabelValue();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(themeBorderRadius)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
            color: appColours.canvasBackground,
            child: InkWell(
              onTap: widget.onTap,
              splashColor: appColours.accent.withValues(alpha: 0.2),
              borderRadius:
                  BorderRadius.all(Radius.circular(themeBorderRadius)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(widget.advert.title,
                        style: GoogleFonts.sora(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    VSpacer(2),
                    Text(widget.advert.address.townCity,
                        style: GoogleFonts.sora(
                            fontSize: 14, color: Color(0xFF555555))),
                    VSpacer(6),
                    AdvertDetail(
                      icon: Icons.access_time,
                      label: widget.advert.dateLabel,
                    ),
                    if (widget.advert.applicantPayRate != null) ...[
                      VSpacer(6),
                      AdvertDetail(
                        icon: Icons.currency_pound,
                        label:
                            "${widget.advert.applicantPayRate!.display} per ${widget.advert.advertiserPayRateType.unit()}",
                      ),
                    ] else if (widget.advert.advertiserPayRate != null) ...[
                      VSpacer(6),
                      AdvertDetail(
                        icon: Icons.currency_pound,
                        label:
                            "${widget.advert.advertiserPayRate!.display} per ${widget.advert.advertiserPayRateType.unit()}",
                      ),
                    ],
                    if (widget.advert.status == AdvertStatus.approved ||
                        widget.advert.status ==
                            AdvertStatus.pending_approval) ...[
                      VSpacer(8),
                      _TrailingText(
                          label: widget.advert.applyByLabel(),
                          value: widget.advert.applyByLabelValue()),
                    ],
                    if (widget.showStatus) ...[
                      VSpacer(8),
                      _TrailingText(
                          label: "Status", value: widget.advert.statusLabel)
                    ],
                    if (widget.showApplicationStatus &&
                        widget.advert.application != null) ...[
                      VSpacer(8),
                      _TrailingText(
                          label: "Application Status",
                          value: widget.advert.application!.statusLabel)
                    ],
                  ],
                ),
              ),
            )));
  }
}

class _TrailingText extends StatelessWidget {
  const _TrailingText({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("$label: ", style: TextStyle(fontSize: 16)),
        Text(value, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16))
      ],
    );
  }
}
