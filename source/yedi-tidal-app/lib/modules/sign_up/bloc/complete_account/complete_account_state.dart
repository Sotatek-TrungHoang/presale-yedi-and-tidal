import 'package:equatable/equatable.dart';
import 'package:yedi_app/modules/authentication/models/auth_user_model.dart';
import 'package:yedi_app/util/models.dart';

enum CompleteAccountStatus { waitingForSubmit, submitting, success }

class CompleteAccountState implements Equatable {
  final CompleteAccountStatus status;
  final String? error;
  final AuthUserModel? updatedUser;

  CompleteAccountState({
    this.status = CompleteAccountStatus.waitingForSubmit,
    this.error,
    this.updatedUser,
  });

  CompleteAccountState copyWith({
    CompleteAccountStatus? status,
    Wrapped<String?>? error,
    Wrapped<AuthUserModel?>? updatedUser,
  }) {
    return CompleteAccountState(
      status: status ?? this.status,
      error: error is Wrapped ? error!.value : this.error,
      updatedUser:
          updatedUser is Wrapped ? updatedUser!.value : this.updatedUser,
    );
  }

  bool get isSubmitting => status == CompleteAccountStatus.submitting;
  bool get canSubmit => !isSubmitting;

  @override
  List<Object?> get props => [
        status,
        error,
        updatedUser,
      ];

  @override
  bool? get stringify => false;
}
