import 'package:flutter/material.dart';
import 'package:yedi_app/pages/sign_up/video_verification/video_verification_view.dart';

class VideoVerificationPage extends StatelessWidget {
  const VideoVerificationPage({super.key});

  static const name = 'video-verification';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: VideoVerificationView(),
    );
  }
}
