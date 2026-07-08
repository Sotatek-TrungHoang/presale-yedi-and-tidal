import 'dart:async';

import 'package:yedi_app/main.dart';
import 'package:yedi_app/modules/api/api.dart';
import 'package:yedi_app/modules/authentication/models/auth_user_model.dart';

class ChangeEmailService {
  late final ApiService _apiService;

  ChangeEmailService() {
    _apiService = getIt.get<ApiService>();
  }

  Future requestEmailChange(String email) async {
    await _apiService
        .postData<Map<String, dynamic>>('app/common/change-email/request', {
      "new_email": email,
    });

    return;
  }

  Future<AuthUserModel> verifyCode(String email, String code) async {
    final res = await _apiService
        .postData<Map<String, dynamic>>('app/common/change-email/verify-code', {
      "new_email": email,
      "code": code,
    });

    return AuthUserModel.fromJson(res.data!['data']);
  }
}
