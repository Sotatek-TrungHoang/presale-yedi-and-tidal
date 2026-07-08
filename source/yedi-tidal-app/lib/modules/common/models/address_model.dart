import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddressModel {
  final int id;
  final String formatted;
  final String line1;
  final String? line2;
  final String townCity;
  final String country;
  final String countryLabel;
  final String postcode;
  final double? latitude;
  final double? longitude;

  AddressModel({
    required this.id,
    required this.formatted,
    required this.line1,
    this.line2,
    required this.townCity,
    required this.country,
    required this.countryLabel,
    required this.postcode,
    this.latitude,
    this.longitude,
  });

  AddressModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        formatted = json['formatted'],
        line1 = json['line_1'],
        line2 = json['line_2'],
        townCity = json['town_city'],
        country = json['country'],
        countryLabel = json['country_label'],
        postcode = json['postcode'],
        latitude = json['latitude'],
        longitude = json['longitude'];

  List<String> get components => [
        line1,
        line2,
        townCity,
        postcode,
        countryLabel,
      ]
          .where((element) => element != null && element.isNotEmpty)
          .toList()
          .cast<String>();

  LatLng? get coordinates {
    if (latitude != null && longitude != null) {
      return LatLng(latitude!, longitude!);
    }
    return null;
  }

  Uri get directionsUrl {
    return Uri(
        scheme: 'https',
        host: 'www.google.com',
        path: '/maps/dir/',
        queryParameters: {
          'api': '1',
          'destination': "$line1, $postcode, $country",
        });
  }
}
