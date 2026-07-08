import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/common/services/account_service.dart';
import 'package:yedi_app/util/models.dart';

enum DeleteAccountStatus {
  initial,
  submitting,
  success,
}

class DeleteAccountState implements Equatable {
  final DeleteAccountStatus status;
  final String? error;

  DeleteAccountState({this.status = DeleteAccountStatus.initial, this.error});

  DeleteAccountState copyWith({
    DeleteAccountStatus? status,
    Wrapped<String?>? error,
  }) {
    return DeleteAccountState(
        status: status ?? this.status,
        error: error is Wrapped ? error!.value : this.error);
  }

  bool get canSubmit => isInitial;
  bool get isInitial => status == DeleteAccountStatus.initial;
  bool get isSubmitting => status == DeleteAccountStatus.submitting;
  bool get isSuccess => status == DeleteAccountStatus.success;

  @override
  List<Object?> get props => [
        status,
        error,
      ];

  @override
  bool? get stringify => true;
}

class DeleteAccountCubit extends Cubit<DeleteAccountState> {
  final AccountService accountService;

  DeleteAccountCubit({required this.accountService})
      : super(DeleteAccountState());

  submit() async {
    emit(state.copyWith(
      status: DeleteAccountStatus.submitting,
      error: Wrapped.value(null),
    ));

    try {
      await accountService.deleteAccount();
      emit(state.copyWith(
        status: DeleteAccountStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DeleteAccountStatus.initial,
        error: Wrapped.value(e.toString()),
      ));
    }
  }
}
