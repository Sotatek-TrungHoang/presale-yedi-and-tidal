import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/api/api_exceptions.dart';
import 'package:yedi_app/modules/authentication/services/authentication_service.dart';
import 'package:yedi_app/modules/common/cubits/generic_form_state.dart';
import 'package:yedi_app/util/models.dart';

class ResetPasswordState extends GenericFormState implements Equatable {
  ResetPasswordState({
    required super.status,
    required super.data,
    required super.errors,
    required super.error,
  });

  factory ResetPasswordState.initial() {
    return ResetPasswordState(
      status: FormStatus.idle,
      data: {
        "password": "",
        "password_confirmation": "",
      },
      errors: {},
      error: null,
    );
  }

  ResetPasswordState copyWith({
    FormStatus? status,
    Map<String, dynamic>? data,
    Map<String, String>? errors,
    Wrapped<String?>? error,
  }) {
    return ResetPasswordState(
      status: status ?? this.status,
      data: data ?? this.data,
      errors: errors ?? this.errors,
      error: error is Wrapped ? error!.value : this.error,
    );
  }

  @override
  List<Object?> get props => [
        status,
        data,
        errors,
        error,
      ];

  @override
  bool? get stringify => true;
}

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  final AuthenticationService authenticationService;
  final String email;
  final String token;

  ResetPasswordCubit(
      {required this.authenticationService,
      required this.email,
      required this.token})
      : super(ResetPasswordState.initial());

  fieldUpdated(String field, dynamic value) {
    emit(state.copyWith(
      data: {
        ...state.data,
        field: value,
      },
    ));
  }

  submit() async {
    emit(state.copyWith(status: FormStatus.submitting));
    try {
      await authenticationService.resetPassword(
        email: email,
        token: token,
        password: state.data['password'],
        passwordConfirmation: state.data['password_confirmation'],
      );
      emit(state.copyWith(status: FormStatus.success));
    } on APIValidationException catch (e) {
      emit(state.copyWith(
        status: FormStatus.idle,
        errors: e.errors,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FormStatus.idle,
        error: Wrapped.value(e.toString()),
      ));
    }
  }
}
