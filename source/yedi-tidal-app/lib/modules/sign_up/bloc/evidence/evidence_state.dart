import 'package:equatable/equatable.dart';
import 'package:yedi_app/modules/authentication/models/auth_user_model.dart';
import 'package:yedi_app/modules/common/models/upload_model.dart';
import 'package:yedi_app/util/models.dart';

enum EvidenceStatus { waitingForSubmit, submitting, success, error }

class EvidenceState implements Equatable {
  final UploadModel? upload;

  final EvidenceStatus status;
  final Map<String, String> errors;
  final String? error;

  final AuthUserModel? updatedUser;

  EvidenceState({
    this.upload,
    this.status = EvidenceStatus.waitingForSubmit,
    this.error,
    this.errors = const {},
    this.updatedUser,
  });

  EvidenceState copyWith({
    Wrapped<UploadModel?>? upload,
    EvidenceStatus? status,
    Wrapped<String?>? error,
    Map<String, String>? errors,
    Wrapped<AuthUserModel?>? updatedUser,
  }) {
    return EvidenceState(
      upload: upload is Wrapped ? upload!.value : this.upload,
      status: status ?? this.status,
      error: error is Wrapped ? error!.value : this.error,
      errors: errors ?? this.errors,
      updatedUser:
          updatedUser is Wrapped ? updatedUser!.value : this.updatedUser,
    );
  }

  Map<String, dynamic> get payload => {
        "upload_id": upload?.id,
      };

  bool get isSubmitting => status == EvidenceStatus.submitting;
  bool get canSubmit => !isSubmitting && upload != null;

  @override
  List<Object?> get props => [
        upload,
        status,
        error,
        errors,
        updatedUser,
      ];

  @override
  bool? get stringify => false;
}
