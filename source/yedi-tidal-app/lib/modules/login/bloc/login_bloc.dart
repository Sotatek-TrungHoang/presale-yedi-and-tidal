import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/api/api_exceptions.dart';
import 'package:yedi_app/modules/authentication/services/authentication_service.dart';
import 'package:yedi_app/modules/login/bloc/login_event.dart';
import 'package:yedi_app/modules/login/bloc/login_state.dart';
import 'package:yedi_app/util/models.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthenticationService _authenticationService;

  LoginBloc(AuthenticationService authenticationService)
      : _authenticationService = authenticationService,
        super(LoginState()) {
    on<LoginEmailChanged>(_onEmailChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LoginPrefillDebugApplicantPressed>(_onLoginPrefillDebugApplicantPressed);
    on<LoginPrefillDebugAdvertiserPressed>(
        _onLoginPrefillDebugAdvertiserPressed);
  }

  _onEmailChanged(
    LoginEmailChanged event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(
      email: event.value,
    ));
  }

  _onPasswordChanged(
    LoginPasswordChanged event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(
      password: event.value,
    ));
  }

  _onLoginPrefillDebugApplicantPressed(
      LoginPrefillDebugApplicantPressed event, Emitter<LoginState> emit) {
    emit(state.copyWith(
        email: "matthew.woodley+applicant@ne6.studio", password: "password"));
  }

  _onLoginPrefillDebugAdvertiserPressed(
      LoginPrefillDebugAdvertiserPressed event, Emitter<LoginState> emit) {
    emit(state.copyWith(
        email: "matthew.woodley+advertiser@ne6.studio", password: "password"));
  }

  Future _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(
        status: LoginStatus.submitting, error: const Wrapped.value(null)));

    try {
      final response =
          await _authenticationService.login(state.email, state.password);
      emit(state.copyWith(
          status: LoginStatus.success,
          successResponse: Wrapped.value(response)));
    } on APIException catch (e) {
      emit(state.copyWith(
          status: LoginStatus.waitingForSubmit,
          error: Wrapped.value(e.message)));
    } catch (e) {
      emit(state.copyWith(
          status: LoginStatus.waitingForSubmit,
          error: Wrapped.value(e.toString())));
    }
  }
}
