import 'package:yedi_app/modules/authentication/models/auth_user_model.dart';

sealed class AuthenticationEvent {
  const AuthenticationEvent();
}

final class AuthenticationLogoutPressed extends AuthenticationEvent {}

final class RefreshUser extends AuthenticationEvent {}

final class ReplaceUserModel extends AuthenticationEvent {
  final AuthUserModel user;
  final String? bearerToken;
  ReplaceUserModel(this.user, [this.bearerToken]);
}
