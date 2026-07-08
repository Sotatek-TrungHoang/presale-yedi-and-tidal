import 'package:equatable/equatable.dart';
import 'package:yedi_app/modules/authentication/services/authentication_service.dart';
import 'package:yedi_app/util/models.dart';

enum LoginStatus { waitingForSubmit, submitting, success }

class LoginState implements Equatable {
  final String email;
  final String password;
  final LoginStatus status;

  final String? error;
  final LoginResponse? successResponse;

  LoginState(
      {this.email = '',
      this.password = '',
      this.status = LoginStatus.waitingForSubmit,
      this.error,
      this.successResponse});

  LoginState copyWith(
      {String? email,
      String? password,
      LoginStatus? status,
      Wrapped<String?>? error,
      Wrapped<LoginResponse?>? successResponse}) {
    return LoginState(
        email: email ?? this.email,
        password: password ?? this.password,
        status: status ?? this.status,
        error: error is Wrapped ? error!.value : null,
        successResponse: successResponse is Wrapped
            ? successResponse!.value
            : this.successResponse);
  }

  bool get isSubmitting => status == LoginStatus.submitting;
  bool get canSubmit =>
      !isSubmitting && email.isNotEmpty && password.isNotEmpty;

  @override
  List<Object?> get props => [email, password, status, error, successResponse];

  @override
  bool? get stringify => true;
}
