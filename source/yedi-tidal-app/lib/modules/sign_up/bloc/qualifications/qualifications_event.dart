import 'package:yedi_app/modules/authentication/models/auth_user_model.dart';

sealed class QualificationsEvent {}

class QualificationsInitialised extends QualificationsEvent {
  final AuthUserModel? user;
  QualificationsInitialised(this.user);
}

class QualificationsTeacherNumberChanged extends QualificationsEvent {
  final String value;
  QualificationsTeacherNumberChanged(this.value);
}

class QualificationsQualificationChanged extends QualificationsEvent {
  final String? value;
  QualificationsQualificationChanged(this.value);
}

class QualificationsSubmitted extends QualificationsEvent {}
