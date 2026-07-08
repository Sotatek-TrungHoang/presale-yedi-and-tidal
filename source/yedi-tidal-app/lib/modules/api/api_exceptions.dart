import 'package:dio/dio.dart';

class APIException implements Exception {
  final Response? response;
  final String? message;

  APIException({this.response, this.message});

  @override
  String toString() {
    return message ?? response?.statusMessage ?? "Network error";
  }
}

class APIValidationException extends APIException {
  final Map<String, String> errors;

  APIValidationException(
      {required super.response, super.message, this.errors = const {}});
}
