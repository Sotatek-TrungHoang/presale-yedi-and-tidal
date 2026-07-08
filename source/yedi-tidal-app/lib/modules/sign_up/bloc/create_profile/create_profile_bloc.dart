import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/api/api_exceptions.dart';
import 'package:yedi_app/modules/authentication/models/auth_user_model.dart';
import 'package:yedi_app/modules/common/services/dropdown_service.dart';
import 'package:yedi_app/modules/sign_up/bloc/create_profile/create_profile_event.dart';
import 'package:yedi_app/modules/sign_up/bloc/create_profile/create_profile_state.dart';
import 'package:yedi_app/modules/sign_up/services/sign_up_service.dart';
import 'package:yedi_app/util/data_types.dart';
import 'package:yedi_app/util/models.dart';

class CreateProfileBloc extends Bloc<CreateProfileEvent, CreateProfileState> {
  final SignUpService signUpService;
  final DropdownService dropdownService;
  final UserType userType;

  CreateProfileBloc(
      {required this.signUpService,
      required this.dropdownService,
      required this.userType})
      : super(CreateProfileState()) {
    on<CreateProfileInitialised>(_onCreateProfileInitialised);
    on<CreateProfileJobRoleChanged>(_onCreateProfileJobRoleChanged);
    on<CreateProfileTypeOfWorkChanged>(_onCreateProfileTypeOfWorkChanged);
    on<CreateProfileTitleChanged>(_onCreateProfileTitleChanged);
    on<CreateProfileFirstNameChanged>(_onCreateProfileFirstNameChanged);
    on<CreateProfileLastNameChanged>(_onCreateProfileLastNameChanged);
    on<CreateProfileDateOfBirthChanged>(_onCreateProfileDateOfBirthChanged);
    on<CreateProfileTelephoneChanged>(_onCreateProfileTelephoneChanged);
    on<CreateProfileEmailChanged>(_onCreateProfileEmailChanged);
    on<CreateProfilePasswordChanged>(_onCreateProfilePasswordChanged);
    on<CreateProfilePasswordConfirmationChanged>(
        _onCreateProfilePasswordConfirmationChanged);
    on<CreateProfileAdvertiserNameChanged>(
        _onCreateProfileAdvertiserNameChanged);
    on<CreateProfileAdvertiserTelephoneChanged>(
        _onCreateProfileAdvertiserTelephoneChanged);
    on<CreateProfileAdvertiserEmailChanged>(
        _onCreateProfileAdvertiserEmailChanged);
    on<CreateProfileAdvertiserBioChanged>(_onCreateProfileAdvertiserBioChanged);
    on<CreateProfileAdvertiserAdditionalInfoChanged>(
        _onCreateProfileAdvertiserAdditionalInfoChanged);
    on<CreateProfileSubmitted>(_onCreateProfileSubmitted);
  }

  _onCreateProfileInitialised(
      CreateProfileInitialised event, Emitter<CreateProfileState> emit) async {
    try {
      final titles = await dropdownService.userTitles();
      final List<Value<int>> jobRoles = userType == UserType.applicant
          ? await dropdownService.jobRoles()
          : [];
      final List<Value<int>> typesOfWork = userType == UserType.applicant
          ? await dropdownService.typesOfWork()
          : [];

      emit(state.copyWith(
        status: CreateProfileStatus.waitingForSubmit,
        titles: titles,
        jobRoles: jobRoles,
        typesOfWork: typesOfWork,
        jobRole: Wrapped.value(jobRoles
            .where((jobRole) =>
                jobRole.value == event.user?.applicant?.jobRole?.id)
            .firstOrNull
            ?.value),
        typeOfWork: Wrapped.value(typesOfWork
            .where((typeOfWork) =>
                typeOfWork.value == event.user?.applicant?.typeOfWork?.id)
            .firstOrNull
            ?.value),
        title: Wrapped.value(titles
            .where((title) => title.value == event.user?.title)
            .firstOrNull
            ?.value),
        firstName: event.user?.firstName ?? '',
        lastName: event.user?.lastName ?? '',
        dateOfBirth: Wrapped.value(event.user?.dateOfBirth),
        telephone: event.user?.telephone ?? '',
        email: event.user?.email ?? '',
        password: '',
        passwordConfirmation: '',
        advertiserName: event.user?.advertiser?.name ?? '',
        advertiserTelephone: event.user?.advertiser?.telephone ?? '',
        advertiserEmail: event.user?.advertiser?.email ?? '',
        advertiserBio: event.user?.advertiser?.bio ?? '',
        advertiserAdditionalInfo: event.user?.advertiser?.additionalInfo ?? '',
      ));
    } on APIException catch (e) {
      emit(state.copyWith(
          status: CreateProfileStatus.error,
          error: Wrapped.value(e.message ?? e.toString())));
    } catch (e) {
      emit(state.copyWith(
          status: CreateProfileStatus.error,
          error: Wrapped.value(e.toString())));
    }
  }

  _onCreateProfileJobRoleChanged(CreateProfileJobRoleChanged event,
      Emitter<CreateProfileState> emit) async {
    emit(state.copyWith(
      jobRole: Wrapped.value(event.value),
    ));
  }

  _onCreateProfileTypeOfWorkChanged(CreateProfileTypeOfWorkChanged event,
      Emitter<CreateProfileState> emit) async {
    emit(state.copyWith(
      typeOfWork: Wrapped.value(event.value),
    ));
  }

  _onCreateProfileTitleChanged(
      CreateProfileTitleChanged event, Emitter<CreateProfileState> emit) async {
    emit(state.copyWith(title: Wrapped.value(event.value)));
  }

  _onCreateProfileFirstNameChanged(CreateProfileFirstNameChanged event,
      Emitter<CreateProfileState> emit) async {
    emit(state.copyWith(firstName: event.value));
  }

  _onCreateProfileLastNameChanged(CreateProfileLastNameChanged event,
      Emitter<CreateProfileState> emit) async {
    emit(state.copyWith(lastName: event.value));
  }

  _onCreateProfileDateOfBirthChanged(CreateProfileDateOfBirthChanged event,
      Emitter<CreateProfileState> emit) async {
    emit(state.copyWith(dateOfBirth: Wrapped.value(event.value)));
  }

  _onCreateProfileTelephoneChanged(CreateProfileTelephoneChanged event,
      Emitter<CreateProfileState> emit) async {
    emit(state.copyWith(telephone: event.value));
  }

  _onCreateProfileEmailChanged(
      CreateProfileEmailChanged event, Emitter<CreateProfileState> emit) async {
    emit(state.copyWith(email: event.value));
  }

  _onCreateProfilePasswordChanged(CreateProfilePasswordChanged event,
      Emitter<CreateProfileState> emit) async {
    emit(state.copyWith(password: event.value));
  }

  _onCreateProfilePasswordConfirmationChanged(
      CreateProfilePasswordConfirmationChanged event,
      Emitter<CreateProfileState> emit) async {
    emit(state.copyWith(passwordConfirmation: event.value));
  }

  _onCreateProfileAdvertiserNameChanged(
      CreateProfileAdvertiserNameChanged event,
      Emitter<CreateProfileState> emit) async {
    emit(state.copyWith(advertiserName: event.value));
  }

  _onCreateProfileAdvertiserTelephoneChanged(
      CreateProfileAdvertiserTelephoneChanged event,
      Emitter<CreateProfileState> emit) async {
    emit(state.copyWith(advertiserTelephone: event.value));
  }

  _onCreateProfileAdvertiserEmailChanged(
      CreateProfileAdvertiserEmailChanged event,
      Emitter<CreateProfileState> emit) async {
    emit(state.copyWith(advertiserEmail: event.value));
  }

  _onCreateProfileAdvertiserBioChanged(CreateProfileAdvertiserBioChanged event,
      Emitter<CreateProfileState> emit) async {
    emit(state.copyWith(advertiserBio: event.value));
  }

  _onCreateProfileAdvertiserAdditionalInfoChanged(
      CreateProfileAdvertiserAdditionalInfoChanged event,
      Emitter<CreateProfileState> emit) async {
    emit(state.copyWith(advertiserAdditionalInfo: event.value));
  }

  _onCreateProfileSubmitted(
      CreateProfileSubmitted event, Emitter<CreateProfileState> emit) async {
    emit(state.copyWith(
        status: CreateProfileStatus.submitting,
        errors: {},
        error: Wrapped.value(null),
        successResponse: Wrapped.value(null)));

    try {
      final payload = state.payload;
      final response = userType == UserType.applicant
          ? await signUpService.createApplicantProfile(payload)
          : await signUpService.createAdvertiserProfile(payload);

      emit(state.copyWith(
          status: CreateProfileStatus.success,
          successResponse: Wrapped.value(response),
          error: Wrapped.value(null)));
    } on APIValidationException catch (e) {
      emit(state.copyWith(
          status: CreateProfileStatus.waitingForSubmit,
          errors: e.errors,
          error: Wrapped.value(e.message ?? e.toString())));
    } on APIException catch (e) {
      emit(state.copyWith(
          status: CreateProfileStatus.waitingForSubmit,
          error: Wrapped.value(e.message ?? e.toString())));
    } catch (e) {
      emit(state.copyWith(
          status: CreateProfileStatus.waitingForSubmit,
          error: Wrapped.value(e.toString())));
    }
  }
}
