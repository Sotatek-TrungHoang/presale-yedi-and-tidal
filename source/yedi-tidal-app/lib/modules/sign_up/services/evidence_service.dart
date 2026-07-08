import 'dart:async';

import 'package:yedi_app/main.dart';
import 'package:yedi_app/modules/api/api.dart';
import 'package:yedi_app/modules/sign_up/models/required_evidence_model.dart';

class EvidenceService {
  late final ApiService _apiService;

  EvidenceService() {
    _apiService = getIt.get<ApiService>();
  }

  Future<RequiredEvidenceModel> getRequiredEvidence(int id) async {
    final res = await _apiService
        .getData<Map<String, dynamic>>('app/applicant/required-evidence/$id');
    return RequiredEvidenceModel.fromJson(res.data!['data']);
  }
}
