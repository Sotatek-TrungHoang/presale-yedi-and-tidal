import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yedi_app/main.dart';
import 'package:yedi_app/modules/api/api_exceptions.dart';
import 'package:yedi_app/util/env.dart';
import 'package:yedi_app/util/firebase.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Env.baseUrl,
    ),
  );

  ApiService() {
    // Add any interceptors if necessary
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Example: Adding headers to the request
        options.headers['Content-Type'] = 'application/json';
        options.headers['Accept'] = 'application/json';
        final prefs = await SharedPreferences.getInstance();
        final bearerToken = prefs.getString('bearerToken');
        if (bearerToken != null) {
          options.headers['Authorization'] = "Bearer $bearerToken";
        }

        final fcmToken = getIt.get<FirebaseToken>();
        if (fcmToken.token != null) {
          options.headers['X-FCM-Token'] = fcmToken.token!;
        }

        return handler.next(options); // Continue the request
      },
      onResponse: (response, handler) {
        return handler.next(response); // Continue with response
      },
      onError: (DioException e, handler) {
        // Handle errors globally
        return handler.next(e); // Continue with error handling
      },
    ));
  }

  // GET request
  Future<Response<T>> getData<T>(String endpoint,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get<T>(endpoint, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleException(e);
    }
  }

  // POST request
  Future<Response<T>> postData<T>(String endpoint,
      [Map<String, dynamic> data = const {}]) async {
    try {
      return await _dio.post<T>(endpoint, data: data);
    } on DioException catch (e) {
      throw _handleException(e);
    }
  }

  // POST request
  Future<Response<T>> postFormData<T>(String endpoint, FormData data,
      {ProgressCallback? onSendProgress}) async {
    try {
      return await _dio.post<T>(
        endpoint,
        data: data,
        onSendProgress: onSendProgress,
      );
    } on DioException catch (e) {
      throw _handleException(e);
    }
  }

  // PUT request
  Future<Response> putData(String endpoint, Map<String, dynamic> data) async {
    try {
      Response response = await _dio.put(endpoint, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleException(e);
    }
  }

  // PATCH request
  Future<Response<T>> patchData<T>(
      String endpoint, Map<String, dynamic> data) async {
    try {
      return await _dio.patch<T>(endpoint, data: data);
    } on DioException catch (e) {
      throw _handleException(e);
    }
  }

  // DELETE request
  Future<Response> deleteData(String endpoint) async {
    try {
      Response response = await _dio.delete(endpoint);
      return response;
    } on DioException catch (e) {
      throw _handleException(e);
    }
  }

  Exception _handleException(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      final message = data is String
          ? data
          : (data is Map
              ? (data.containsKey('message') ? data['message'] : e.message)
              : e.message);
      // status not in the 200s

      if (e.response!.statusCode == 422) {
        final Map<String, dynamic> apiErrors =
            data.containsKey('errors') ? data['errors'] : {};
        final Map<String, String> errors = {};
        apiErrors.forEach((key, value) {
          if (value is List && value.isNotEmpty) {
            errors[key] = value[0].toString();
          }
        });

        return APIValidationException(
            response: e.response!, message: message, errors: errors);
      }
      return APIException(
          response: e.response!,
          message: message ?? e.response!.statusMessage ?? "Network Error");
    }
    // request failed
    return APIException(response: e.response, message: e.toString());
  }
}
