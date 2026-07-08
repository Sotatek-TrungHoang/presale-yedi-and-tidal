import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/api/api_exceptions.dart';
import 'package:yedi_app/modules/authentication/models/auth_user_model.dart';
import 'package:yedi_app/modules/common/cubits/generic_form_state.dart';
import 'package:yedi_app/modules/common/models/upload_model.dart';
import 'package:yedi_app/modules/profile/service/profile_service.dart';
import 'package:yedi_app/util/models.dart';

class UpdateApplicantComplianceState extends GenericFormState
    implements Equatable {
  final UploadModel? photograph;
  final UploadModel? evidenceOfId;

  UpdateApplicantComplianceState({
    super.status = FormStatus.idle,
    super.error,
    super.errors = const {},
    super.data = const {},
    this.photograph,
    this.evidenceOfId,
  });

  UpdateApplicantComplianceState copyWith({
    Wrapped<UploadModel?>? photograph,
    Wrapped<UploadModel?>? evidenceOfId,
    FormStatus? status,
    Map<String, String>? errors,
    Wrapped<String?>? error,
  }) {
    return UpdateApplicantComplianceState(
      status: status ?? this.status,
      data: data,
      photograph: photograph is Wrapped ? photograph!.value : this.photograph,
      evidenceOfId:
          evidenceOfId is Wrapped ? evidenceOfId!.value : this.evidenceOfId,
      errors: errors ?? this.errors,
      error: error is Wrapped ? error!.value : this.error,
    );
  }

  @override
  List<Object?> get props => [
        status,
        data,
        photograph,
        evidenceOfId,
        errors,
        error,
      ];

  @override
  bool? get stringify => true;
}

class UpdateApplicantComplianceCubit
    extends Cubit<UpdateApplicantComplianceState> {
  final ProfileService profileService;

  UpdateApplicantComplianceCubit(
      {required this.profileService, required AuthUserModel user})
      : super(UpdateApplicantComplianceState(
          photograph: user.applicant?.photograph,
          evidenceOfId: user.applicant?.evidenceOfId,
        ));

  photographUpdated(UploadModel? photograph) {
    emit(state.copyWith(photograph: Wrapped.value(photograph)));
  }

  evidenceOfIdUpdated(UploadModel? evidenceOfId) {
    emit(state.copyWith(evidenceOfId: Wrapped.value(evidenceOfId)));
  }

  submit() async {
    emit(state.copyWith(status: FormStatus.submitting));
    try {
      final payload = {
        "photograph_id": state.photograph?.id,
        "evidence_of_id_id": state.evidenceOfId?.id,
      };

      await profileService.updateCompliance(payload);
      emit(state.copyWith(status: FormStatus.success));
    } on APIValidationException catch (e) {
      emit(state.copyWith(
        status: FormStatus.idle,
        errors: e.errors,
      ));
    } on APIException catch (e) {
      emit(state.copyWith(
        status: FormStatus.idle,
        error: Wrapped.value(e.message ?? "An error occurred"),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FormStatus.idle,
        error: Wrapped.value(e.toString()),
      ));
    }
  }
}
