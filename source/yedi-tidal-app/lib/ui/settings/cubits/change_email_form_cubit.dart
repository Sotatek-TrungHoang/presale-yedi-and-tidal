import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/api/api_exceptions.dart';
import 'package:yedi_app/modules/authentication/models/auth_user_model.dart';
import 'package:yedi_app/modules/common/services/change_email_service.dart';
import 'package:yedi_app/util/models.dart';

enum ChangeEmailFormCubitStatus {
  initial,
  submittingEmail,
  inputtingCode,
  verifyingCode
}

class ChangeEmailFormCubitState implements Equatable {
  final ChangeEmailFormCubitStatus status;
  final String email;
  final String code;
  final String? error;
  final AuthUserModel? updatedUser;

  ChangeEmailFormCubitState(
      {this.status = ChangeEmailFormCubitStatus.initial,
      this.email = "",
      this.code = "",
      this.error,
      this.updatedUser});

  ChangeEmailFormCubitState copyWith({
    ChangeEmailFormCubitStatus? status,
    String? email,
    String? code,
    Wrapped<String?>? error,
    Wrapped<AuthUserModel?>? updatedUser,
  }) {
    return ChangeEmailFormCubitState(
        status: status ?? this.status,
        email: email ?? this.email,
        code: code ?? this.code,
        error: error is Wrapped ? error!.value : this.error,
        updatedUser:
            updatedUser is Wrapped ? updatedUser!.value : this.updatedUser);
  }

  bool get canRequestChange => isInitial && email.isNotEmpty;
  bool get canVerifyCode => isInputtingCode && code.length == 6;

  bool get isInitial => status == ChangeEmailFormCubitStatus.initial;
  bool get isSubmittingEmail =>
      status == ChangeEmailFormCubitStatus.submittingEmail;
  bool get isInputtingCode =>
      status == ChangeEmailFormCubitStatus.inputtingCode;
  bool get isVerifyingCode =>
      status == ChangeEmailFormCubitStatus.verifyingCode;

  @override
  List<Object?> get props => [
        status,
        email,
        code,
        error,
        updatedUser,
      ];

  @override
  bool? get stringify => true;
}

class ChangeEmailFormCubit extends Cubit<ChangeEmailFormCubitState> {
  final ChangeEmailService changeEmailService;

  ChangeEmailFormCubit({required this.changeEmailService})
      : super(ChangeEmailFormCubitState());

  setEmail(String email) {
    emit(state.copyWith(email: email));
  }

  submitEmail() async {
    emit(state.copyWith(
        status: ChangeEmailFormCubitStatus.submittingEmail,
        error: Wrapped.value(null),
        updatedUser: Wrapped.value(null)));

    try {
      await changeEmailService.requestEmailChange(state.email);
      emit(state.copyWith(status: ChangeEmailFormCubitStatus.inputtingCode));
    } on APIValidationException catch (e) {
      emit(state.copyWith(
        status: ChangeEmailFormCubitStatus.initial,
        error: Wrapped.value(e.message ?? "An error occurred"),
      ));
    } on APIException catch (e) {
      emit(state.copyWith(
        status: ChangeEmailFormCubitStatus.initial,
        error: Wrapped.value(e.message ?? "An error occurred"),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ChangeEmailFormCubitStatus.initial,
        error: Wrapped.value(e.toString()),
      ));
    }
  }

  setCode(String code) {
    emit(state.copyWith(code: code));
  }

  verifyEmail() async {
    emit(state.copyWith(
        status: ChangeEmailFormCubitStatus.verifyingCode,
        error: Wrapped.value(null)));

    try {
      final updatedUser =
          await changeEmailService.verifyCode(state.email, state.code);
      emit(state.copyWith(
          status: ChangeEmailFormCubitStatus.initial,
          email: "",
          code: "",
          updatedUser: Wrapped.value(updatedUser)));
    } on APIValidationException catch (e) {
      emit(state.copyWith(
        status: ChangeEmailFormCubitStatus.inputtingCode,
        error: Wrapped.value(e.message ?? "An error occurred"),
      ));
    } on APIException catch (e) {
      final data = e.response!.data as Map<String, dynamic>;
      if (data['data']?['action'] == 'code') {
        emit(state.copyWith(
          status: ChangeEmailFormCubitStatus.inputtingCode,
          error: Wrapped.value(e.message ?? "An error occurred"),
        ));
      } else {
        emit(state.copyWith(
          status: ChangeEmailFormCubitStatus.initial,
          error: Wrapped.value(e.message ?? "An error occurred"),
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: ChangeEmailFormCubitStatus.initial,
        error: Wrapped.value(e.toString()),
      ));
    }
  }

  cancel() {
    emit(state.copyWith(
        status: ChangeEmailFormCubitStatus.initial,
        email: "",
        code: "",
        error: null));
  }
}
