import 'package:equatable/equatable.dart';
import 'package:yedi_app/modules/common/models/upload_model.dart';

class VideoVerificationModel implements Equatable {
  final int id;
  final String code;
  final UploadModel? upload;

  VideoVerificationModel({
    required this.id,
    required this.code,
    this.upload,
  });

  VideoVerificationModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        code = json['code'],
        upload = json['upload'] != null ? UploadModel.fromJson(json['upload']) : null;

  @override
  List<Object?> get props => [
        id,
        code,
        upload,
      ];

  @override
  bool? get stringify => true;
}
