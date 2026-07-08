import 'package:equatable/equatable.dart';
import 'package:yedi_app/modules/sign_up/services/sign_up_service.dart';
import 'package:yedi_app/ui/inputs/dropdown_input.dart';
import 'package:yedi_app/util/data_types.dart';
import 'package:yedi_app/util/dates.dart';
import 'package:yedi_app/util/models.dart';

enum CreateProfileStatus {
  loading,
  waitingForSubmit,
  submitting,
  success,
  error
}

class CreateProfileState implements Equatable {
  final List<Value<String>> titles;
  final List<Value<int>> jobRoles;
  final List<Value<int>> typesOfWork;
  final int? jobRole;
  final int? typeOfWork;

  final String? title;
  final String firstName;
  final String lastName;
  final DateTime? dateOfBirth;
  final String telephone;
  final String email;
  final String password;
  final String passwordConfirmation;

  final String advertiserName;
  final String advertiserTelephone;
  final String advertiserEmail;
  final String advertiserBio;
  final String advertiserAdditionalInfo;

  final CreateProfileStatus status;
  final Map<String, String> errors;
  final String? error;

  final CreateProfileResponse? successResponse;

  CreateProfileState({
    this.titles = const [],
    this.jobRoles = const [],
    this.typesOfWork = const [],
    this.jobRole,
    this.typeOfWork,
    this.title,
    this.firstName = '',
    this.lastName = '',
    this.dateOfBirth,
    this.telephone = '',
    this.email = '',
    this.password = '',
    this.passwordConfirmation = '',
    this.advertiserName = '',
    this.advertiserTelephone = '',
    this.advertiserEmail = '',
    this.advertiserBio = '',
    this.advertiserAdditionalInfo = '',
    this.status = CreateProfileStatus.loading,
    this.error,
    this.errors = const {},
    this.successResponse,
  });

  CreateProfileState copyWith({
    List<Value<String>>? titles,
    List<Value<int>>? jobRoles,
    List<Value<int>>? typesOfWork,
    Wrapped<int?>? jobRole,
    Wrapped<int?>? typeOfWork,
    Wrapped<String?>? title,
    String? firstName,
    String? lastName,
    Wrapped<DateTime?>? dateOfBirth,
    String? telephone,
    String? email,
    String? password,
    String? passwordConfirmation,
    String? advertiserName,
    String? advertiserTelephone,
    String? advertiserEmail,
    String? advertiserBio,
    String? advertiserAdditionalInfo,
    CreateProfileStatus? status,
    Wrapped<String?>? error,
    Map<String, String>? errors,
    Wrapped<CreateProfileResponse?>? successResponse,
  }) {
    return CreateProfileState(
      titles: titles ?? this.titles,
      jobRoles: jobRoles ?? this.jobRoles,
      typesOfWork: typesOfWork ?? this.typesOfWork,
      jobRole: jobRole is Wrapped ? jobRole!.value : this.jobRole,
      typeOfWork: typeOfWork is Wrapped ? typeOfWork!.value : this.typeOfWork,
      title: title is Wrapped ? title!.value : this.title,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth:
          dateOfBirth is Wrapped ? dateOfBirth!.value : this.dateOfBirth,
      telephone: telephone ?? this.telephone,
      email: email ?? this.email,
      password: password ?? this.password,
      passwordConfirmation: passwordConfirmation ?? this.passwordConfirmation,
      advertiserName: advertiserName ?? this.advertiserName,
      advertiserTelephone: advertiserTelephone ?? this.advertiserTelephone,
      advertiserEmail: advertiserEmail ?? this.advertiserEmail,
      advertiserBio: advertiserBio ?? this.advertiserBio,
      advertiserAdditionalInfo:
          advertiserAdditionalInfo ?? this.advertiserAdditionalInfo,
      status: status ?? this.status,
      error: error is Wrapped ? error!.value : this.error,
      errors: errors ?? this.errors,
      successResponse: successResponse is Wrapped
          ? successResponse!.value
          : this.successResponse,
    );
  }

  Map<String, dynamic> get payload => {
        'title': title,
        'first_name': firstName,
        'last_name': lastName,
        'date_of_birth': dateOfBirth?.formatDate(format: "yyyy-MM-dd"),
        'telephone': telephone,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'job_role_id': jobRole,
        'type_of_work_id': typeOfWork,
        'advertiser': {
          "name": advertiserName,
          "telephone": advertiserTelephone,
          "email": advertiserEmail,
          "bio": advertiserBio,
          "additional_info": advertiserAdditionalInfo,
        }
      };
  bool get isSubmitting => status == CreateProfileStatus.submitting;

  Value<String>? get selectedTitle =>
      titles.where((element) => element.value == title).firstOrNull;

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
        titles,
        jobRoles,
        typesOfWork,
        jobRole,
        typeOfWork,
        title,
        firstName,
        lastName,
        dateOfBirth,
        telephone,
        email,
        password,
        passwordConfirmation,
        advertiserName,
        advertiserTelephone,
        advertiserEmail,
        advertiserBio,
        advertiserAdditionalInfo,
        status,
        error,
        errors,
        successResponse
      ];

  @override
  bool? get stringify => false;
}
