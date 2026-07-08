import 'dart:async';

import 'package:yedi_app/main.dart';
import 'package:yedi_app/modules/api/api.dart';
import 'package:yedi_app/modules/authentication/models/auth_user_model.dart';
import 'package:yedi_app/modules/sign_up/models/sign_up_page_model.dart';

final class CreateProfileResponse {
  final AuthUserModel user;
  final String? token;

  CreateProfileResponse({required this.user, required this.token});
}

final class GetPagesResponse {
  final List<SignUpPageModel> pages;
  final int currentPageIndex;

  GetPagesResponse(this.pages, this.currentPageIndex);
}

class SignUpService {
  late final ApiService _apiService;

  SignUpService() {
    _apiService = getIt.get<ApiService>();
  }

  Future<GetPagesResponse> getPages(UserType userType) async {
    final url = userType == UserType.applicant
        ? 'app/applicant/sign-up/pages'
        : 'app/advertiser/sign-up/pages';

    final res = await _apiService.getData(url);

    return GetPagesResponse(
        List.from(res.data!['pages'])
            .map((e) => SignUpPageModel.fromJson(e))
            .toList(),
        res.data!['current_page_index']);
  }

  Future<CreateProfileResponse> createAdvertiserProfile(
      Map<String, dynamic> data) async {
    final res = await _apiService.postData<Map<String, dynamic>>(
        'app/advertiser/sign-up/create-profile', data);
    return CreateProfileResponse(
        token: res.data!['token'],
        user: AuthUserModel.fromJson(res.data!['user']));
  }

  Future<CreateProfileResponse> createApplicantProfile(
      Map<String, dynamic> data) async {
    final res = await _apiService.postData<Map<String, dynamic>>(
        'app/applicant/sign-up/create-profile', data);
    return CreateProfileResponse(
        token: res.data!['token'],
        user: AuthUserModel.fromJson(res.data!['user']));
  }

  Future<AuthUserModel> submitCompliance(Map<String, dynamic> data) async {
    final res = await _apiService.postData<Map<String, dynamic>>(
        'app/applicant/sign-up/submit-compliance', data);
    return AuthUserModel.fromJson(res.data!['data']);
  }

  Future<AuthUserModel> submitApplicantAddress(
      Map<String, dynamic> data) async {
    final res = await _apiService.postData<Map<String, dynamic>>(
        'app/applicant/sign-up/submit-address', data);
    return AuthUserModel.fromJson(res.data!['data']);
  }

  Future<AuthUserModel> submitAdvertiserAddress(
      Map<String, dynamic> data) async {
    final res = await _apiService.postData<Map<String, dynamic>>(
        'app/advertiser/sign-up/submit-address', data);
    return AuthUserModel.fromJson(res.data!['data']);
  }

  Future<AuthUserModel> submitQualifications(Map<String, dynamic> data) async {
    final res = await _apiService.postData<Map<String, dynamic>>(
        'app/applicant/sign-up/submit-qualifications', data);
    return AuthUserModel.fromJson(res.data!['data']);
  }

  Future<AuthUserModel> submitReferences(Map<String, dynamic> data) async {
    final res = await _apiService.postData<Map<String, dynamic>>(
        'app/applicant/sign-up/submit-references', data);
    return AuthUserModel.fromJson(res.data!['data']);
  }

  Future<AuthUserModel> submitEvidence(
      int requiredEvidenceId, Map<String, dynamic> data) async {
    final res = await _apiService.postData<Map<String, dynamic>>(
        'app/applicant/sign-up/submit-evidence/$requiredEvidenceId', data);
    return AuthUserModel.fromJson(res.data!['data']);
  }

  Future<AuthUserModel> agreeToDeclaration(int declarationId) async {
    final res = await _apiService.postData<Map<String, dynamic>>(
        'app/applicant/sign-up/agree-to-declaration/$declarationId', {});
    return AuthUserModel.fromJson(res.data!['data']);
  }

  Future<AuthUserModel> submitRightToWorkDeclaration(
      Map<String, dynamic> data) async {
    final res = await _apiService.postData<Map<String, dynamic>>(
        'app/applicant/sign-up/submit-right-to-work-declaration', data);
    return AuthUserModel.fromJson(res.data!['data']);
  }

  Future<AuthUserModel> submitAdvertiserPhotograph(
      Map<String, dynamic> data) async {
    final res = await _apiService.postData<Map<String, dynamic>>(
        'app/advertiser/sign-up/submit-photograph', data);
    return AuthUserModel.fromJson(res.data!['data']);
  }

  Future<AuthUserModel> completeApplicantSignUp() async {
    final res = await _apiService.postData<Map<String, dynamic>>(
        'app/applicant/sign-up/complete-sign-up', {});
    return AuthUserModel.fromJson(res.data!['data']);
  }

  Future<AuthUserModel> completeAdvertiserSignUp() async {
    final res = await _apiService.postData<Map<String, dynamic>>(
        'app/advertiser/sign-up/complete-sign-up', {});
    return AuthUserModel.fromJson(res.data!['data']);
  }

  Future cancelSignUp(UserType userType) async {
    final url = userType == UserType.applicant
        ? 'app/applicant/sign-up/cancel-sign-up'
        : 'app/advertiser/sign-up/cancel-sign-up';
    await _apiService.postData<Map<String, dynamic>>(url, {});
    return true;
  }
}
