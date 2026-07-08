import 'dart:async';

import 'package:yedi_app/main.dart';
import 'package:yedi_app/modules/api/api.dart';
import 'package:yedi_app/modules/sign_up/models/declaration_model.dart';

class DeclarationService {
  late final ApiService _apiService;

  DeclarationService() {
    _apiService = getIt.get<ApiService>();
  }

  Future<DeclarationModel> getDeclaration(int id) async {
    final res = await _apiService
        .getData<Map<String, dynamic>>('app/applicant/declarations/$id');
    return DeclarationModel.fromJson(res.data!['data']);
  }
}
