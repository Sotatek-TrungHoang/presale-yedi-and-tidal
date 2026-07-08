import 'dart:async';

import 'package:yedi_app/main.dart';
import 'package:yedi_app/modules/api/api.dart';

class AccountService {
  late final ApiService _apiService;

  AccountService() {
    _apiService = getIt.get<ApiService>();
  }

  Future deleteAccount() async {
    await _apiService
        .postData<Map<String, dynamic>>('app/common/delete-account');

    return;
  }
}
