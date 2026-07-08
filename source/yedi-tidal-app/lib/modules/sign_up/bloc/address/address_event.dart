import 'package:yedi_app/modules/authentication/models/auth_user_model.dart';

sealed class AddressEvent {}

class AddressInitialised extends AddressEvent {
  final AuthUserModel? user;
  AddressInitialised(this.user);
}

class AddressLine1Changed extends AddressEvent {
  final String value;
  AddressLine1Changed(this.value);
}

class AddressLine2Changed extends AddressEvent {
  final String value;
  AddressLine2Changed(this.value);
}

class AddressTownCityChanged extends AddressEvent {
  final String value;
  AddressTownCityChanged(this.value);
}

class AddressPostcodeChanged extends AddressEvent {
  final String value;
  AddressPostcodeChanged(this.value);
}

class AddressCountryChanged extends AddressEvent {
  final String? value;
  AddressCountryChanged(this.value);
}

class AddressSubmitted extends AddressEvent {}
