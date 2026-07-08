import 'dart:async';

import 'package:yedi_app/main.dart';
import 'package:yedi_app/modules/api/api.dart';
import 'package:yedi_app/modules/hearted_applicants/models/hearted_applicant_model.dart';

class HeartedApplicantsService {
  late final ApiService _apiService;

  HeartedApplicantsService() {
    _apiService = getIt.get<ApiService>();
  }

  Future<List<HeartedApplicantModel>> getHeartedApplicants() async {
    final res = await _apiService
        .getData<Map<String, dynamic>>('app/advertiser/applicants');

    return List.from(res.data!['data'])
        .map((data) => HeartedApplicantModel.fromJson(data))
        .toList();
  }

  Future<String> heartApplicant(int applicantId) async {
    final res = await _apiService.postData<Map<String, dynamic>>(
        'app/advertiser/applicants/$applicantId/heart');

    return res.data!['message'];
  }

  Future<String> unheartApplicant(int applicantId) async {
    final res = await _apiService.postData<Map<String, dynamic>>(
        'app/advertiser/applicants/$applicantId/unheart');

    return res.data!['message'];
  }
}
