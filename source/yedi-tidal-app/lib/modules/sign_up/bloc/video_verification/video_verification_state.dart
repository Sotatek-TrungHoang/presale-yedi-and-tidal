import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:video_player/video_player.dart';
import 'package:yedi_app/modules/sign_up/models/video_verification_model.dart';
import 'package:yedi_app/util/models.dart';

enum VideoVerificationStatus {
  loading,
  readyToRecord,
  recording,
  loadingPreview,
  preview,
  error,
  complete,
}

class VideoVerificationState implements Equatable {
  final VideoVerificationStatus status;
  final VideoVerificationModel? videoVerification;
  final CameraController? cameraController;
  final CameraDescription? cameraDescription;
  final VideoPlayerController? videoPlayerController;
  final XFile? result;
  final String? error;
  final double? uploadProgress;

  VideoVerificationState(
      {required this.status,
      this.videoVerification,
      this.cameraController,
      this.cameraDescription,
      this.videoPlayerController,
      this.result,
      this.error,
      this.uploadProgress});

  factory VideoVerificationState.initial() {
    return VideoVerificationState(
      status: VideoVerificationStatus.loading,
    );
  }

  VideoVerificationState copyWith({
    VideoVerificationStatus? status,
    Wrapped<VideoVerificationModel?>? videoVerification,
    Wrapped<CameraController?>? cameraController,
    Wrapped<CameraDescription?>? cameraDescription,
    Wrapped<VideoPlayerController?>? videoPlayerController,
    Wrapped<XFile?>? result,
    Wrapped<String?>? error,
    Wrapped<double?>? uploadProgress,
  }) {
    return VideoVerificationState(
        status: status ?? this.status,
        videoVerification: videoVerification is Wrapped
            ? videoVerification!.value
            : this.videoVerification,
        cameraController: cameraController is Wrapped
            ? cameraController!.value
            : this.cameraController,
        cameraDescription: cameraDescription is Wrapped
            ? cameraDescription!.value
            : this.cameraDescription,
        videoPlayerController: videoPlayerController is Wrapped
            ? videoPlayerController!.value
            : this.videoPlayerController,
        error: error is Wrapped ? error!.value : this.error,
        uploadProgress: uploadProgress is Wrapped
            ? uploadProgress!.value
            : this.uploadProgress,
        result: result is Wrapped ? result!.value : this.result);
  }

  bool get controllerReady =>
      cameraController != null && cameraController!.value.isInitialized;
  bool get isLoading => status == VideoVerificationStatus.loading;
  bool get isReadyToRecord => status == VideoVerificationStatus.readyToRecord;
  bool get isRecording => status == VideoVerificationStatus.recording;
  bool get isPreview => status == VideoVerificationStatus.preview;
  bool get isPreviewLoading => status == VideoVerificationStatus.loadingPreview;
  bool get isError => status == VideoVerificationStatus.error;

  bool get isPlayingVideo => videoPlayerController?.value.isPlaying ?? false;

  @override
  List<Object?> get props => [
        status,
        videoVerification,
        cameraController,
        cameraDescription,
        videoPlayerController,
        videoPlayerController?.value.isPlaying,
        videoPlayerController?.value.position,
        result,
        error,
        uploadProgress
      ];

  @override
  bool? get stringify => false;
}
