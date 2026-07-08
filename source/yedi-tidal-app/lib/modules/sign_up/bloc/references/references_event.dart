import 'package:yedi_app/modules/authentication/models/auth_user_model.dart';

sealed class ReferencesEvent {}

class ReferencesInitialised extends ReferencesEvent {
  final int referencesRequired;
  final AuthUserModel? user;
  ReferencesInitialised(this.referencesRequired, this.user);
}

class ReferencesNameChanged extends ReferencesEvent {
  final int index;
  final String value;
  ReferencesNameChanged(this.index, this.value);
}

class ReferencesEmailChanged extends ReferencesEvent {
  final int index;
  final String value;
  ReferencesEmailChanged(this.index, this.value);
}

class ReferencesTelephoneChanged extends ReferencesEvent {
  final int index;
  final String value;
  ReferencesTelephoneChanged(this.index, this.value);
}

class ReferencesSubmitted extends ReferencesEvent {}
