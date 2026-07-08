import 'package:equatable/equatable.dart';
import 'package:yedi_app/modules/authentication/models/auth_user_model.dart';
import 'package:yedi_app/modules/common/models/upload_model.dart';
import 'package:yedi_app/util/models.dart';

enum AdvertiserPhotoUploadStatus {
  waitingForSubmit,
  submitting,
  success,
  error
}

class AdvertiserPhotoUploadState implements Equatable {
  final UploadModel? photograph;

  final AdvertiserPhotoUploadStatus status;
  final Map<String, String> errors;
  final String? error;

  final AuthUserModel? updatedUser;

  AdvertiserPhotoUploadState({
    this.photograph,
    this.status = AdvertiserPhotoUploadStatus.waitingForSubmit,
    this.error,
    this.errors = const {},
    this.updatedUser,
  });

  AdvertiserPhotoUploadState copyWith({
    Wrapped<UploadModel?>? photograph,
    AdvertiserPhotoUploadStatus? status,
    Wrapped<String?>? error,
    Map<String, String>? errors,
    Wrapped<AuthUserModel?>? updatedUser,
  }) {
    return AdvertiserPhotoUploadState(
      photograph: photograph is Wrapped ? photograph!.value : this.photograph,
      status: status ?? this.status,
      error: error is Wrapped ? error!.value : this.error,
      errors: errors ?? this.errors,
      updatedUser:
          updatedUser is Wrapped ? updatedUser!.value : this.updatedUser,
    );
  }

  Map<String, dynamic> get payload => {
        'photograph_id': photograph?.id,
      };

  bool get isIdle => status == AdvertiserPhotoUploadStatus.waitingForSubmit;
  bool get isSubmitting => status == AdvertiserPhotoUploadStatus.submitting;
  bool get isSuccess => status == AdvertiserPhotoUploadStatus.success;
  bool get canSubmit => !isSubmitting && photograph != null;

  @override
  List<Object?> get props => [photograph, status, error, errors, updatedUser];

  @override
  bool? get stringify => false;
}
