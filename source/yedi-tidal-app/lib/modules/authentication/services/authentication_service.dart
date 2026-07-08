import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:yedi_app/main.dart';
import 'package:yedi_app/modules/authentication/models/auth_user_model.dart';
import 'package:yedi_app/modules/api/api.dart';

enum AuthenticationStatus { unknown, authenticated, unauthenticated }

class LoginResponse {
  final AuthUserModel user;
  final String token;

  LoginResponse({required this.token, required this.user});
}

class AuthenticationService {
  late final ApiService _apiService;
  late final SharedPreferences _sharedPreferences;

  AuthenticationService() {
    _apiService = getIt.get<ApiService>();
    _sharedPreferences = getIt.get<SharedPreferences>();
  }

  Future<LoginResponse> login(String email, String password) async {
    final res = await _apiService.postData<Map<String, dynamic>>(
        'app/common/auth/login', {'email': email, 'password': password});

    return LoginResponse(
        token: res.data!['data']['token'],
        user: AuthUserModel.fromJson(res.data!['data']['user']));
  }

  Future<AuthUserModel> getCurrentUser() async {
    final res =
        await _apiService.getData<Map<String, dynamic>>('app/common/auth/user');
    return AuthUserModel.fromJson(res.data!['data']);
  }

  Future<void> logOut() async {
    await _sharedPreferences.remove('bearerToken');
  }

  Future setBearerToken(String bearerToken) async {
    await _sharedPreferences.setString('bearerToken', bearerToken);
  }

  Future clearBearerToken() async {
    await _sharedPreferences.remove('bearerToken');
  }

  Future forgotPassword(String email) async {
    await _apiService.postData<Map<String, dynamic>>(
        'app/common/auth/forgot-password', {"email": email});
  }

  Future resetPassword(
      {required String email,
      required String token,
      required String password,
      required String passwordConfirmation}) async {
    await _apiService
        .postData<Map<String, dynamic>>('app/common/auth/reset-password', {
      "email": email,
      "token": token,
      "password": password,
      "password_confirmation": passwordConfirmation
    });
  }
}
