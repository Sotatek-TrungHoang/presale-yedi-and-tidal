import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yedi_app/modules/adverts/models/application_model.dart';
import 'package:yedi_app/pages/home/advertiser/adverts/advert_detail/advertiser_advert_detail_page.dart';
import 'package:yedi_app/ui/spacer.dart';
import 'package:yedi_app/ui/theme/app_theme.dart';
import 'package:yedi_app/util/dates.dart';

class ApplicationListing extends StatelessWidget {
  final ApplicationModel application;
  final bool isAccepting;
  final bool isDeclining;
  final bool isRating;
  final bool showActions;
  final bool showAdvertDetails;
  final void Function()? onDeclinePressed;
  final void Function()? onAcceptPressed;
  final void Function(int rating)? onRatingPressed;
  final void Function(bool heart)? onHeartPressed;

  const ApplicationListing(
      {required this.application,
      this.isAccepting = false,
      this.isDeclining = false,
      this.isRating = false,
      this.showActions = true,
      this.showAdvertDetails = true,
      this.onDeclinePressed,
      this.onAcceptPressed,
      this.onRatingPressed,
      this.onHeartPressed,
      super.key});

  @override
  Widget build(BuildContext context) {
    final canAction = application.status == ApplicationStatus.pending &&
        !isDeclining &&
        !isAccepting;

    final showRatingInputs = application.canRate && onRatingPressed != null;

    return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(themeBorderRadius)),
          color: appColours.canvasBackground,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _applicationInfo(),
            if (showActions) ...[
              VSpacer(12),
              _approveDeclineButtons(canAction, context)
            ],
            if (showRatingInputs || application.rating != null) ...[
              VSpacer(12),
              _ratingInputs(),
            ],
            if (showAdvertDetails && application.advert != null) ...[
              VSpacer(12),
              _viewJobButton(context)
            ],
          ],
        ));
  }

  ElevatedButton _viewJobButton(BuildContext context) {
    return ElevatedButton(
      onPressed: isRating
          ? null
          : () {
              context.pushNamed(AdvertiserAdvertDetailPage.name,
                  pathParameters: {"id": application.advert!.id.toString()});
            },
      child: Text("View Job"),
    );
  }

  Row _applicationInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: appColours.accent,
          foregroundColor: Colors.white,
          foregroundImage: application.applicant?.photograph != null
              ? NetworkImage(application
                      .applicant!.photograph!.imageConversions?.small?.url ??
                  application.applicant!.photograph!.url)
              : null,
          child: Text(
            application.applicant?.user!.initials ?? "",
            style: TextStyle(fontSize: 16),
          ),
        ),
        HSpacer(20),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  application.applicant?.user!.name ?? "",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                if (application.applicant?.rating != null) ...[
                  HSpacer(5),
                  Icon(
                    Icons.star,
                    color: appColours.accent,
                    size: 16,
                  ),
                  HSpacer(2),
                  Text(
                    application.applicant!.rating?.toStringAsFixed(1) ?? "-",
                    style: TextStyle(fontSize: 12),
                  )
                ]
              ],
            ),
            if (showAdvertDetails && application.advert != null) ...[
              Text(application.advert!.title),
            ],
            VSpacer(1),
            Text(
              "Applied on ${application.createdAt.formatDate()}",
              style: TextStyle(fontSize: 14, color: Color(0xFF555555)),
            ),
            if (application.status == ApplicationStatus.declined &&
                application.actionedAt != null) ...[
              VSpacer(1),
              Text(
                "Declined at ${application.actionedAt!.formatDateTime()}",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: appColours.error),
              ),
            ] else if (application.status == ApplicationStatus.accepted &&
                application.actionedAt != null) ...[
              VSpacer(1),
              Text(
                "Accepted at ${application.actionedAt!.formatDateTime()}",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: appColours.success),
              ),
            ]
          ],
        )),
        if (onHeartPressed != null &&
            application.applicant?.hearted != null) ...[
          HSpacer(20),
          IconButton(
              onPressed: () {
                onHeartPressed!(!application.applicant!.hearted!);
              },
              color:
                  application.applicant!.hearted! ? Colors.red : Colors.black,
              icon: Icon(
                application.applicant!.hearted!
                    ? Icons.favorite
                    : Icons.favorite_border,
              ))
        ]
      ],
    );
  }

  Row _approveDeclineButtons(bool canAction, BuildContext context) {
    return Row(children: [
      Expanded(
          child: ElevatedButton(
        onPressed: canAction && onDeclinePressed != null
            ? () => onDeclinePressed!()
            : null,
        style: ElevatedButton.styleFrom(
            elevation: 0, backgroundColor: Color(0xFF555555)),
        child: Text(isDeclining ? "Declining" : "Decline"),
      )),
      HSpacer(10),
      Expanded(
          child: ElevatedButton(
              onPressed: canAction && onAcceptPressed != null
                  ? () {
                      showDialog(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          return AlertDialog(
                            title: Text("Confirm Approval"),
                            content: Text(
                                "Are you sure you want to approve this application?\n\nDoing so will decline all other pending applications for this job."),
                            actions: [
                              OutlinedButton(
                                onPressed: () {
                                  Navigator.of(dialogContext)
                                      .pop(); // Close the dialog
                                },
                                child: Text("Cancel"),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(dialogContext)
                                      .pop(); // Close the dialog
                                  onAcceptPressed!();
                                },
                                child: Text("Approve"),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  : null,
              child: Text("Approve"))),
    ]);
  }

  Row _ratingInputs() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(5, (index) {
          final rating = index + 1;
          return IconButton(
              iconSize: 32,
              icon: Icon(
                Icons.star,
                color:
                    application.rating != null && application.rating! >= rating
                        ? appColours.accent
                        : Color(0xFFCCCCCC),
              ),
              onPressed: isRating || application.rating != null
                  ? null
                  : () => onRatingPressed!(rating));
        }));
  }
}
