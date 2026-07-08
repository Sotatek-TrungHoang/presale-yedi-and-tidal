import 'package:yedi_app/modules/authentication/models/auth_user_model.dart';
import 'package:yedi_app/modules/sign_up/models/video_verification_model.dart';
import 'package:yedi_app/modules/common/models/upload_model.dart';

sealed class ComplianceFormEvent {}

class ComplianceFormInitialised extends ComplianceFormEvent {
  final AuthUserModel? user;
  ComplianceFormInitialised(this.user);
}

class ComplianceFormPhotographChanged extends ComplianceFormEvent {
  final UploadModel? value;
  ComplianceFormPhotographChanged(this.value);
}

class ComplianceFormEvidenceOfIdChanged extends ComplianceFormEvent {
  final UploadModel? value;
  ComplianceFormEvidenceOfIdChanged(this.value);
}

class ComplianceFormVideoVerificationChanged extends ComplianceFormEvent {
  final VideoVerificationModel? value;
  ComplianceFormVideoVerificationChanged(this.value);
}

class ComplianceFormSubmitted extends ComplianceFormEvent {}
