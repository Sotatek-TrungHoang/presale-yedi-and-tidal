import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/api/api_exceptions.dart';
import 'package:yedi_app/modules/hearted_applicants/bloc/hearted_applicants_event.dart';
import 'package:yedi_app/modules/hearted_applicants/bloc/hearted_applicants_state.dart';
import 'package:yedi_app/modules/hearted_applicants/services/hearted_applicants_service.dart';
import 'package:yedi_app/util/models.dart';

class HeartedApplicantsBloc
    extends Bloc<HeartedApplicantsEvent, HeartedApplicantsState> {
  HeartedApplicantsBloc({required this.heartedApplicantsService})
      : super(HeartedApplicantsState()) {
    on<HeartedApplicantsInitialised>(_onHeartedApplicantsInitialised);
    on<HeartedApplicantsRefreshed>(_onHeartedApplicantsRefreshed);
    on<HeartedApplicantsApplicantHearted>(_onHeartedApplicantsApplicantHearted);
  }

  final HeartedApplicantsService heartedApplicantsService;

  _onHeartedApplicantsInitialised(HeartedApplicantsInitialised event,
      Emitter<HeartedApplicantsState> emit) async {
    emit(state.copyWith(status: HeartedApplicantsStatus.loading));
    await _fetchApplicants(emit);
  }

  _onHeartedApplicantsRefreshed(HeartedApplicantsRefreshed event,
      Emitter<HeartedApplicantsState> emit) async {
    emit(state.copyWith(status: HeartedApplicantsStatus.refreshing));
    await _fetchApplicants(emit);
  }

  _onHeartedApplicantsApplicantHearted(
    HeartedApplicantsApplicantHearted event,
    Emitter<HeartedApplicantsState> emit,
  ) {
    final applicants = state.heartedApplicants.map((heartedApplicant) {
      if (heartedApplicant.id == event.heartedApplicantId) {
        heartedApplicant = heartedApplicant.setHearted(event.hearted);
      }
      return heartedApplicant;
    }).toList();
    emit(state.copyWith(heartedApplicants: applicants));
  }

  _fetchApplicants(Emitter<HeartedApplicantsState> emit) async {
    try {
      final applicants = await heartedApplicantsService.getHeartedApplicants();
      emit(state.copyWith(
          heartedApplicants: applicants,
          status: HeartedApplicantsStatus.loaded,
          error: null));
    } on APIException catch (e) {
      emit(state.copyWith(
          status: HeartedApplicantsStatus.error,
          error: Wrapped.value(e.message ?? "Something went wrong")));
    } catch (e) {
      emit(state.copyWith(
          status: HeartedApplicantsStatus.error,
          error: Wrapped.value(e.toString())));
    }
  }
}
