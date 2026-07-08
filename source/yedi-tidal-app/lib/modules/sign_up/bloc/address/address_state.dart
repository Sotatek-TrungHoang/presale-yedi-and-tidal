import 'package:equatable/equatable.dart';
import 'package:yedi_app/modules/authentication/models/auth_user_model.dart';
import 'package:yedi_app/ui/inputs/dropdown_input.dart';
import 'package:yedi_app/util/data_types.dart';
import 'package:yedi_app/util/models.dart';

enum AddressStatus { loading, waitingForSubmit, submitting, success, error }

class AddressState implements Equatable {
  final List<Value<String>> countries;
  final String? country;
  final String line1;
  final String line2;
  final String townCity;
  final String postcode;

  final AddressStatus status;
  final Map<String, String> errors;
  final String? error;

  final AuthUserModel? updatedUser;

  AddressState({
    this.countries = const [],
    this.country,
    this.line1 = '',
    this.line2 = '',
    this.townCity = '',
    this.postcode = '',
    this.status = AddressStatus.loading,
    this.error,
    this.errors = const {},
    this.updatedUser,
  });

  AddressState copyWith({
    List<Value<String>>? countries,
    Wrapped<String?>? country,
    String? line1,
    String? line2,
    String? townCity,
    String? postcode,
    AddressStatus? status,
    Wrapped<String?>? error,
    Map<String, String>? errors,
    Wrapped<AuthUserModel?>? updatedUser,
  }) {
    return AddressState(
      countries: countries ?? this.countries,
      country: country is Wrapped ? country!.value : this.country,
      line1: line1 ?? this.line1,
      line2: line2 ?? this.line2,
      townCity: townCity ?? this.townCity,
      postcode: postcode ?? this.postcode,
      status: status ?? this.status,
      error: error is Wrapped ? error!.value : this.error,
      errors: errors ?? this.errors,
      updatedUser:
          updatedUser is Wrapped ? updatedUser!.value : this.updatedUser,
    );
  }

  Map<String, dynamic> get payload => {
        'line_1': line1,
        'line_2': line2,
        'town_city': townCity,
        'postcode': postcode,
        'country': country,
      };

  bool get isSubmitting => status == AddressStatus.submitting;

  List<DropdownOption<String>> get countryItems => countries
      .map((e) => DropdownOption<String>(
            e.value,
            e.label,
          ))
      .toList();

  @override
  List<Object?> get props => [
        countries,
        country,
        line1,
        line2,
        townCity,
        postcode,
        status,
        error,
        errors,
        updatedUser,
      ];

  @override
  bool? get stringify => false;
}
