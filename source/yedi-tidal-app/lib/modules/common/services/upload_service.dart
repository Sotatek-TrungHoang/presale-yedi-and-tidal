import 'dart:async';

import 'package:dio/dio.dart';
import 'package:yedi_app/main.dart';
import 'package:yedi_app/modules/api/api.dart';
import 'package:yedi_app/modules/common/models/upload_model.dart';

class UploadService {
  late final ApiService _apiService;

  UploadService() {
    _apiService = getIt.get<ApiService>();
  }

  Future<UploadModel> uploadFile(String filePath,
      {ProgressCallback? onSendProgress}) async {
    final formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(filePath,
          filename: filePath.split("/").last)
    });

    final res = await _apiService.postFormData<Map<String, dynamic>>(
        'app/common/uploads', formData,
        onSendProgress: onSendProgress);
    return UploadModel.fromJson(res.data!['data']);
  }

  Future<UploadModel> fromGoogle(String name, String postcode) async {
    final res = await _apiService
        .postData<Map<String, dynamic>>('app/common/uploads/from-google', {
      'name': name,
      'postcode': postcode,
    });
    return UploadModel.fromJson(res.data!['data']);
  }
}
