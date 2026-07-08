import 'package:yedi_app/modules/authentication/models/auth_user_model.dart';

sealed class RightToWorkEvent {}

class RightToWorkInitialised extends RightToWorkEvent {
  final AuthUserModel? user;
  RightToWorkInitialised(this.user);
}

class RightToWorkRightToWorkUkChanged extends RightToWorkEvent {
  final bool value;
  RightToWorkRightToWorkUkChanged(this.value);
}

class RightToWorkRequireVisaToWorkUkChanged extends RightToWorkEvent {
  final bool value;
  RightToWorkRequireVisaToWorkUkChanged(this.value);
}

class RightToWorkLivedOrWorkedOutsideUk6MonthsChanged extends RightToWorkEvent {
  final bool value;
  RightToWorkLivedOrWorkedOutsideUk6MonthsChanged(this.value);
}

class RightToWorkHasCriminalConvictionsOrProsecutionsPendingChanged
    extends RightToWorkEvent {
  final bool value;
  RightToWorkHasCriminalConvictionsOrProsecutionsPendingChanged(this.value);
}

class RightToWorkSubmitted extends RightToWorkEvent {}
