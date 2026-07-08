import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/authentication/models/auth_user_model.dart';
import 'package:yedi_app/modules/profile/service/profile_service.dart';
import 'package:yedi_app/modules/sign_up/models/declaration_model.dart';
import 'package:yedi_app/modules/sign_up/services/declaration_service.dart';
import 'package:yedi_app/util/models.dart';

enum UpdateDeclarationStatus { loading, loaded, submitting, error, success }

class UpdateDeclarationState implements Equatable {
  final DeclarationModel? declaration;
  final bool agreed;
  final bool locked;
  final UpdateDeclarationStatus status;
  final String? error;

  UpdateDeclarationState({
    this.declaration,
    this.agreed = false,
    this.locked = false,
    this.status = UpdateDeclarationStatus.loading,
    this.error,
  });

  UpdateDeclarationState copyWith({
    UpdateDeclarationStatus? status,
    Wrapped<DeclarationModel?>? declaration,
    bool? agreed,
    bool? locked,
    Wrapped<String?>? error,
  }) {
    return UpdateDeclarationState(
      status: status ?? this.status,
      declaration:
          declaration is Wrapped ? declaration!.value : this.declaration,
      agreed: agreed ?? this.agreed,
      locked: locked ?? this.locked,
      error: error is Wrapped ? error!.value : this.error,
    );
  }

  bool get isLoading => status == UpdateDeclarationStatus.loading;
  bool get isLoaded => status == UpdateDeclarationStatus.loaded;
  bool get isSubmitting => status == UpdateDeclarationStatus.submitting;
  bool get isError => status == UpdateDeclarationStatus.error;
  bool get isSuccess => status == UpdateDeclarationStatus.success;

  @override
  List<Object?> get props => [
        status,
        declaration,
        agreed,
        locked,
        error,
      ];

  @override
  bool? get stringify => true;
}

class UpdateDeclarationCubit extends Cubit<UpdateDeclarationState> {
  final ProfileService profileService;
  final DeclarationService declarationService;
  final int declarationId;

  UpdateDeclarationCubit(
      {required this.declarationId,
      required this.profileService,
      required this.declarationService,
      required AuthUserModel user})
      : super(UpdateDeclarationState(
            locked: user.applicant?.declarationAgreements
                    .where((e) => e.declaration.id == declarationId)
                    .isNotEmpty ??
                false,
            agreed: user.applicant?.declarationAgreements
                    .where((e) => e.declaration.id == declarationId)
                    .isNotEmpty ??
                false));

  init() async {
    try {
      final declaration =
          await declarationService.getDeclaration(declarationId);
      emit(state.copyWith(
        status: UpdateDeclarationStatus.loaded,
        declaration: Wrapped.value(declaration),
      ));
    } catch (e) {
      emit(state.copyWith(
          status: UpdateDeclarationStatus.error,
          error: Wrapped.value(e.toString())));
    }
  }

  agreedChanged(bool agreed) {
    emit(state.copyWith(agreed: agreed));
  }

  submit() async {
    emit(state.copyWith(status: UpdateDeclarationStatus.submitting));
    try {
      await profileService.agreeToDeclaration(declarationId);
      emit(state.copyWith(status: UpdateDeclarationStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: UpdateDeclarationStatus.loaded,
        error: Wrapped.value(e.toString()),
      ));
    }
  }
}
