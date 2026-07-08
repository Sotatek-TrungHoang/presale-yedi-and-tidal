import 'package:equatable/equatable.dart';
import 'package:yedi_app/modules/common/models/upload_model.dart';

class DeclarationModel implements Equatable {
  final int id;
  final String title;
  final String description;
  final UploadModel upload;

  DeclarationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.upload,
  });

  DeclarationModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        description = json['description'],
        upload = UploadModel.fromJson(json['upload']);

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        upload,
      ];

  @override
  bool? get stringify => true;
}
