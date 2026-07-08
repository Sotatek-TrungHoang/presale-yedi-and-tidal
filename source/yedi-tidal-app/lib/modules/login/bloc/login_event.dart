sealed class LoginEvent {}

class LoginEmailChanged extends LoginEvent {
  final String value;
  LoginEmailChanged(this.value);
}

class LoginPasswordChanged extends LoginEvent {
  final String value;
  LoginPasswordChanged(this.value);
}

class LoginPrefillDebugApplicantPressed extends LoginEvent {}

class LoginPrefillDebugAdvertiserPressed extends LoginEvent {}

class LoginSubmitted extends LoginEvent {}
