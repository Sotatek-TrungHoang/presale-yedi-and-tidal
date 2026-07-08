import 'package:yedi_app/modules/authentication/models/auth_user_model.dart';

sealed class DeclarationEvent {}

class DeclarationInitialised extends DeclarationEvent {
  final AuthUserModel? user;
  DeclarationInitialised(this.user);
}

class DeclarationAgreedChanged extends DeclarationEvent {
  final bool value;
  DeclarationAgreedChanged(this.value);
}

class DeclarationSubmitted extends DeclarationEvent {}
