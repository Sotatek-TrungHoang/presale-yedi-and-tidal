import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/api/api_exceptions.dart';
import 'package:yedi_app/modules/hearted_applicants/services/hearted_applicants_service.dart';

class HeartApplicantState {
  final bool isHearting;
  final String? error;
  final String? success;
  final bool? newHeartedVal;

  HeartApplicantState(
      {required this.isHearting, this.error, this.success, this.newHeartedVal});
}

class HeartApplicantCubit extends Cubit<HeartApplicantState> {
  final int applicantId;
  final HeartedApplicantsService heartedApplicantsService;

  HeartApplicantCubit(
      {required this.heartedApplicantsService, required this.applicantId})
      : super(HeartApplicantState(isHearting: false));

  heartOrUnheartApplicant(bool heart) async {
    if (heart) {
      await heartApplicant();
    } else {
      await unheartApplicant();
    }
  }

  heartApplicant() async {
    emit(HeartApplicantState(isHearting: true));
    try {
      final success =
          await heartedApplicantsService.heartApplicant(applicantId);
      emit(HeartApplicantState(
          isHearting: false, success: success, newHeartedVal: true));
    } on APIException catch (e) {
      emit(HeartApplicantState(
          isHearting: false,
          error: e.message ?? "Something went wrong",
          success: null));
    } catch (e) {
      emit(HeartApplicantState(
          isHearting: false, error: e.toString(), success: null));
    }
  }

  unheartApplicant() async {
    emit(HeartApplicantState(isHearting: true));
    try {
      final success =
          await heartedApplicantsService.unheartApplicant(applicantId);
      emit(HeartApplicantState(
          isHearting: false, success: success, newHeartedVal: false));
    } on APIException catch (e) {
      emit(HeartApplicantState(
          isHearting: false,
          error: e.message ?? "Something went wrong",
          success: null));
    } catch (e) {
      emit(HeartApplicantState(
          isHearting: false, error: e.toString(), success: null));
    }
  }
}
