import 'package:equatable/equatable.dart';
import 'package:yedi_app/modules/authentication/models/auth_user_model.dart';
import 'package:yedi_app/modules/sign_up/models/video_verification_model.dart';
import 'package:yedi_app/modules/common/models/upload_model.dart';
import 'package:yedi_app/util/models.dart';

enum ComplianceFormStatus { waitingForSubmit, submitting, success }

class ComplianceFormState implements Equatable {
  final UploadModel? photograph;
  final UploadModel? evidenceOfId;
  final VideoVerificationModel? videoVerification;
  final ComplianceFormStatus status;
  final AuthUserModel? updatedUser;
  final Map<String, String> errors;
  final String? error;

  ComplianceFormState({
    this.photograph,
    this.evidenceOfId,
    this.videoVerification,
    this.status = ComplianceFormStatus.waitingForSubmit,
    this.updatedUser,
    this.error,
    this.errors = const {},
  });

  ComplianceFormState copyWith({
    Wrapped<UploadModel?>? photograph,
    Wrapped<UploadModel?>? evidenceOfId,
    Wrapped<VideoVerificationModel?>? videoVerification,
    ComplianceFormStatus? status,
    Wrapped<AuthUserModel?>? updatedUser,
    Wrapped<String?>? error,
    Map<String, String>? errors,
  }) {
    return ComplianceFormState(
      photograph: photograph is Wrapped ? photograph!.value : this.photograph,
      evidenceOfId:
          evidenceOfId is Wrapped ? evidenceOfId!.value : this.evidenceOfId,
      videoVerification: videoVerification is Wrapped
          ? videoVerification!.value
          : this.videoVerification,
      updatedUser:
          updatedUser is Wrapped ? updatedUser!.value : this.updatedUser,
      status: status ?? this.status,
      error: error is Wrapped ? error!.value : this.error,
      errors: errors ?? this.errors,
    );
  }

  bool get canSubmit =>
      !isSubmitting &&
      photograph != null &&
      evidenceOfId != null &&
      videoVerification != null;

  Map<String, dynamic> get payload => {
        'photograph_id': photograph?.id,
        'evidence_of_id_id': evidenceOfId?.id,
        'video_verification_id': videoVerification?.id,
      };
  bool get isSubmitting => status == ComplianceFormStatus.submitting;

  @override
  List<Object?> get props => [
        photograph,
        evidenceOfId,
        videoVerification,
        status,
        updatedUser,
        error,
        errors
      ];

  @override
  bool? get stringify => false;
}
