import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/api/api_exceptions.dart';
import 'package:yedi_app/modules/sign_up/bloc/evidence/evidence_event.dart';
import 'package:yedi_app/modules/sign_up/bloc/evidence/evidence_state.dart';
import 'package:yedi_app/modules/sign_up/services/evidence_service.dart';
import 'package:yedi_app/modules/sign_up/services/sign_up_service.dart';
import 'package:yedi_app/util/models.dart';

class EvidenceBloc extends Bloc<EvidenceEvent, EvidenceState> {
  final SignUpService signUpService;
  final EvidenceService evidenceService;
  final int requiredEvidenceId;

  EvidenceBloc(
      {required this.requiredEvidenceId,
      required this.signUpService,
      required this.evidenceService})
      : super(EvidenceState()) {
    on<EvidenceInitialised>(_onEvidenceInitialised);
    on<EvidenceUploadChanged>(_onEvidenceUploadChanged);
    on<EvidenceSubmitted>(_onEvidenceSubmitted);
  }

  _onEvidenceInitialised(
      EvidenceInitialised event, Emitter<EvidenceState> emit) async {
    final applicantEvidence = event.user?.applicant?.applicantEvidence
        .where((evidence) => evidence.requiredEvidence.id == requiredEvidenceId)
        .firstOrNull;
    emit(state.copyWith(
      upload: Wrapped.value(applicantEvidence?.upload),
    ));
  }

  _onEvidenceUploadChanged(
      EvidenceUploadChanged event, Emitter<EvidenceState> emit) async {
    emit(state.copyWith(upload: Wrapped.value(event.value)));
  }

  _onEvidenceSubmitted(
      EvidenceSubmitted event, Emitter<EvidenceState> emit) async {
    emit(state.copyWith(
        status: EvidenceStatus.submitting,
        errors: {},
        error: Wrapped.value(null),
        updatedUser: Wrapped.value(null)));

    try {
      final payload = state.payload;
      final response =
          await signUpService.submitEvidence(requiredEvidenceId, payload);

      emit(state.copyWith(
          status: EvidenceStatus.success,
          updatedUser: Wrapped.value(response),
          error: Wrapped.value(null)));
    } on APIValidationException catch (e) {
      emit(state.copyWith(
          status: EvidenceStatus.waitingForSubmit,
          errors: e.errors,
          error: Wrapped.value(e.message ?? e.toString())));
    } on APIException catch (e) {
      emit(state.copyWith(
          status: EvidenceStatus.waitingForSubmit,
          error: Wrapped.value(e.message ?? e.toString())));
    } catch (e) {
      emit(state.copyWith(
          status: EvidenceStatus.waitingForSubmit,
          error: Wrapped.value(e.toString())));
    }
  }
}
