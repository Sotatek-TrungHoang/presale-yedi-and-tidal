import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/authentication/bloc/authentication_event.dart';
import 'package:yedi_app/modules/authentication/bloc/authentication_state.dart';
import 'package:yedi_app/modules/authentication/models/auth_user_model.dart';
import 'package:yedi_app/modules/authentication/services/authentication_service.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc(
      {required AuthenticationService authenticationService,
      required AuthUserModel? initialUser})
      : _authenticationService = authenticationService,
        super(initialUser == null
            ? const AuthenticationState.unauthenticated()
            : AuthenticationState.authenticated(initialUser)) {
    on<AuthenticationLogoutPressed>(_onLogoutPressed);
    on<RefreshUser>(_onRefreshUser);
    on<ReplaceUserModel>(_onReplaceUserModel);
  }

  late final AuthenticationService _authenticationService;

  Future _onLogoutPressed(
    AuthenticationLogoutPressed event,
    Emitter<AuthenticationState> emit,
  ) async {
    _authenticationService.clearBearerToken();
    emit(const AuthenticationState.unauthenticated());
  }

  Future _onRefreshUser(
    RefreshUser event,
    Emitter<AuthenticationState> emit,
  ) async {
    final user = await _tryGetUser();
    if (user != null) {
      emit(AuthenticationState.authenticated(user));
    } else {
      emit(const AuthenticationState.unauthenticated());
    }
  }

  Future _onReplaceUserModel(
    ReplaceUserModel event,
    Emitter<AuthenticationState> emit,
  ) async {
    if (event.bearerToken != null) {
      _authenticationService.setBearerToken(event.bearerToken!);
    }
    emit(AuthenticationState.authenticated(event.user));
  }

  Future<AuthUserModel?> _tryGetUser() async {
    try {
      final user = await _authenticationService.getCurrentUser();
      return user;
    } catch (e) {
      return null;
    }
  }
}
