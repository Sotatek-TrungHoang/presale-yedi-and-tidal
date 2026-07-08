import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/api/api_exceptions.dart';
import 'package:yedi_app/modules/sign_up/bloc/right_to_work/right_to_work_event.dart';
import 'package:yedi_app/modules/sign_up/bloc/right_to_work/right_to_work_state.dart';
import 'package:yedi_app/modules/sign_up/services/sign_up_service.dart';
import 'package:yedi_app/util/models.dart';

class RightToWorkBloc extends Bloc<RightToWorkEvent, RightToWorkState> {
  final SignUpService signUpService;

  RightToWorkBloc({required this.signUpService}) : super(RightToWorkState()) {
    on<RightToWorkInitialised>(_onRightToWorkInitialised);
    on<RightToWorkRightToWorkUkChanged>(_onRightToWorkRightToWorkUkChanged);
    on<RightToWorkRequireVisaToWorkUkChanged>(
        _onRightToWorkRequireVisaToWorkUkChanged);
    on<RightToWorkLivedOrWorkedOutsideUk6MonthsChanged>(
        _onRightToWorkLivedOrWorkedOutsideUk6MonthsChanged);
    on<RightToWorkHasCriminalConvictionsOrProsecutionsPendingChanged>(
        _onRightToWorkHasCriminalConvictionsOrProsecutionsPendingChanged);
    on<RightToWorkSubmitted>(_onRightToWorkSubmitted);
  }

  _onRightToWorkInitialised(
      RightToWorkInitialised event, Emitter<RightToWorkState> emit) async {
    emit(state.copyWith(
      rightToWorkUk:
          event.user?.applicant?.rightToWorkDeclaration?.rightToWorkUk,
      requireVisaToWorkUk:
          event.user?.applicant?.rightToWorkDeclaration?.requireVisaToWorkUk,
      livedOrWorkedOutsideUk6Months: event.user?.applicant
          ?.rightToWorkDeclaration?.livedOrWorkedOutsideUk6Months,
      hasCriminalConvictionsOrProsecutionsPending: event.user?.applicant
          ?.rightToWorkDeclaration?.hasCriminalConvictionsOrProsecutionsPending,
    ));
  }

  _onRightToWorkRightToWorkUkChanged(RightToWorkRightToWorkUkChanged event,
      Emitter<RightToWorkState> emit) async {
    emit(state.copyWith(rightToWorkUk: event.value));
  }

  _onRightToWorkRequireVisaToWorkUkChanged(
      RightToWorkRequireVisaToWorkUkChanged event,
      Emitter<RightToWorkState> emit) async {
    emit(state.copyWith(requireVisaToWorkUk: event.value));
  }

  _onRightToWorkLivedOrWorkedOutsideUk6MonthsChanged(
      RightToWorkLivedOrWorkedOutsideUk6MonthsChanged event,
      Emitter<RightToWorkState> emit) async {
    emit(state.copyWith(livedOrWorkedOutsideUk6Months: event.value));
  }

  _onRightToWorkHasCriminalConvictionsOrProsecutionsPendingChanged(
      RightToWorkHasCriminalConvictionsOrProsecutionsPendingChanged event,
      Emitter<RightToWorkState> emit) async {
    emit(state.copyWith(
        hasCriminalConvictionsOrProsecutionsPending: event.value));
  }

  _onRightToWorkSubmitted(
      RightToWorkSubmitted event, Emitter<RightToWorkState> emit) async {
    emit(state.copyWith(
        status: RightToWorkStatus.submitting,
        errors: {},
        error: Wrapped.value(null),
        updatedUser: Wrapped.value(null)));

    try {
      final response =
          await signUpService.submitRightToWorkDeclaration(state.payload);

      emit(state.copyWith(
          status: RightToWorkStatus.success,
          updatedUser: Wrapped.value(response),
          error: Wrapped.value(null)));
    } on APIValidationException catch (e) {
      emit(state.copyWith(
          status: RightToWorkStatus.waitingForSubmit,
          errors: e.errors,
          error: Wrapped.value(e.message ?? e.toString())));
    } on APIException catch (e) {
      emit(state.copyWith(
          status: RightToWorkStatus.waitingForSubmit,
          error: Wrapped.value(e.message ?? e.toString())));
    } catch (e) {
      emit(state.copyWith(
          status: RightToWorkStatus.waitingForSubmit,
          error: Wrapped.value(e.toString())));
    }
  }
}
