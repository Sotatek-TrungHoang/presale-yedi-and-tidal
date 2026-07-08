import 'dart:async';

import 'package:yedi_app/main.dart';
import 'package:yedi_app/modules/api/api.dart';

class ChangePasswordService {
  late final ApiService _apiService;

  ChangePasswordService() {
    _apiService = getIt.get<ApiService>();
  }

  Future changePassword(
      {required String currentPassword,
      required String password,
      required String passwordConfirmation}) async {
    await _apiService
        .postData<Map<String, dynamic>>('app/common/change-password', {
      "current_password": currentPassword,
      "password": password,
      "password_confirmation": passwordConfirmation,
    });

    return;
  }
}
