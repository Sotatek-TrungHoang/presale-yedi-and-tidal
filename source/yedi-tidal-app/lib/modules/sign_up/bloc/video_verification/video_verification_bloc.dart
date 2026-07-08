import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:yedi_app/modules/api/api_exceptions.dart';
import 'package:yedi_app/modules/sign_up/bloc/video_verification/video_verification_event.dart';
import 'package:yedi_app/modules/sign_up/bloc/video_verification/video_verification_state.dart';
import 'package:yedi_app/modules/sign_up/services/video_verification_service.dart';
import 'package:yedi_app/modules/common/services/upload_service.dart';
import 'package:yedi_app/util/models.dart';

class VideoVerificationBloc extends Bloc<VideoVerificationEvent, VideoVerificationState> {
  final UploadService uploadService;
  final VideoVerificationService videoVerificationService;

  VideoVerificationBloc({required this.uploadService, required this.videoVerificationService}) : super(VideoVerificationState.initial()) {
    on<VideoVerificationInitialised>(_onVideoVerificationInitialised);
    on<VideoVerificationStartRecordingPressed>(_onVideoVerificationStartRecordingPressed);
    on<VideoVerificationStopRecordingPressed>(_onVideoVerificationStopRecordingPressed);
    on<VideoVerificationDiscardVideoPressed>(_onVideoVerificationDiscardVideoPressed);
    on<VideoVerificationSaveVideoPressed>(_onVideoVerificationSaveVideoPressed);
    on<VideoVerificationVideoUpdated>(_onVideoVerificationVideoUpdated);
  }

  _onVideoVerificationInitialised(
    VideoVerificationInitialised event,
    Emitter<VideoVerificationState> emit,
  ) async {
    try {
      final videoVerification = await videoVerificationService.getNewVideoVerification();

      final cameras = await availableCameras();
      final camera = cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.front);

      final cameraController = CameraController(camera, ResolutionPreset.max);
      cameraController.lockCaptureOrientation(DeviceOrientation.portraitUp);
      await cameraController.initialize();

      emit(state.copyWith(
          status: VideoVerificationStatus.readyToRecord,
          videoVerification: Wrapped.value(videoVerification),
          cameraDescription: Wrapped.value(camera),
          cameraController: Wrapped.value(cameraController)));
    } on APIException catch (e) {
      emit(state.copyWith(status: VideoVerificationStatus.error, error: Wrapped.value(e.message ?? e.toString())));
    } on CameraException catch (e) {
      emit(state.copyWith(status: VideoVerificationStatus.error, error: Wrapped.value(e.description ?? e.code)));
    } catch (e) {
      emit(state.copyWith(status: VideoVerificationStatus.error, error: Wrapped.value(e.toString())));
    }
  }

  _onVideoVerificationStartRecordingPressed(
    VideoVerificationStartRecordingPressed event,
    Emitter<VideoVerificationState> emit,
  ) async {
    try {
      await state.cameraController?.startVideoRecording();
      emit(state.copyWith(
        status: VideoVerificationStatus.recording,
        result: Wrapped.value(null),
        uploadProgress: Wrapped.value(null),
        error: Wrapped.value(null),
      ));
    } on CameraException catch (e) {
      emit(state.copyWith(status: VideoVerificationStatus.error, error: Wrapped.value(e.description ?? e.code)));
    }
  }

  _onVideoVerificationStopRecordingPressed(
    VideoVerificationStopRecordingPressed event,
    Emitter<VideoVerificationState> emit,
  ) async {
    final result = await state.cameraController?.stopVideoRecording();
    print("stoppong recording");

    if (result != null) {
      emit(state.copyWith(status: VideoVerificationStatus.loadingPreview));

      final existingVideoController = state.videoPlayerController;
      if (existingVideoController != null) {
        await existingVideoController.dispose();
      }

      final videoFile = File(result.path);
      final videoPlayerController = VideoPlayerController.file(videoFile);
      await videoPlayerController.initialize();

      videoPlayerController.addListener(() {
        if (videoPlayerController.value.position == videoPlayerController.value.duration) {
          state.videoPlayerController?.seekTo(Duration.zero);
        }
        add(VideoVerificationVideoUpdated());
      });

      emit(state.copyWith(
          status: VideoVerificationStatus.preview, videoPlayerController: Wrapped.value(videoPlayerController), result: Wrapped.value(result)));
    } else {
      emit(state.copyWith(status: VideoVerificationStatus.error, error: Wrapped.value('Failed to record video')));
    }
  }

  _onVideoVerificationDiscardVideoPressed(
    VideoVerificationDiscardVideoPressed event,
    Emitter<VideoVerificationState> emit,
  ) async {
    final existingVideoController = state.videoPlayerController;
    emit(state.copyWith(status: VideoVerificationStatus.readyToRecord, videoPlayerController: Wrapped.value(null), result: Wrapped.value(null)));

    if (existingVideoController != null) {
      await existingVideoController.dispose();
    }
  }

  _onVideoVerificationSaveVideoPressed(
    VideoVerificationSaveVideoPressed event,
    Emitter<VideoVerificationState> emit,
  ) async {
    final result = state.result;
    if (result == null) {
      return;
    }

    try {
      final upload = await uploadService.uploadFile(result.path, onSendProgress: (count, total) {
        final progress = count / total;
        emit(state.copyWith(uploadProgress: Wrapped.value(progress)));
      });

      final videoVerification = await videoVerificationService.submitVideoVerification(state.videoVerification!.id, upload.id);

      emit(state.copyWith(status: VideoVerificationStatus.complete, videoVerification: Wrapped.value(videoVerification)));
    } on APIException catch (e) {
      emit(state.copyWith(status: VideoVerificationStatus.error, error: Wrapped.value(e.message ?? e.toString())));
    } catch (e) {
      emit(state.copyWith(status: VideoVerificationStatus.error, error: Wrapped.value(e.toString())));
    }
  }

  _onVideoVerificationVideoUpdated(
    VideoVerificationVideoUpdated event,
    Emitter<VideoVerificationState> emit,
  ) {
    emit(state.copyWith());
  }

  @override
  Future<void> close() {
    state.cameraController?.dispose();
    state.videoPlayerController?.dispose();
    return super.close();
  }
}
