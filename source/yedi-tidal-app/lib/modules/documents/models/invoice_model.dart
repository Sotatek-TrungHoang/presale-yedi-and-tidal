import 'package:equatable/equatable.dart';
import 'package:yedi_app/modules/common/models/upload_model.dart';

class InvoiceModel extends Equatable {
  final int id;
  final String invoiceNumber;
  final String title;
  final UploadModel upload;
  final DateTime createdAt;

  const InvoiceModel(
      {required this.id,
      required this.invoiceNumber,
      required this.title,
      required this.upload,
      required this.createdAt});

  InvoiceModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        invoiceNumber = json['invoice_number'],
        title = json['title'],
        upload = UploadModel.fromJson(json['upload']),
        createdAt = DateTime.parse(json['created_at']);

  @override
  List<Object?> get props => [
        id,
        invoiceNumber,
        title,
        upload,
        createdAt,
      ];
}
