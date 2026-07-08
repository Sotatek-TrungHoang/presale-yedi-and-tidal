import 'package:equatable/equatable.dart';
import 'package:yedi_app/modules/authentication/models/auth_user_model.dart';
import 'package:yedi_app/util/models.dart';

enum ReferencesStatus { loading, waitingForSubmit, submitting, success, error }

class ReferenceForm implements Equatable {
  final String name;
  final String telephone;
  final String email;

  ReferenceForm({this.name = '', this.telephone = '', this.email = ''});

  ReferenceForm copyWith({
    String? name,
    String? telephone,
    String? email,
  }) =>
      ReferenceForm(
        name: name ?? this.name,
        telephone: telephone ?? this.telephone,
        email: email ?? this.email,
      );

  @override
  List<Object?> get props => [name, telephone, email];

  @override
  bool? get stringify => true;
}

class ReferencesState implements Equatable {
  final List<ReferenceForm> references;

  final ReferencesStatus status;
  final Map<String, String> errors;
  final String? error;

  final AuthUserModel? updatedUser;

  ReferencesState({
    this.references = const [],
    this.status = ReferencesStatus.loading,
    this.error,
    this.errors = const {},
    this.updatedUser,
  });

  ReferencesState copyWith({
    List<ReferenceForm>? references,
    ReferencesStatus? status,
    Wrapped<String?>? error,
    Map<String, String>? errors,
    Wrapped<AuthUserModel?>? updatedUser,
  }) {
    return ReferencesState(
      references: references ?? this.references,
      status: status ?? this.status,
      error: error is Wrapped ? error!.value : this.error,
      errors: errors ?? this.errors,
      updatedUser:
          updatedUser is Wrapped ? updatedUser!.value : this.updatedUser,
    );
  }

  Map<String, dynamic> get payload => {
        'references': references
            .map((reference) => {
                  "name": reference.name,
                  "email": reference.email,
                  "telephone": reference.telephone,
                })
            .toList(),
      };

  bool get isSubmitting => status == ReferencesStatus.submitting;

  @override
  List<Object?> get props => [
        references,
        status,
        error,
        errors,
        updatedUser,
      ];

  @override
  bool? get stringify => false;
}
