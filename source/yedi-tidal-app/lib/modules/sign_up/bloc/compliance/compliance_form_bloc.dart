import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/api/api_exceptions.dart';
import 'package:yedi_app/modules/sign_up/bloc/compliance/compliance_form_event.dart';
import 'package:yedi_app/modules/sign_up/bloc/compliance/compliance_form_state.dart';
import 'package:yedi_app/modules/sign_up/services/sign_up_service.dart';
import 'package:yedi_app/modules/sign_up/services/video_verification_service.dart';
import 'package:yedi_app/util/models.dart';

class ComplianceFormBloc extends Bloc<ComplianceFormEvent, ComplianceFormState> {
  final SignUpService signUpService;
  final VideoVerificationService videoVerificationService;

  ComplianceFormBloc({required this.signUpService, required this.videoVerificationService}) : super(ComplianceFormState()) {
    on<ComplianceFormInitialised>(_onComplianceFormInitialised);
    on<ComplianceFormPhotographChanged>(_onComplianceFormPhotographChanged);
    on<ComplianceFormEvidenceOfIdChanged>(_onComplianceFormEvidenceOfIdChanged);
    on<ComplianceFormVideoVerificationChanged>(_onComplianceFormVideoVerificationChanged);
    on<ComplianceFormSubmitted>(_onComplianceFormSubmitted);
  }

  _onComplianceFormInitialised(ComplianceFormInitialised event, Emitter<ComplianceFormState> emit) async {
    emit(state.copyWith(
      photograph: Wrapped.value(event.user?.applicant?.photograph),
      evidenceOfId: Wrapped.value(event.user?.applicant?.evidenceOfId),
      videoVerification: Wrapped.value(event.user?.applicant?.videoVerification),
    ));
  }

  _onComplianceFormPhotographChanged(ComplianceFormPhotographChanged event, Emitter<ComplianceFormState> emit) async {
    emit(state.copyWith(
      photograph: Wrapped.value(event.value),
    ));
  }

  _onComplianceFormEvidenceOfIdChanged(ComplianceFormEvidenceOfIdChanged event, Emitter<ComplianceFormState> emit) async {
    emit(state.copyWith(
      evidenceOfId: Wrapped.value(event.value),
    ));
  }

  _onComplianceFormVideoVerificationChanged(ComplianceFormVideoVerificationChanged event, Emitter<ComplianceFormState> emit) async {
    emit(state.copyWith(
      videoVerification: Wrapped.value(event.value),
    ));
  }

  _onComplianceFormSubmitted(ComplianceFormSubmitted event, Emitter<ComplianceFormState> emit) async {
    emit(state.copyWith(status: ComplianceFormStatus.submitting, errors: {}, error: Wrapped.value(null)));

    try {
      final payload = state.payload;
      final updatedUser = await signUpService.submitCompliance(payload);
      emit(state.copyWith(
        status: ComplianceFormStatus.success,
        updatedUser: Wrapped.value(updatedUser),
      ));
    } on APIValidationException catch (e) {
      emit(state.copyWith(
        status: ComplianceFormStatus.waitingForSubmit,
        error: Wrapped.value(e.message),
        errors: e.errors,
      ));
    } on APIException catch (e) {
      emit(state.copyWith(
        status: ComplianceFormStatus.waitingForSubmit,
        error: Wrapped.value(e.message),
      ));
    } catch (e) {
      emit(state.copyWith(
        error: Wrapped.value(e.toString()),
        status: ComplianceFormStatus.waitingForSubmit,
      ));
    }
  }
}
