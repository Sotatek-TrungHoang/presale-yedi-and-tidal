import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/api/api_exceptions.dart';
import 'package:yedi_app/modules/authentication/models/auth_user_model.dart';
import 'package:yedi_app/modules/common/cubits/generic_form_state.dart';
import 'package:yedi_app/modules/common/services/dropdown_service.dart';
import 'package:yedi_app/modules/profile/service/profile_service.dart';
import 'package:yedi_app/ui/inputs/dropdown_input.dart';
import 'package:yedi_app/util/data_types.dart';
import 'package:yedi_app/util/dates.dart';
import 'package:yedi_app/util/models.dart';

class UpdateApplicantProfileState extends GenericFormState
    implements Equatable {
  final List<Value<String>> titles;
  final List<Value<int>> jobRoles;
  final List<Value<int>> typesOfWork;
  final DateTime? dateOfBirth;

  UpdateApplicantProfileState({
    required super.status,
    required super.data,
    required super.errors,
    required super.error,
    required this.titles,
    required this.jobRoles,
    required this.typesOfWork,
    this.dateOfBirth,
  });

  factory UpdateApplicantProfileState.initial() {
    return UpdateApplicantProfileState(
      status: FormStatus.loading,
      data: {
        "first_name": "",
        "last_name": "",
        "telephone": "",
      },
      titles: [],
      jobRoles: [],
      typesOfWork: [],
      dateOfBirth: null,
      errors: {},
      error: null,
    );
  }

  UpdateApplicantProfileState copyWith({
    FormStatus? status,
    Map<String, dynamic>? data,
    List<Value<String>>? titles,
    List<Value<int>>? jobRoles,
    List<Value<int>>? typesOfWork,
    Wrapped<DateTime?>? dateOfBirth,
    Map<String, String>? errors,
    Wrapped<String?>? error,
  }) {
    return UpdateApplicantProfileState(
      status: status ?? this.status,
      data: data ?? this.data,
      titles: titles ?? this.titles,
      jobRoles: jobRoles ?? this.jobRoles,
      typesOfWork: typesOfWork ?? this.typesOfWork,
      dateOfBirth:
          dateOfBirth is Wrapped ? dateOfBirth!.value : this.dateOfBirth,
      errors: errors ?? this.errors,
      error: error is Wrapped ? error!.value : this.error,
    );
  }

  List<DropdownOption<String>> get titleItems => titles
      .map((e) => DropdownOption<String>(
            e.value,
            e.label,
          ))
      .toList();

  List<DropdownOption<int>> get jobRoleItems => jobRoles
      .map((e) => DropdownOption<int>(
            e.value,
            e.label,
          ))
      .toList();

  List<DropdownOption<int>> get typeOfWorkItems => typesOfWork
      .map((e) => DropdownOption<int>(
            e.value,
            e.label,
          ))
      .toList();

  @override
  List<Object?> get props => [
        status,
        data,
        titles,
        jobRoles,
        typesOfWork,
        dateOfBirth,
        errors,
        error,
      ];

  @override
  bool? get stringify => true;
}

class UpdateApplicantProfileCubit extends Cubit<UpdateApplicantProfileState> {
  final DropdownService dropdownService;
  final ProfileService profileService;

  UpdateApplicantProfileCubit(
      {required this.dropdownService,
      required this.profileService,
      required AuthUserModel user})
      : super(UpdateApplicantProfileState(
            status: FormStatus.loading,
            data: {
              'title': user.title,
              'first_name': user.firstName,
              'last_name': user.lastName,
              'telephone': user.telephone,
              'job_role_id': user.applicant?.jobRole?.id,
              'type_of_work_id': user.applicant?.typeOfWork?.id,
            },
            dateOfBirth: user.dateOfBirth,
            titles: [],
            jobRoles: [],
            typesOfWork: [],
            errors: {},
            error: null));

  init() async {
    try {
      final titles = await dropdownService.userTitles();
      final jobRoles = await dropdownService.jobRoles();
      final typesOfWork = await dropdownService.typesOfWork();

      emit(state.copyWith(
          status: FormStatus.idle,
          titles: titles,
          jobRoles: jobRoles,
          typesOfWork: typesOfWork,
          data: {
            ...state.data,
            'title': titles
                .where((title) => title.value == state.data['title'] as String?)
                .firstOrNull
                ?.value,
            'job_role_id': jobRoles
                .where((jobRole) =>
                    jobRole.value == state.data['job_role_id'] as int?)
                .firstOrNull
                ?.value,
            'type_of_work_id': typesOfWork
                .where((typeOfWork) =>
                    typeOfWork.value == state.data['type_of_work_id'] as int?)
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

  dateOfBirthUpdated(DateTime? dateOfBirth) {
    emit(state.copyWith(dateOfBirth: Wrapped.value(dateOfBirth)));
  }

  submit() async {
    emit(state.copyWith(status: FormStatus.submitting));
    try {
      final payload = {
        ...state.data,
        'date_of_birth': state.dateOfBirth?.formatDateDB(),
      };

      await profileService.updateProfile(payload);
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
