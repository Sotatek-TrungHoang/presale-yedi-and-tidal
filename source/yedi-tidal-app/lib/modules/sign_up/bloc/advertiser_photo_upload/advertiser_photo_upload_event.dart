import 'package:yedi_app/modules/authentication/models/auth_user_model.dart';
import 'package:yedi_app/modules/common/models/upload_model.dart';

sealed class AdvertiserPhotoUploadEvent {}

class AdvertiserPhotoUploadInitialised extends AdvertiserPhotoUploadEvent {
  final AuthUserModel? user;
  AdvertiserPhotoUploadInitialised(this.user);
}

class AdvertiserPhotoUploadPhotographChanged
    extends AdvertiserPhotoUploadEvent {
  final UploadModel? value;
  AdvertiserPhotoUploadPhotographChanged(this.value);
}

class AdvertiserPhotoUploadSubmitted extends AdvertiserPhotoUploadEvent {}
