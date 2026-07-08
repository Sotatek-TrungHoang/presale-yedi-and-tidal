import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/api/api_exceptions.dart';
import 'package:yedi_app/modules/common/services/dropdown_service.dart';
import 'package:yedi_app/modules/sign_up/bloc/references/references_event.dart';
import 'package:yedi_app/modules/sign_up/bloc/references/references_state.dart';
import 'package:yedi_app/modules/sign_up/services/sign_up_service.dart';
import 'package:yedi_app/util/models.dart';

class ReferencesBloc extends Bloc<ReferencesEvent, ReferencesState> {
  final SignUpService signUpService;
  final DropdownService dropdownService;

  ReferencesBloc({required this.signUpService, required this.dropdownService})
      : super(ReferencesState()) {
    on<ReferencesInitialised>(_onReferencesInitialised);
    on<ReferencesNameChanged>(_onReferencesNameChanged);
    on<ReferencesEmailChanged>(_onReferencesEmailChanged);
    on<ReferencesTelephoneChanged>(_onReferencesTelephoneChanged);
    on<ReferencesSubmitted>(_onReferencesSubmitted);
  }

  _onReferencesInitialised(
      ReferencesInitialised event, Emitter<ReferencesState> emit) async {
    final List<ReferenceForm> references =
        List.generate(event.referencesRequired, (index) {
      final reference =
          event.user?.applicant?.references.elementAtOrNull(index);
      return ReferenceForm(
          name: reference?.name ?? "",
          email: reference?.email ?? "",
          telephone: reference?.telephone ?? "");
    });

    emit(state.copyWith(
        status: ReferencesStatus.waitingForSubmit, references: references));
  }

  _onReferencesNameChanged(
      ReferencesNameChanged event, Emitter<ReferencesState> emit) async {
    final references = state.references;

    final updatedReferences = List<ReferenceForm>.from(references);
    updatedReferences[event.index] =
        updatedReferences[event.index].copyWith(name: event.value);
    emit(state.copyWith(references: updatedReferences));
  }

  _onReferencesEmailChanged(
      ReferencesEmailChanged event, Emitter<ReferencesState> emit) async {
    final references = state.references;

    final updatedReferences = List<ReferenceForm>.from(references);
    updatedReferences[event.index] =
        updatedReferences[event.index].copyWith(email: event.value);
    emit(state.copyWith(references: updatedReferences));
  }

  _onReferencesTelephoneChanged(
      ReferencesTelephoneChanged event, Emitter<ReferencesState> emit) async {
    final references = state.references;

    final updatedReferences = List<ReferenceForm>.from(references);
    updatedReferences[event.index] =
        updatedReferences[event.index].copyWith(telephone: event.value);
    emit(state.copyWith(references: updatedReferences));
  }

  _onReferencesSubmitted(
      ReferencesSubmitted event, Emitter<ReferencesState> emit) async {
    emit(state.copyWith(
        status: ReferencesStatus.submitting,
        errors: {},
        error: Wrapped.value(null),
        updatedUser: Wrapped.value(null)));

    try {
      final payload = state.payload;
      final response = await signUpService.submitReferences(payload);

      emit(state.copyWith(
          status: ReferencesStatus.success,
          updatedUser: Wrapped.value(response),
          error: Wrapped.value(null)));
    } on APIValidationException catch (e) {
      emit(state.copyWith(
          status: ReferencesStatus.waitingForSubmit,
          errors: e.errors,
          error: Wrapped.value(e.message ?? e.toString())));
    } on APIException catch (e) {
      emit(state.copyWith(
          status: ReferencesStatus.waitingForSubmit,
          error: Wrapped.value(e.message ?? e.toString())));
    } catch (e) {
      emit(state.copyWith(
          status: ReferencesStatus.waitingForSubmit,
          error: Wrapped.value(e.toString())));
    }
  }
}
