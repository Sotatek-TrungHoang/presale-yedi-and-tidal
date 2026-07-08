import 'package:equatable/equatable.dart';
import 'package:yedi_app/modules/authentication/models/auth_user_model.dart';
import 'package:yedi_app/ui/inputs/dropdown_input.dart';
import 'package:yedi_app/util/data_types.dart';
import 'package:yedi_app/util/models.dart';

enum QualificationsStatus {
  loading,
  waitingForSubmit,
  submitting,
  success,
  error
}

class QualificationsState implements Equatable {
  final List<Value<String>> qualifications;
  final String? qualification;
  final String teacherNumber;

  final QualificationsStatus status;
  final Map<String, String> errors;
  final String? error;

  final AuthUserModel? updatedUser;

  QualificationsState({
    this.qualifications = const [],
    this.qualification,
    this.teacherNumber = '',
    this.status = QualificationsStatus.loading,
    this.error,
    this.errors = const {},
    this.updatedUser,
  });

  QualificationsState copyWith({
    List<Value<String>>? qualifications,
    Wrapped<String?>? qualification,
    String? teacherNumber,
    QualificationsStatus? status,
    Wrapped<String?>? error,
    Map<String, String>? errors,
    Wrapped<AuthUserModel?>? updatedUser,
  }) {
    return QualificationsState(
      qualifications: qualifications ?? this.qualifications,
      qualification:
          qualification is Wrapped ? qualification!.value : this.qualification,
      teacherNumber: teacherNumber ?? this.teacherNumber,
      status: status ?? this.status,
      error: error is Wrapped ? error!.value : this.error,
      errors: errors ?? this.errors,
      updatedUser:
          updatedUser is Wrapped ? updatedUser!.value : this.updatedUser,
    );
  }

  Map<String, dynamic> get payload => {
        'teacher_number': teacherNumber,
        'qualification': qualification,
      };

  bool get isSubmitting => status == QualificationsStatus.submitting;

  List<DropdownOption<String>> get qualificationItems => qualifications
      .map((e) => DropdownOption<String>(
            e.value,
            e.label,
          ))
      .toList();

  @override
  List<Object?> get props => [
        qualifications,
        qualification,
        teacherNumber,
        status,
        error,
        errors,
        updatedUser,
      ];

  @override
  bool? get stringify => false;
}
