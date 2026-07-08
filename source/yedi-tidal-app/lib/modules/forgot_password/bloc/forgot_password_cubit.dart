import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/api/api_exceptions.dart';
import 'package:yedi_app/modules/authentication/services/authentication_service.dart';
import 'package:yedi_app/modules/common/cubits/generic_form_state.dart';
import 'package:yedi_app/util/models.dart';

class ForgotPasswordState extends GenericFormState implements Equatable {
  ForgotPasswordState({
    required super.status,
    required super.data,
    required super.errors,
    required super.error,
  });

  factory ForgotPasswordState.initial() {
    return ForgotPasswordState(
      status: FormStatus.idle,
      data: {
        "email": "",
      },
      errors: {},
      error: null,
    );
  }

  ForgotPasswordState copyWith({
    FormStatus? status,
    Map<String, dynamic>? data,
    Map<String, String>? errors,
    Wrapped<String?>? error,
  }) {
    return ForgotPasswordState(
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

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final AuthenticationService authenticationService;

  ForgotPasswordCubit({required this.authenticationService})
      : super(ForgotPasswordState.initial());

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
      await authenticationService.forgotPassword(state.data['email']);
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
