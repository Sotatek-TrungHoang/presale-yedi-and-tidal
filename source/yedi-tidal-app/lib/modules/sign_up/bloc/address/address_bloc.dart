import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/api/api_exceptions.dart';
import 'package:yedi_app/modules/authentication/models/auth_user_model.dart';
import 'package:yedi_app/modules/common/services/dropdown_service.dart';
import 'package:yedi_app/modules/sign_up/bloc/address/address_event.dart';
import 'package:yedi_app/modules/sign_up/bloc/address/address_state.dart';
import 'package:yedi_app/modules/sign_up/services/sign_up_service.dart';
import 'package:yedi_app/util/models.dart';

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  final SignUpService signUpService;
  final DropdownService dropdownService;
  final UserType userType;

  AddressBloc(
      {required this.signUpService,
      required this.dropdownService,
      required this.userType})
      : super(AddressState()) {
    on<AddressInitialised>(_onAddressInitialised);
    on<AddressLine1Changed>(_onAddressLine1Changed);
    on<AddressLine2Changed>(_onAddressLine2Changed);
    on<AddressTownCityChanged>(_onAddressTownCityChanged);
    on<AddressPostcodeChanged>(_onAddressPostcodeChanged);
    on<AddressCountryChanged>(_onAddressCountryChanged);
    on<AddressSubmitted>(_onAddressSubmitted);
  }

  _onAddressInitialised(
      AddressInitialised event, Emitter<AddressState> emit) async {
    try {
      final countries = await dropdownService.countries();
      emit(state.copyWith(
        status: AddressStatus.waitingForSubmit,
        countries: countries,
        country: Wrapped.value(countries
            .where((title) =>
                title.value ==
                (event.user?.applicant?.address?.country ??
                    event.user?.advertiser?.address?.country))
            .firstOrNull
            ?.value),
        line1: event.user?.applicant?.address?.line1 ??
            event.user?.advertiser?.address?.line1 ??
            '',
        line2: event.user?.applicant?.address?.line2 ??
            event.user?.advertiser?.address?.line2 ??
            '',
        townCity: event.user?.applicant?.address?.townCity ??
            event.user?.advertiser?.address?.townCity ??
            '',
        postcode: event.user?.applicant?.address?.postcode ??
            event.user?.advertiser?.address?.postcode ??
            '',
      ));
    } on APIException catch (e) {
      emit(state.copyWith(
          status: AddressStatus.error,
          error: Wrapped.value(e.message ?? e.toString())));
    } catch (e) {
      emit(state.copyWith(
          status: AddressStatus.error, error: Wrapped.value(e.toString())));
    }
  }

  _onAddressLine1Changed(
      AddressLine1Changed event, Emitter<AddressState> emit) async {
    emit(state.copyWith(
      line1: event.value,
    ));
  }

  _onAddressLine2Changed(
      AddressLine2Changed event, Emitter<AddressState> emit) async {
    emit(state.copyWith(
      line2: event.value,
    ));
  }

  _onAddressTownCityChanged(
      AddressTownCityChanged event, Emitter<AddressState> emit) async {
    emit(state.copyWith(
      townCity: event.value,
    ));
  }

  _onAddressPostcodeChanged(
      AddressPostcodeChanged event, Emitter<AddressState> emit) async {
    emit(state.copyWith(
      postcode: event.value,
    ));
  }

  _onAddressCountryChanged(
      AddressCountryChanged event, Emitter<AddressState> emit) async {
    emit(state.copyWith(
      country: Wrapped.value(event.value),
    ));
  }

  _onAddressSubmitted(
      AddressSubmitted event, Emitter<AddressState> emit) async {
    emit(state.copyWith(
        status: AddressStatus.submitting,
        errors: {},
        error: Wrapped.value(null),
        updatedUser: Wrapped.value(null)));

    try {
      final payload = state.payload;
      final response = userType == UserType.applicant
          ? await signUpService.submitApplicantAddress(payload)
          : await signUpService.submitAdvertiserAddress(payload);

      emit(state.copyWith(
          status: AddressStatus.success,
          updatedUser: Wrapped.value(response),
          error: Wrapped.value(null)));
    } on APIValidationException catch (e) {
      emit(state.copyWith(
          status: AddressStatus.waitingForSubmit,
          errors: e.errors,
          error: Wrapped.value(e.message ?? e.toString())));
    } on APIException catch (e) {
      emit(state.copyWith(
          status: AddressStatus.waitingForSubmit,
          error: Wrapped.value(e.message ?? e.toString())));
    } catch (e) {
      emit(state.copyWith(
          status: AddressStatus.waitingForSubmit,
          error: Wrapped.value(e.toString())));
    }
  }
}
