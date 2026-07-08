import 'dart:async';

import 'package:yedi_app/main.dart';
import 'package:yedi_app/modules/api/api.dart';
import 'package:yedi_app/modules/profile/model/profile_block_model.dart';

abstract class ProfileService {
  late final ApiService _apiService;

  Future<List<ProfileBlockModel>> getBlocks() async {
    throw UnimplementedError();
  }

  Future updateAddress(Map<String, dynamic> data) async {
    throw UnimplementedError();
  }

  Future updateProfile(Map<String, dynamic> data) async {
    throw UnimplementedError();
  }

  Future updateCompliance(Map<String, dynamic> data) async {
    throw UnimplementedError();
  }

  Future updateQualifications(Map<String, dynamic> data) async {
    throw UnimplementedError();
  }

  Future updateEvidence(int requiredEvidenceId, String? uploadId) async {
    throw UnimplementedError();
  }

  Future agreeToDeclaration(int declarationId) async {
    throw UnimplementedError();
  }

  Future updateRightToWorkDeclaration(Map<String, dynamic> data) async {
    throw UnimplementedError();
  }
}

class AdvertiserProfileService extends ProfileService {
  AdvertiserProfileService() {
    _apiService = getIt.get<ApiService>();
  }

  @override
  Future updateAddress(Map<String, dynamic> data) async {
    await _apiService.postData<Map<String, dynamic>>(
        'app/advertiser/profile/update-address', data);

    return;
  }

  @override
  Future updateProfile(Map<String, dynamic> data) async {
    await _apiService.postData<Map<String, dynamic>>(
        'app/advertiser/profile/update-profile', data);

    return;
  }
}

class ApplicantProfileService extends ProfileService {
  ApplicantProfileService() {
    _apiService = getIt.get<ApiService>();
  }

  @override
  Future<List<ProfileBlockModel>> getBlocks() async {
    final res = await _apiService.getData('app/applicant/profile');

    return (res.data!['data'] as List)
        .map((e) => ProfileBlockModel.fromJson(e))
        .toList();
  }

  @override
  Future updateAddress(Map<String, dynamic> data) async {
    await _apiService.postData<Map<String, dynamic>>(
        'app/applicant/profile/update-address', data);

    return;
  }

  @override
  Future updateProfile(Map<String, dynamic> data) async {
    await _apiService.postData<Map<String, dynamic>>(
        'app/applicant/profile/update-profile', data);

    return;
  }

  @override
  Future updateCompliance(Map<String, dynamic> data) async {
    await _apiService.postData<Map<String, dynamic>>(
        'app/applicant/profile/update-compliance', data);

    return;
  }

  @override
  Future updateQualifications(Map<String, dynamic> data) async {
    await _apiService.postData<Map<String, dynamic>>(
        'app/applicant/profile/update-qualifications', data);

    return;
  }

  @override
  Future updateEvidence(int requiredEvidenceId, String? uploadId) async {
    await _apiService.postData<Map<String, dynamic>>(
        'app/applicant/profile/update-evidence/$requiredEvidenceId',
        {"upload_id": uploadId});

    return;
  }

  @override
  Future agreeToDeclaration(int declarationId) async {
    await _apiService.postData<Map<String, dynamic>>(
        'app/applicant/profile/agree-to-declaration/$declarationId');

    return;
  }

  @override
  Future updateRightToWorkDeclaration(Map<String, dynamic> data) async {
    await _apiService.postData<Map<String, dynamic>>(
        'app/applicant/profile/update-right-to-work-declaration', data);
  }
}
