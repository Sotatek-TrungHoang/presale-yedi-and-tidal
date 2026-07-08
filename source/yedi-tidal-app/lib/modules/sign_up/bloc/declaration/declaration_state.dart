import 'package:equatable/equatable.dart';
import 'package:yedi_app/modules/authentication/models/auth_user_model.dart';
import 'package:yedi_app/util/models.dart';

enum DeclarationStatus { waitingForSubmit, submitting, success, error }

class DeclarationState implements Equatable {
  final bool agreed;

  final DeclarationStatus status;
  final Map<String, String> errors;
  final String? error;

  final AuthUserModel? updatedUser;

  DeclarationState({
    this.agreed = false,
    this.status = DeclarationStatus.waitingForSubmit,
    this.error,
    this.errors = const {},
    this.updatedUser,
  });

  DeclarationState copyWith({
    bool? agreed,
    DeclarationStatus? status,
    Wrapped<String?>? error,
    Map<String, String>? errors,
    Wrapped<AuthUserModel?>? updatedUser,
  }) {
    return DeclarationState(
      agreed: agreed ?? this.agreed,
      status: status ?? this.status,
      error: error is Wrapped ? error!.value : this.error,
      errors: errors ?? this.errors,
      updatedUser:
          updatedUser is Wrapped ? updatedUser!.value : this.updatedUser,
    );
  }

  bool get isSubmitting => status == DeclarationStatus.submitting;
  bool get canSubmit => !isSubmitting && agreed;

  @override
  List<Object?> get props => [
        agreed,
        status,
        error,
        errors,
        updatedUser,
      ];

  @override
  bool? get stringify => false;
}
