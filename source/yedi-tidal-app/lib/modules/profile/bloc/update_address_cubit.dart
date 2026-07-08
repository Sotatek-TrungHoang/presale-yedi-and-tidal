import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/api/api_exceptions.dart';
import 'package:yedi_app/modules/authentication/models/auth_user_model.dart';
import 'package:yedi_app/modules/common/cubits/generic_form_state.dart';
import 'package:yedi_app/modules/common/models/address_model.dart';
import 'package:yedi_app/modules/common/services/dropdown_service.dart';
import 'package:yedi_app/modules/profile/service/profile_service.dart';
import 'package:yedi_app/ui/inputs/dropdown_input.dart';
import 'package:yedi_app/util/data_types.dart';
import 'package:yedi_app/util/models.dart';

class UpdateAddressState extends GenericFormState implements Equatable {
  final List<Value<String>> countries;

  UpdateAddressState(
      {required super.status,
      required super.data,
      required super.errors,
      required super.error,
      required this.countries});

  factory UpdateAddressState.initial() {
    return UpdateAddressState(
      status: FormStatus.loading,
      data: {
        "line_1": "",
        "line_2": "",
        "town_city": "",
        "postcode": "",
        "country": "",
      },
      errors: {},
      error: null,
      countries: [],
    );
  }

  UpdateAddressState copyWith({
    FormStatus? status,
    Map<String, dynamic>? data,
    Map<String, String>? errors,
    Wrapped<String?>? error,
    List<Value<String>>? countries,
  }) {
    return UpdateAddressState(
      status: status ?? this.status,
      data: data ?? this.data,
      errors: errors ?? this.errors,
      error: error is Wrapped ? error!.value : this.error,
      countries: countries ?? this.countries,
    );
  }

  List<DropdownOption<String>> get countryItems => countries
      .map((e) => DropdownOption<String>(
            e.value,
            e.label,
          ))
      .toList();

  @override
  List<Object?> get props => [
        status,
        data,
        errors,
        error,
        countries,
      ];

  @override
  bool? get stringify => true;
}

class UpdateAddressCubit extends Cubit<UpdateAddressState> {
  final DropdownService dropdownService;
  final ProfileService profileService;
  final UserType userType;

  UpdateAddressCubit(
      {required this.dropdownService,
      required this.userType,
      required this.profileService})
      : super(UpdateAddressState.initial());

  init(AddressModel? address) async {
    try {
      final countries = await dropdownService.countries();
      emit(state.copyWith(
        status: FormStatus.idle,
        countries: countries,
        data: {
          "line_1": address?.line1 ?? "",
          "line_2": address?.line2 ?? "",
          "town_city": address?.townCity ?? "",
          "postcode": address?.postcode ?? "",
          "country": address?.country ?? "",
        },
      ));
    } on APIException catch (e) {
      emit(state.copyWith(
        status: FormStatus.error,
        error: Wrapped.value(e.toString()),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FormStatus.error,
        error: Wrapped.value(e.toString()),
      ));
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
      await profileService.updateAddress(state.data);
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
