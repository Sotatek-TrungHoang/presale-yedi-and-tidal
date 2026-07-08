import 'package:equatable/equatable.dart';
import 'package:yedi_app/modules/authentication/models/auth_user_model.dart';
import 'package:yedi_app/util/models.dart';

enum RightToWorkStatus { waitingForSubmit, submitting, success, error }

class RightToWorkState implements Equatable {
  final bool? rightToWorkUk;
  final bool? requireVisaToWorkUk;
  final bool? livedOrWorkedOutsideUk6Months;
  final bool? hasCriminalConvictionsOrProsecutionsPending;

  final RightToWorkStatus status;
  final Map<String, String> errors;
  final String? error;

  final AuthUserModel? updatedUser;

  RightToWorkState({
    this.rightToWorkUk,
    this.requireVisaToWorkUk,
    this.livedOrWorkedOutsideUk6Months,
    this.hasCriminalConvictionsOrProsecutionsPending,
    this.status = RightToWorkStatus.waitingForSubmit,
    this.error,
    this.errors = const {},
    this.updatedUser,
  });

  RightToWorkState copyWith({
    bool? rightToWorkUk,
    bool? requireVisaToWorkUk,
    bool? livedOrWorkedOutsideUk6Months,
    bool? hasCriminalConvictionsOrProsecutionsPending,
    RightToWorkStatus? status,
    Wrapped<String?>? error,
    Map<String, String>? errors,
    Wrapped<AuthUserModel?>? updatedUser,
  }) {
    return RightToWorkState(
      rightToWorkUk: rightToWorkUk ?? this.rightToWorkUk,
      requireVisaToWorkUk: requireVisaToWorkUk ?? this.requireVisaToWorkUk,
      livedOrWorkedOutsideUk6Months:
          livedOrWorkedOutsideUk6Months ?? this.livedOrWorkedOutsideUk6Months,
      hasCriminalConvictionsOrProsecutionsPending:
          hasCriminalConvictionsOrProsecutionsPending ??
              this.hasCriminalConvictionsOrProsecutionsPending,
      status: status ?? this.status,
      error: error is Wrapped ? error!.value : this.error,
      errors: errors ?? this.errors,
      updatedUser:
          updatedUser is Wrapped ? updatedUser!.value : this.updatedUser,
    );
  }

  bool get isSubmitting => status == RightToWorkStatus.submitting;
  bool get canSubmit =>
      !isSubmitting &&
      rightToWorkUk != null &&
      requireVisaToWorkUk != null &&
      livedOrWorkedOutsideUk6Months != null &&
      hasCriminalConvictionsOrProsecutionsPending != null;

  Map<String, dynamic> get payload => {
        "right_to_work_uk": rightToWorkUk,
        "require_visa_to_work_uk": requireVisaToWorkUk,
        "lived_or_worked_outside_uk_6_months": livedOrWorkedOutsideUk6Months,
        "has_criminal_convictions_or_prosecutions_pending":
            hasCriminalConvictionsOrProsecutionsPending,
      };

  @override
  List<Object?> get props => [
        rightToWorkUk,
        requireVisaToWorkUk,
        livedOrWorkedOutsideUk6Months,
        hasCriminalConvictionsOrProsecutionsPending,
        status,
        error,
        errors,
        updatedUser,
      ];

  @override
  bool? get stringify => false;
}
