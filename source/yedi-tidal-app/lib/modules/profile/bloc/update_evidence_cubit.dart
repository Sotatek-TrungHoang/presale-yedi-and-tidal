import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/authentication/models/auth_user_model.dart';
import 'package:yedi_app/modules/common/models/upload_model.dart';
import 'package:yedi_app/modules/profile/service/profile_service.dart';
import 'package:yedi_app/modules/sign_up/models/required_evidence_model.dart';
import 'package:yedi_app/modules/sign_up/services/evidence_service.dart';
import 'package:yedi_app/util/models.dart';

enum UpdateEvidenceStatus { loading, loaded, submitting, error, success }

class UpdateEvidenceState implements Equatable {
  final RequiredEvidenceModel? requiredEvidence;
  final UploadModel? applicantEvidence;
  final UpdateEvidenceStatus status;
  final String? error;

  UpdateEvidenceState({
    this.requiredEvidence,
    this.applicantEvidence,
    this.status = UpdateEvidenceStatus.loading,
    this.error,
  });

  UpdateEvidenceState copyWith({
    UpdateEvidenceStatus? status,
    Wrapped<RequiredEvidenceModel?>? requiredEvidence,
    Wrapped<UploadModel?>? applicantEvidence,
    Wrapped<String?>? error,
  }) {
    return UpdateEvidenceState(
      status: status ?? this.status,
      requiredEvidence: requiredEvidence is Wrapped
          ? requiredEvidence!.value
          : this.requiredEvidence,
      applicantEvidence: applicantEvidence is Wrapped
          ? applicantEvidence!.value
          : this.applicantEvidence,
      error: error is Wrapped ? error!.value : this.error,
    );
  }

  bool get isLoading => status == UpdateEvidenceStatus.loading;
  bool get isLoaded => status == UpdateEvidenceStatus.loaded;
  bool get isSubmitting => status == UpdateEvidenceStatus.submitting;
  bool get isError => status == UpdateEvidenceStatus.error;
  bool get isSuccess => status == UpdateEvidenceStatus.success;

  @override
  List<Object?> get props => [
        status,
        requiredEvidence,
        applicantEvidence,
        error,
      ];

  @override
  bool? get stringify => true;
}

class UpdateEvidenceCubit extends Cubit<UpdateEvidenceState> {
  final ProfileService profileService;
  final EvidenceService evidenceService;
  final int requiredEvidenceId;

  UpdateEvidenceCubit(
      {required this.requiredEvidenceId,
      required this.profileService,
      required this.evidenceService,
      required AuthUserModel user})
      : super(UpdateEvidenceState(
            applicantEvidence: user.applicant?.applicantEvidence
                .where((e) => e.requiredEvidence.id == requiredEvidenceId)
                .firstOrNull
                ?.upload));

  init() async {
    try {
      final requiredEvidence =
          await evidenceService.getRequiredEvidence(requiredEvidenceId);
      emit(state.copyWith(
        status: UpdateEvidenceStatus.loaded,
        requiredEvidence: Wrapped.value(requiredEvidence),
      ));
    } catch (e) {
      emit(state.copyWith(
          status: UpdateEvidenceStatus.error,
          error: Wrapped.value(e.toString())));
    }
  }

  fileUpdated(UploadModel? file) {
    emit(state.copyWith(applicantEvidence: Wrapped.value(file)));
  }

  submit() async {
    emit(state.copyWith(status: UpdateEvidenceStatus.submitting));
    try {
      await profileService.updateEvidence(
          requiredEvidenceId, state.applicantEvidence?.id);
      emit(state.copyWith(status: UpdateEvidenceStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: UpdateEvidenceStatus.loaded,
        error: Wrapped.value(e.toString()),
      ));
    }
  }
}
