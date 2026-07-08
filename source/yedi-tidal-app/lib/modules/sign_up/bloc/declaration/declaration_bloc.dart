import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/api/api_exceptions.dart';
import 'package:yedi_app/modules/sign_up/bloc/declaration/declaration_event.dart';
import 'package:yedi_app/modules/sign_up/bloc/declaration/declaration_state.dart';
import 'package:yedi_app/modules/sign_up/services/declaration_service.dart';
import 'package:yedi_app/modules/sign_up/services/sign_up_service.dart';
import 'package:yedi_app/util/models.dart';

class DeclarationBloc extends Bloc<DeclarationEvent, DeclarationState> {
  final SignUpService signUpService;
  final DeclarationService declarationService;
  final int declarationId;

  DeclarationBloc(
      {required this.declarationId,
      required this.signUpService,
      required this.declarationService})
      : super(DeclarationState()) {
    on<DeclarationInitialised>(_onDeclarationInitialised);
    on<DeclarationAgreedChanged>(_onDeclarationAgreedChanged);
    on<DeclarationSubmitted>(_onDeclarationSubmitted);
  }

  _onDeclarationInitialised(
      DeclarationInitialised event, Emitter<DeclarationState> emit) async {
    final agreed = event.user?.applicant?.declarationAgreements
        .where((agreement) => agreement.declaration.id == declarationId)
        .firstOrNull;
    emit(state.copyWith(
      agreed: agreed != null,
    ));
  }

  _onDeclarationAgreedChanged(
      DeclarationAgreedChanged event, Emitter<DeclarationState> emit) async {
    emit(state.copyWith(agreed: event.value));
  }

  _onDeclarationSubmitted(
      DeclarationSubmitted event, Emitter<DeclarationState> emit) async {
    emit(state.copyWith(
        status: DeclarationStatus.submitting,
        errors: {},
        error: Wrapped.value(null),
        updatedUser: Wrapped.value(null)));

    try {
      final response = await signUpService.agreeToDeclaration(declarationId);

      emit(state.copyWith(
          status: DeclarationStatus.success,
          updatedUser: Wrapped.value(response),
          error: Wrapped.value(null)));
    } on APIValidationException catch (e) {
      emit(state.copyWith(
          status: DeclarationStatus.waitingForSubmit,
          errors: e.errors,
          error: Wrapped.value(e.message ?? e.toString())));
    } on APIException catch (e) {
      emit(state.copyWith(
          status: DeclarationStatus.waitingForSubmit,
          error: Wrapped.value(e.message ?? e.toString())));
    } catch (e) {
      emit(state.copyWith(
          status: DeclarationStatus.waitingForSubmit,
          error: Wrapped.value(e.toString())));
    }
  }
}
