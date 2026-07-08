import 'package:equatable/equatable.dart';
import 'package:yedi_app/modules/common/models/upload_model.dart';

class PayslipModel extends Equatable {
  final int id;
  final String payslipNumber;
  final String title;
  final UploadModel upload;
  final DateTime createdAt;

  const PayslipModel(
      {required this.id,
      required this.payslipNumber,
      required this.title,
      required this.upload,
      required this.createdAt});

  PayslipModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        payslipNumber = json['payslip_number'],
        title = json['title'],
        upload = UploadModel.fromJson(json['upload']),
        createdAt = DateTime.parse(json['created_at']);

  @override
  List<Object?> get props => [
        id,
        payslipNumber,
        title,
        upload,
        createdAt,
      ];
}
