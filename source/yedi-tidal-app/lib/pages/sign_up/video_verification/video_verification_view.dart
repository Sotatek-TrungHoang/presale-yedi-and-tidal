import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yedi_app/modules/sign_up/bloc/video_verification/video_verification_bloc.dart';
import 'package:yedi_app/modules/sign_up/bloc/video_verification/video_verification_event.dart';
import 'package:yedi_app/modules/sign_up/bloc/video_verification/video_verification_state.dart';
import 'package:yedi_app/modules/sign_up/services/video_verification_service.dart';
import 'package:yedi_app/modules/common/services/upload_service.dart';
import 'package:yedi_app/pages/sign_up/video_verification/video_verification_content_loaded.dart';
import 'package:yedi_app/ui/page_error.dart';

class VideoVerificationView extends StatelessWidget {
  const VideoVerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VideoVerificationBloc(
        uploadService: UploadService(),
        videoVerificationService: VideoVerificationService(),
      )..add(VideoVerificationInitialised()),
      child: BlocConsumer<VideoVerificationBloc, VideoVerificationState>(
        listenWhen: (previous, current) => current.status == VideoVerificationStatus.complete,
        listener: (context, state) {
          context.pop(state.videoVerification!);
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.isError) {
            return PageError(error: state.error ?? "An error occurred");
          } else {
            return const VideoVerificationContentLoaded();
          }
        },
      ),
    );
  }
}
