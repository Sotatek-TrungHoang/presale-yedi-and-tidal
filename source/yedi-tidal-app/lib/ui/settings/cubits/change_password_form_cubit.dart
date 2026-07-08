import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/api/api_exceptions.dart';
import 'package:yedi_app/modules/common/services/change_password_service.dart';

enum ChangePasswordFormCubitStatus {
  initial,
  submitting,
  success,
}

class ChangePasswordFormCubitState implements Equatable {
  final ChangePasswordFormCubitStatus status;
  final String currentPassword;
  final String password;
  final String passwordConfirmation;

  final Map<String, dynamic> errors;

  ChangePasswordFormCubitState(
      {this.status = ChangePasswordFormCubitStatus.initial,
      this.currentPassword = "",
      this.password = "",
      this.passwordConfirmation = "",
      this.errors = const {}});

  ChangePasswordFormCubitState copyWith({
    ChangePasswordFormCubitStatus? status,
    String? currentPassword,
    String? password,
    String? passwordConfirmation,
    Map<String, dynamic>? errors,
  }) {
    return ChangePasswordFormCubitState(
        status: status ?? this.status,
        currentPassword: currentPassword ?? this.currentPassword,
        password: password ?? this.password,
        passwordConfirmation: passwordConfirmation ?? this.passwordConfirmation,
        errors: errors ?? this.errors);
  }

  bool get canSubmit =>
      (isInitial || isSuccess) &&
      currentPassword.isNotEmpty &&
      password.isNotEmpty &&
      passwordConfirmation.isNotEmpty;

  bool get canInput => isInitial || isSuccess;

  bool get isInitial => status == ChangePasswordFormCubitStatus.initial;
  bool get isSubmitting => status == ChangePasswordFormCubitStatus.submitting;
  bool get isSuccess => status == ChangePasswordFormCubitStatus.success;

  @override
  List<Object?> get props => [
        status,
        currentPassword,
        password,
        passwordConfirmation,
        errors,
      ];

  @override
  bool? get stringify => true;
}

class ChangePasswordFormCubit extends Cubit<ChangePasswordFormCubitState> {
  final ChangePasswordService changePasswordService;

  ChangePasswordFormCubit({required this.changePasswordService})
      : super(ChangePasswordFormCubitState());

  setCurrentPassword(String currentPassword) {
    emit(state.copyWith(currentPassword: currentPassword));
  }

  setPassword(String password) {
    emit(state.copyWith(password: password));
  }

  setPasswordConfirmation(String passwordConfirmation) {
    emit(state.copyWith(passwordConfirmation: passwordConfirmation));
  }

  submitEmail() async {
    emit(state.copyWith(
      status: ChangePasswordFormCubitStatus.submitting,
      errors: {},
    ));

    try {
      await changePasswordService.changePassword(
        currentPassword: state.currentPassword,
        password: state.password,
        passwordConfirmation: state.passwordConfirmation,
      );
      emit(state.copyWith(
        status: ChangePasswordFormCubitStatus.success,
        currentPassword: "",
        password: "",
        passwordConfirmation: "",
      ));
    } on APIValidationException catch (e) {
      emit(state.copyWith(
        status: ChangePasswordFormCubitStatus.initial,
        errors: e.errors,
      ));
    } on APIException catch (e) {
      emit(state.copyWith(
        status: ChangePasswordFormCubitStatus.initial,
        errors: {"password_confirmation": e.message ?? "An error occurred"},
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ChangePasswordFormCubitStatus.initial,
        errors: {"password_confirmation": e.toString()},
      ));
    }
  }
}
