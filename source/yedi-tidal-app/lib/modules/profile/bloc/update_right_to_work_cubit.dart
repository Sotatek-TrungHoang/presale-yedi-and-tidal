import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/authentication/models/auth_user_model.dart';
import 'package:yedi_app/modules/profile/service/profile_service.dart';
import 'package:yedi_app/util/models.dart';

enum UpdateRightToWorkStatus { idle, submitting, error, success }

class UpdateRightToWorkState implements Equatable {
  final bool? rightToWorkUk;
  final bool? requireVisaToWorkUk;
  final bool? livedOrWorkedOutsideUk6Months;
  final bool? hasCriminalConvictionsOrProsecutionsPending;

  final UpdateRightToWorkStatus status;
  final Map<String, String> errors;
  final String? error;

  UpdateRightToWorkState({
    this.rightToWorkUk,
    this.requireVisaToWorkUk,
    this.livedOrWorkedOutsideUk6Months,
    this.hasCriminalConvictionsOrProsecutionsPending,
    this.status = UpdateRightToWorkStatus.idle,
    this.error,
    this.errors = const {},
  });

  UpdateRightToWorkState copyWith({
    bool? rightToWorkUk,
    bool? requireVisaToWorkUk,
    bool? livedOrWorkedOutsideUk6Months,
    bool? hasCriminalConvictionsOrProsecutionsPending,
    UpdateRightToWorkStatus? status,
    Wrapped<String?>? error,
    Map<String, String>? errors,
  }) {
    return UpdateRightToWorkState(
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
    );
  }

  bool get isIdle => status == UpdateRightToWorkStatus.idle;
  bool get isSuccess => status == UpdateRightToWorkStatus.success;
  bool get isSubmitting => status == UpdateRightToWorkStatus.submitting;
  bool get canSubmit =>
      isIdle &&
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
      ];

  @override
  bool? get stringify => false;
}

class UpdateRightToWorkCubit extends Cubit<UpdateRightToWorkState> {
  final ProfileService profileService;

  UpdateRightToWorkCubit(
      {required this.profileService, required AuthUserModel user})
      : super(UpdateRightToWorkState(
          rightToWorkUk: user.applicant?.rightToWorkDeclaration?.rightToWorkUk,
          requireVisaToWorkUk:
              user.applicant?.rightToWorkDeclaration?.requireVisaToWorkUk,
          livedOrWorkedOutsideUk6Months: user
              .applicant?.rightToWorkDeclaration?.livedOrWorkedOutsideUk6Months,
          hasCriminalConvictionsOrProsecutionsPending: user
              .applicant
              ?.rightToWorkDeclaration
              ?.hasCriminalConvictionsOrProsecutionsPending,
        ));

  rightToWorkUkChanged(bool value) {
    emit(state.copyWith(rightToWorkUk: value));
  }

  requireVisaToWorkUkChanged(bool value) {
    emit(state.copyWith(requireVisaToWorkUk: value));
  }

  livedOrWorkedOutsideUk6MonthsChanged(bool value) {
    emit(state.copyWith(livedOrWorkedOutsideUk6Months: value));
  }

  hasCriminalConvictionsOrProsecutionsPendingChanged(bool value) {
    emit(state.copyWith(hasCriminalConvictionsOrProsecutionsPending: value));
  }

  submit() async {
    emit(state.copyWith(status: UpdateRightToWorkStatus.submitting));
    try {
      await profileService.updateRightToWorkDeclaration(state.payload);
      emit(state.copyWith(status: UpdateRightToWorkStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: UpdateRightToWorkStatus.idle,
        error: Wrapped.value(e.toString()),
      ));
    }
  }
}
