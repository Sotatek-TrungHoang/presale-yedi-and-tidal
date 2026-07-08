import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/sign_up/bloc/video_verification/video_verification_bloc.dart';
import 'package:yedi_app/modules/sign_up/bloc/video_verification/video_verification_event.dart';
import 'package:yedi_app/modules/sign_up/bloc/video_verification/video_verification_state.dart';
import 'package:video_player/video_player.dart';
import 'dart:math' as math;

import 'package:yedi_app/ui/spacer.dart';
import 'package:yedi_app/ui/theme/app_theme.dart';

class VideoVerificationContentLoaded extends StatelessWidget {
  const VideoVerificationContentLoaded({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<VideoVerificationBloc>().state;

    print("Is playing video: ${state.isPlayingVideo}");

    late final Widget mainBody;
    if (state.isPreview) {
      mainBody = _videoPreview(context, state);
    } else if (state.isPreviewLoading) {
      mainBody = Center(child: CircularProgressIndicator());
    } else {
      mainBody = _cameraPreview(context, state);
    }

    return PopScope(
      canPop: state.status == VideoVerificationStatus.error ||
          state.status == VideoVerificationStatus.loading ||
          state.status == VideoVerificationStatus.readyToRecord,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }

        final state = context.read<VideoVerificationBloc>().state;
        if (state.status == VideoVerificationStatus.preview) {
          context
              .read<VideoVerificationBloc>()
              .add(VideoVerificationDiscardVideoPressed());
        }
      },
      child: Column(children: [
        Expanded(child: mainBody),
        Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                "Please take a clear video of yourself saying aloud the following code:",
                textAlign: TextAlign.center,
              ),
              VSpacer(12),
              Text(
                state.videoVerification!.code.split('').join('-'),
                style: TextStyle(fontSize: 20),
              ),
              if (state.isReadyToRecord) ...[
                VSpacer(24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                          onPressed: () {
                            context
                                .read<VideoVerificationBloc>()
                                .add(VideoVerificationStartRecordingPressed());
                          },
                          child: Text("Take Video")),
                    ),
                  ],
                )
              ] else if (state.isRecording) ...[
                VSpacer(24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                          onPressed: () {
                            context
                                .read<VideoVerificationBloc>()
                                .add(VideoVerificationStopRecordingPressed());
                          },
                          child: Text("Stop Recording")),
                    ),
                  ],
                )
              ] else if (state.isPreview) ...[
                VSpacer(24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                          style: Theme.of(context)
                              .elevatedButtonTheme
                              .style
                              ?.copyWith(
                                  backgroundColor:
                                      WidgetStatePropertyAll(appColours.error)),
                          onPressed: state.uploadProgress != null
                              ? null
                              : () {
                                  context.read<VideoVerificationBloc>().add(
                                      VideoVerificationDiscardVideoPressed());
                                },
                          child: Text("Record Again")),
                    ),
                    HSpacer(20),
                    Expanded(
                      child: ElevatedButton(
                          onPressed: state.uploadProgress != null
                              ? null
                              : () {
                                  context
                                      .read<VideoVerificationBloc>()
                                      .add(VideoVerificationSaveVideoPressed());
                                },
                          child: Text(state.uploadProgress == null
                              ? "Save Video"
                              : "Uploading (${(state.uploadProgress! * 100).toInt()}%)...")),
                    ),
                  ],
                )
              ]
            ],
          ),
        ),
      ]),
    );
  }

  Widget _cameraPreview(BuildContext context, VideoVerificationState state) {
    return LayoutBuilder(
        builder: (context, constraints) => Center(
                child: SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: ClipRect(
                  child: OverflowBox(
                alignment: Alignment.center,
                child: Transform.scale(
                  scale: 1.05,
                  child: FittedBox(
                    fit: BoxFit.fitHeight,
                    child: SizedBox(
                      width: constraints.maxHeight,
                      height: constraints.maxHeight *
                          state.cameraController!.value.aspectRatio,
                      child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(
                              (state.cameraDescription!.sensorOrientation +
                                      270) *
                                  math.pi /
                                  180),
                          child: CameraPreview(state.cameraController!)),
                    ),
                  ),
                ),
              )),
            )));

    // return Transform(
    //     alignment: Alignment.center,
    //     transform: Matrix4.rotationY(math.pi),
    //     child: CameraPreview(
    //       state.cameraController!,
    //     ));
  }

  Widget _videoPreview(BuildContext context, VideoVerificationState state) {
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: FittedBox(
              clipBehavior: Clip.hardEdge,
              fit: BoxFit.cover,
              child: SizedBox(
                  height: state.videoPlayerController!.value.size.height,
                  width: state.videoPlayerController!.value.size.width,
                  child: VideoPlayer(state.videoPlayerController!)),
            ),
          ),
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                final isPlayingVideo =
                    context.read<VideoVerificationBloc>().state.isPlayingVideo;
                if (isPlayingVideo) {
                  context
                      .read<VideoVerificationBloc>()
                      .state
                      .videoPlayerController!
                      .pause();
                } else {
                  context
                      .read<VideoVerificationBloc>()
                      .state
                      .videoPlayerController!
                      .play();
                }
              },
              child: state.isPlayingVideo
                  ? Container()
                  : Center(
                      child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius:
                                  BorderRadius.circular(themeBorderRadius)),
                          child: Icon(
                            state.isPlayingVideo
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                            size: 72,
                          )),
                    ),
            ),
          ),
        ],
      );
    });
  }
}
