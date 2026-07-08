import 'package:equatable/equatable.dart';
import 'package:yedi_app/modules/common/models/upload_model.dart';

class ContractModel extends Equatable {
  final int id;
  final String title;
  final UploadModel upload;
  final DateTime createdAt;

  const ContractModel(
      {required this.id,
      required this.title,
      required this.upload,
      required this.createdAt});

  ContractModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        upload = UploadModel.fromJson(json['upload']),
        createdAt = DateTime.parse(json['created_at']);

  @override
  List<Object?> get props => [
        id,
        title,
        upload,
        createdAt,
      ];
}
