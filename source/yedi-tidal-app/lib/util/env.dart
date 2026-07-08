abstract class Env {
  static String get baseUrl => const String.fromEnvironment('BASE_API_URL');
  static String get googleMapsApiKey =>
      const String.fromEnvironment('GOOGLE_MAPS_API_KEY');

  static validate() {
    if (baseUrl.isEmpty) {
      throw Exception('BASE_API_URL is not set');
    }
    if (googleMapsApiKey.isEmpty) {
      throw Exception('GOOGLE_MAPS_API_KEY is not set');
    }
  }

  static String print() {
    return 'Env{baseUrl: $baseUrl, googleMapsApiKey: $googleMapsApiKey}';
  }
}
