import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/api/api_exceptions.dart';
import 'package:yedi_app/modules/authentication/models/auth_user_model.dart';
import 'package:yedi_app/modules/common/cubits/generic_form_state.dart';
import 'package:yedi_app/modules/common/models/settings_model.dart';
import 'package:yedi_app/modules/common/services/dropdown_service.dart';
import 'package:yedi_app/modules/common/services/settings_service.dart';
import 'package:yedi_app/modules/profile/service/profile_service.dart';
import 'package:yedi_app/ui/inputs/dropdown_input.dart';
import 'package:yedi_app/util/data_types.dart';
import 'package:yedi_app/util/models.dart';

class UpdateApplicantQualificationsState extends GenericFormState
    implements Equatable {
  final List<Value<String>> qualifications;
  final SettingsModel? settings;

  UpdateApplicantQualificationsState({
    required super.status,
    required super.data,
    required super.errors,
    required super.error,
    required this.qualifications,
    required this.settings,
  });

  factory UpdateApplicantQualificationsState.initial() {
    return UpdateApplicantQualificationsState(
      status: FormStatus.loading,
      data: {
        "qualification": "",
        "teacher_number": "",
      },
      qualifications: [],
      settings: null,
      errors: {},
      error: null,
    );
  }

  UpdateApplicantQualificationsState copyWith({
    FormStatus? status,
    Map<String, dynamic>? data,
    List<Value<String>>? qualifications,
    SettingsModel? settings,
    Map<String, String>? errors,
    Wrapped<String?>? error,
  }) {
    return UpdateApplicantQualificationsState(
      status: status ?? this.status,
      data: data ?? this.data,
      qualifications: qualifications ?? this.qualifications,
      settings: settings ?? this.settings,
      errors: errors ?? this.errors,
      error: error is Wrapped ? error!.value : this.error,
    );
  }

  List<DropdownOption<String>> get qualificationItems => qualifications
      .map((e) => DropdownOption<String>(
            e.value,
            e.label,
          ))
      .toList();

  @override
  List<Object?> get props => [
        status,
        data,
        qualifications,
        settings,
        errors,
        error,
      ];

  @override
  bool? get stringify => true;
}

class UpdateApplicantQualificationsCubit
    extends Cubit<UpdateApplicantQualificationsState> {
  final DropdownService dropdownService;
  final SettingsService settingsService;
  final ProfileService profileService;

  UpdateApplicantQualificationsCubit(
      {required this.dropdownService,
      required this.settingsService,
      required this.profileService,
      required AuthUserModel user})
      : super(UpdateApplicantQualificationsState(
            status: FormStatus.loading,
            data: {
              'qualification': user.applicant?.qualification,
              'teacher_number': user.applicant?.teacherNumber,
            },
            settings: null,
            qualifications: [],
            errors: {},
            error: null));

  init() async {
    try {
      final qualifications = await dropdownService.qualifications();
      final settings = await settingsService.getSettings();
      emit(state.copyWith(
          status: FormStatus.idle,
          qualifications: qualifications,
          settings: settings,
          data: {
            ...state.data,
            'qualification': qualifications
                .where((title) =>
                    title.value == state.data['qualification'] as String?)
                .firstOrNull
                ?.value,
          }));
    } catch (e) {
      String message =
          e is APIException ? e.message ?? "An error occurred" : e.toString();
      emit(state.copyWith(
          status: FormStatus.error, error: Wrapped.value(message)));
    }
  }

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
      await profileService.updateQualifications(state.data);
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
