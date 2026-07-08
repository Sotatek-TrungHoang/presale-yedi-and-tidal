import 'package:yedi_app/modules/authentication/models/auth_user_model.dart';
import 'package:yedi_app/modules/common/models/upload_model.dart';

sealed class EvidenceEvent {}

class EvidenceInitialised extends EvidenceEvent {
  final AuthUserModel? user;
  EvidenceInitialised(this.user);
}

class EvidenceUploadChanged extends EvidenceEvent {
  final UploadModel? value;
  EvidenceUploadChanged(this.value);
}

class EvidenceSubmitted extends EvidenceEvent {}
