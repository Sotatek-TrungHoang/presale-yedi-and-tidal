import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yedi_app/modules/sign_up/models/video_verification_model.dart';
import 'package:yedi_app/pages/sign_up/video_verification/video_verification_page.dart';
import 'package:yedi_app/ui/spacer.dart';
import 'package:yedi_app/ui/theme/app_theme.dart';

class VideoVerificationWidget extends StatefulWidget {
  const VideoVerificationWidget({
    this.videoVerification,
    this.onSubmit,
    this.incompleteButtonText = 'Upload Video Verification',
    this.completeButtonText = 'Retake Video',
    this.label = 'Video Verification',
    this.infoText = '(For this step you will be prompted to record yourself)',
    super.key,
  });

  final VideoVerificationModel? videoVerification;
  final Function(VideoVerificationModel?)? onSubmit;
  final String label;
  final String? infoText;
  final String incompleteButtonText;
  final String completeButtonText;

  @override
  State<VideoVerificationWidget> createState() =>
      _VideoVerificationWidgetState();
}

class _VideoVerificationWidgetState extends State<VideoVerificationWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(widget.label),
              if (widget.videoVerification != null) ...[
                HSpacer(8),
                Icon(
                  Icons.check_circle,
                  color: appColours.success,
                  size: 18,
                ),
              ]
            ],
          ),
          VSpacer(8),
          if (widget.videoVerification != null) ...[
            Row(children: [
              Container(
                width: 110,
                height: 110,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: appColours.canvasBackground,
                  borderRadius: BorderRadius.circular(themeBorderRadius),
                ),
                child: Center(
                  child: Icon(
                    Icons.videocam,
                    size: 32,
                  ),
                ),
              ),
              HSpacer(20),
              Expanded(
                child: ElevatedButton(
                    onPressed: widget.onSubmit == null ? null : _onUploadTapped,
                    child: Text(widget.completeButtonText)),
              )
            ])
          ] else ...[
            ElevatedButton(
                onPressed: widget.onSubmit == null ? null : _onUploadTapped,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.videocam),
                    HSpacer(4),
                    Text(widget.incompleteButtonText),
                  ],
                )),
            VSpacer(4),
            Text(
              widget.infoText!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            )
          ],
        ]);
  }

  _onUploadTapped() async {
    final verification = await context
        .pushNamed<VideoVerificationModel?>(VideoVerificationPage.name);

    if (verification == null) {
      return;
    }

    widget.onSubmit?.call(verification);
  }
}
