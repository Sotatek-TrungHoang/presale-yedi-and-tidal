import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/api/api_exceptions.dart';
import 'package:yedi_app/modules/common/services/dropdown_service.dart';
import 'package:yedi_app/modules/sign_up/bloc/qualifications/qualifications_event.dart';
import 'package:yedi_app/modules/sign_up/bloc/qualifications/qualifications_state.dart';
import 'package:yedi_app/modules/sign_up/services/sign_up_service.dart';
import 'package:yedi_app/util/models.dart';

class QualificationsBloc
    extends Bloc<QualificationsEvent, QualificationsState> {
  final SignUpService signUpService;
  final DropdownService dropdownService;

  QualificationsBloc(
      {required this.signUpService, required this.dropdownService})
      : super(QualificationsState()) {
    on<QualificationsInitialised>(_onQualificationsInitialised);
    on<QualificationsTeacherNumberChanged>(
        _onQualificationsTeacherNumberChanged);
    on<QualificationsQualificationChanged>(
        _onQualificationsQualificationChanged);
    on<QualificationsSubmitted>(_onQualificationsSubmitted);
  }

  _onQualificationsInitialised(QualificationsInitialised event,
      Emitter<QualificationsState> emit) async {
    try {
      final qualifications = await dropdownService.qualifications();

      emit(state.copyWith(
        status: QualificationsStatus.waitingForSubmit,
        qualifications: qualifications,
        qualification: Wrapped.value(qualifications
            .where(
                (title) => title.value == event.user?.applicant?.qualification)
            .firstOrNull
            ?.value),
        teacherNumber: event.user?.applicant?.teacherNumber ?? '',
      ));
    } on APIException catch (e) {
      emit(state.copyWith(
          status: QualificationsStatus.error,
          error: Wrapped.value(e.message ?? e.toString())));
    } catch (e) {
      emit(state.copyWith(
          status: QualificationsStatus.error,
          error: Wrapped.value(e.toString())));
    }
  }

  _onQualificationsTeacherNumberChanged(
      QualificationsTeacherNumberChanged event,
      Emitter<QualificationsState> emit) async {
    emit(state.copyWith(
      teacherNumber: event.value,
    ));
  }

  _onQualificationsQualificationChanged(
      QualificationsQualificationChanged event,
      Emitter<QualificationsState> emit) async {
    emit(state.copyWith(
      qualification: Wrapped.value(event.value),
    ));
  }

  _onQualificationsSubmitted(
      QualificationsSubmitted event, Emitter<QualificationsState> emit) async {
    emit(state.copyWith(
        status: QualificationsStatus.submitting,
        errors: {},
        error: Wrapped.value(null),
        updatedUser: Wrapped.value(null)));

    try {
      final payload = state.payload;
      final response = await signUpService.submitQualifications(payload);

      emit(state.copyWith(
          status: QualificationsStatus.success,
          updatedUser: Wrapped.value(response),
          error: Wrapped.value(null)));
    } on APIValidationException catch (e) {
      emit(state.copyWith(
          status: QualificationsStatus.waitingForSubmit,
          errors: e.errors,
          error: Wrapped.value(e.message ?? e.toString())));
    } on APIException catch (e) {
      emit(state.copyWith(
          status: QualificationsStatus.waitingForSubmit,
          error: Wrapped.value(e.message ?? e.toString())));
    } catch (e) {
      emit(state.copyWith(
          status: QualificationsStatus.waitingForSubmit,
          error: Wrapped.value(e.toString())));
    }
  }
}
