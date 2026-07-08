import 'package:equatable/equatable.dart';
import 'package:yedi_app/modules/common/models/upload_model.dart';

class AdvertiserModel implements Equatable {
  final int id;
  final String name;
  final String? bio;
  final String email;
  final String telephone;
  final String? additionalInfo;
  final UploadModel? photograph;

  AdvertiserModel(
      {required this.id,
      required this.name,
      this.bio,
      required this.email,
      required this.telephone,
      this.additionalInfo,
      this.photograph});

  AdvertiserModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        bio = json['bio'],
        email = json['email'],
        telephone = json['telephone'],
        additionalInfo = json['additional_info'],
        photograph = json['photograph'] != null
            ? UploadModel.fromJson(json['photograph'])
            : null;

  @override
  List<Object?> get props => [
        id,
        name,
        bio,
        email,
        telephone,
        additionalInfo,
        photograph,
      ];

  @override
  bool? get stringify => true;
}
