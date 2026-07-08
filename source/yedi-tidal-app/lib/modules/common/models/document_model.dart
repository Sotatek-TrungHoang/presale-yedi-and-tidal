import 'package:equatable/equatable.dart';
import 'package:yedi_app/modules/common/models/upload_model.dart';

class DocumentModel implements Equatable {
  final int id;
  final String title;
  final UploadModel upload;

  DocumentModel({
    required this.id,
    required this.title,
    required this.upload,
  });

  DocumentModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        upload = UploadModel.fromJson(json['upload']);

  @override
  List<Object?> get props => [id, title, upload];

  @override
  bool? get stringify => true;
}
