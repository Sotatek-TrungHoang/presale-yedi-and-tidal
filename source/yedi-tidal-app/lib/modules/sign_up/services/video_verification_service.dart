import 'dart:async';

import 'package:yedi_app/main.dart';
import 'package:yedi_app/modules/api/api.dart';
import 'package:yedi_app/modules/sign_up/models/video_verification_model.dart';

class VideoVerificationService {
  late final ApiService _apiService;

  VideoVerificationService() {
    _apiService = getIt.get<ApiService>();
  }

  Future<VideoVerificationModel> getNewVideoVerification() async {
    final res = await _apiService.postData<Map<String, dynamic>>(
        'app/applicant/video-verifications', {});
    return VideoVerificationModel.fromJson(res.data!['data']);
  }

  Future<VideoVerificationModel> submitVideoVerification(
      int videoVerificationId, String uploadId) async {
    final res = await _apiService.postData<Map<String, dynamic>>(
        'app/applicant/video-verifications/$videoVerificationId/submit', {
      "upload_id": uploadId,
    });
    return VideoVerificationModel.fromJson(res.data!['data']);
  }
}
