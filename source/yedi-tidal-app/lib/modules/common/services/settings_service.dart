import 'dart:async';

import 'package:yedi_app/main.dart';
import 'package:yedi_app/modules/api/api.dart';
import 'package:yedi_app/modules/common/models/settings_model.dart';

class SettingsService {
  late final ApiService _apiService;

  SettingsService() {
    _apiService = getIt.get<ApiService>();
  }

  Future<SettingsModel> getSettings() async {
    final res =
        await _apiService.getData<Map<String, dynamic>>('app/common/settings');
    return SettingsModel.fromJson(res.data!['data']);
  }
}
