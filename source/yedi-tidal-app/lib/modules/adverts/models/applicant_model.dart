import 'package:equatable/equatable.dart';
import 'package:yedi_app/modules/authentication/models/auth_user_model.dart';
import 'package:yedi_app/modules/authentication/models/user_model.dart';
import 'package:yedi_app/modules/common/models/address_model.dart';
import 'package:yedi_app/modules/common/models/upload_model.dart';
import 'package:yedi_app/util/models.dart';

class ApplicantModel implements Equatable {
  final int id;
  final ApplicantComplianceStatus complianceStatus;
  final String complianceStatusLabel;
  final double? rating;
  final UserModel? user;
  final AddressModel? address;
  final UploadModel? photograph;
  final bool? hearted;

  ApplicantModel(
      {required this.id,
      required this.complianceStatus,
      required this.complianceStatusLabel,
      this.rating,
      this.user,
      this.photograph,
      this.address,
      this.hearted});

  ApplicantModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        complianceStatus =
            ApplicantComplianceStatus.values.byName(json['compliance_status']),
        complianceStatusLabel = json['compliance_status_label'],
        rating =
            json['rating'] is int ? json['rating'].toDouble() : json['rating'],
        user = json['user'] != null ? UserModel.fromJson(json['user']) : null,
        photograph = json['photograph'] != null
            ? UploadModel.fromJson(json['photograph'])
            : null,
        address = json['address'] != null
            ? AddressModel.fromJson(json['address'])
            : null,
        hearted = json['hearted'];

  ApplicantModel copyWith(
          {ApplicantComplianceStatus? complianceStatus,
          String? complianceStatusLabel,
          double? rating,
          UserModel? user,
          AddressModel? address,
          UploadModel? photograph,
          Wrapped<bool?>? hearted}) =>
      ApplicantModel(
          id: id,
          complianceStatus: complianceStatus ?? this.complianceStatus,
          complianceStatusLabel:
              complianceStatusLabel ?? this.complianceStatusLabel,
          rating: rating ?? this.rating,
          user: user ?? this.user,
          address: address ?? this.address,
          photograph: photograph ?? this.photograph,
          hearted: hearted is Wrapped ? hearted!.value : this.hearted);

  @override
  List<Object?> get props => [
        id,
        complianceStatus,
        complianceStatusLabel,
        rating,
        photograph,
        address,
        user,
        hearted,
      ];

  @override
  bool? get stringify => true;
}
