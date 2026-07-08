import 'package:yedi_app/modules/authentication/models/auth_user_model.dart';

sealed class CreateProfileEvent {}

class CreateProfileInitialised extends CreateProfileEvent {
  final AuthUserModel? user;
  CreateProfileInitialised(this.user);
}

class CreateProfileTitleChanged extends CreateProfileEvent {
  final String? value;
  CreateProfileTitleChanged(this.value);
}

class CreateProfileJobRoleChanged extends CreateProfileEvent {
  final int? value;
  CreateProfileJobRoleChanged(this.value);
}

class CreateProfileTypeOfWorkChanged extends CreateProfileEvent {
  final int? value;
  CreateProfileTypeOfWorkChanged(this.value);
}

class CreateProfileFirstNameChanged extends CreateProfileEvent {
  final String value;
  CreateProfileFirstNameChanged(this.value);
}

class CreateProfileLastNameChanged extends CreateProfileEvent {
  final String value;
  CreateProfileLastNameChanged(this.value);
}

class CreateProfileDateOfBirthChanged extends CreateProfileEvent {
  final DateTime? value;
  CreateProfileDateOfBirthChanged(this.value);
}

class CreateProfileTelephoneChanged extends CreateProfileEvent {
  final String value;
  CreateProfileTelephoneChanged(this.value);
}

class CreateProfileEmailChanged extends CreateProfileEvent {
  final String value;
  CreateProfileEmailChanged(this.value);
}

class CreateProfilePasswordChanged extends CreateProfileEvent {
  final String value;
  CreateProfilePasswordChanged(this.value);
}

class CreateProfilePasswordConfirmationChanged extends CreateProfileEvent {
  final String value;
  CreateProfilePasswordConfirmationChanged(this.value);
}

class CreateProfileAdvertiserNameChanged extends CreateProfileEvent {
  final String value;
  CreateProfileAdvertiserNameChanged(this.value);
}

class CreateProfileAdvertiserTelephoneChanged extends CreateProfileEvent {
  final String value;
  CreateProfileAdvertiserTelephoneChanged(this.value);
}

class CreateProfileAdvertiserEmailChanged extends CreateProfileEvent {
  final String value;
  CreateProfileAdvertiserEmailChanged(this.value);
}

class CreateProfileAdvertiserBioChanged extends CreateProfileEvent {
  final String value;
  CreateProfileAdvertiserBioChanged(this.value);
}

class CreateProfileAdvertiserAdditionalInfoChanged extends CreateProfileEvent {
  final String value;
  CreateProfileAdvertiserAdditionalInfoChanged(this.value);
}

class CreateProfileSubmitted extends CreateProfileEvent {}
