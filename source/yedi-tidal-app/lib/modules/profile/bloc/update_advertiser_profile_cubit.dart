import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/api/api_exceptions.dart';
import 'package:yedi_app/modules/authentication/models/auth_user_model.dart';
import 'package:yedi_app/modules/common/cubits/generic_form_state.dart';
import 'package:yedi_app/modules/common/models/upload_model.dart';
import 'package:yedi_app/modules/common/services/dropdown_service.dart';
import 'package:yedi_app/modules/profile/service/profile_service.dart';
import 'package:yedi_app/util/models.dart';

class UpdateAdvertiserProfileState extends GenericFormState
    implements Equatable {
  final UploadModel? photograph;

  UpdateAdvertiserProfileState(
      {required super.status,
      required super.data,
      required super.errors,
      required super.error,
      this.photograph});

  factory UpdateAdvertiserProfileState.initial() {
    return UpdateAdvertiserProfileState(
      status: FormStatus.loading,
      data: {
        "name": "",
        "email": "",
        "telephone": "",
        "bio": "",
        "additional_info": "",
        "photograph_id": null
      },
      errors: {},
      error: null,
    );
  }

  UpdateAdvertiserProfileState copyWith({
    FormStatus? status,
    Map<String, dynamic>? data,
    Map<String, String>? errors,
    Wrapped<String?>? error,
    Wrapped<UploadModel?>? photograph,
  }) {
    return UpdateAdvertiserProfileState(
      status: status ?? this.status,
      data: data ?? this.data,
      photograph: photograph is Wrapped ? photograph!.value : this.photograph,
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
        photograph,
      ];

  @override
  bool? get stringify => true;
}

class UpdateAdvertiserProfileCubit extends Cubit<UpdateAdvertiserProfileState> {
  final DropdownService dropdownService;
  final ProfileService profileService;

  UpdateAdvertiserProfileCubit(
      {required this.dropdownService,
      required this.profileService,
      required AuthUserAdvertiserModel advertiser})
      : super(UpdateAdvertiserProfileState(
            status: FormStatus.idle,
            photograph: advertiser.photograph,
            data: {
              "name": advertiser.name,
              "email": advertiser.email,
              "telephone": advertiser.telephone,
              "bio": advertiser.bio,
              "additional_info": advertiser.additionalInfo,
              "photograph_id": advertiser.photograph?.id
            },
            errors: {},
            error: null));

  fieldUpdated(String field, dynamic value) {
    emit(state.copyWith(
      data: {
        ...state.data,
        field: value,
      },
    ));
  }

  photographUpdated(UploadModel? photograph) {
    emit(state.copyWith(
      photograph: Wrapped.value(photograph),
      data: {
        ...state.data,
        "photograph_id": photograph?.id,
      },
    ));
  }

  submit() async {
    emit(state.copyWith(status: FormStatus.submitting));
    try {
      await profileService.updateProfile(state.data);
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
