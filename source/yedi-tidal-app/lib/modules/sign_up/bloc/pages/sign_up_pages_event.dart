import 'package:yedi_app/modules/authentication/models/auth_user_model.dart';

sealed class SignUpPagesEvent {}

class SignUpPagesInitialised extends SignUpPagesEvent {
  final AuthUserModel? user;

  SignUpPagesInitialised(this.user);
}

class SignUpPagesUserTypeSelected extends SignUpPagesEvent {
  final UserType userType;

  SignUpPagesUserTypeSelected(this.userType);
}

class SignUpPagesOverviewCompleted extends SignUpPagesEvent {}

class SignUpPagesCreateProfileCompleted extends SignUpPagesEvent {}

class SignUpPagesAddressCompleted extends SignUpPagesEvent {}

class SignUpPagesQualificationsCompleted extends SignUpPagesEvent {}

class SignUpPagesComplianceCompleted extends SignUpPagesEvent {}

class SignUpPagesEvidenceCompleted extends SignUpPagesEvent {}

class SignUpPagesDeclarationCompleted extends SignUpPagesEvent {}

class SignUpPagesRightToWorkDeclarationCompleted extends SignUpPagesEvent {}

class SignUpPagesComplianceCompletedCompleted extends SignUpPagesEvent {}

class SignUpPagesPreviousPagePressed extends SignUpPagesEvent {}

class SignUpPagesCancelTapped extends SignUpPagesEvent {
  final UserType userType;
  final bool returnToLandingPage;
  SignUpPagesCancelTapped(this.userType, this.returnToLandingPage);
}
