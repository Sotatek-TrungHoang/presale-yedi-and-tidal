import 'dart:async';

import 'package:yedi_app/main.dart';
import 'package:yedi_app/modules/api/api.dart';
import 'package:yedi_app/modules/profile/model/refence_model.dart';

class ReferencesService {
  late final ApiService _apiService;

  ReferencesService() {
    _apiService = getIt.get<ApiService>();
  }

  Future<List<ReferenceModel>> getReferences() async {
    final res = await _apiService.getData('app/applicant/references');

    return (res.data!['data'] as List)
        .map((e) => ReferenceModel.fromJson(e))
        .toList();
  }
}
