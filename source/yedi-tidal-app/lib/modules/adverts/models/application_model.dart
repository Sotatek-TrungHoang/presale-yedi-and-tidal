import 'package:equatable/equatable.dart';
import 'package:yedi_app/modules/adverts/models/advert_model.dart';
import 'package:yedi_app/modules/adverts/models/applicant_model.dart';
import 'package:yedi_app/util/models.dart';

enum ApplicationStatus { pending, accepted, declined, cancelled }

class ApplicationModel implements Equatable {
  final int id;
  final ApplicationStatus status;
  final int applicantId;
  final ApplicantModel? applicant;
  final int advertId;
  final AdvertModel? advert;
  final String statusLabel;
  final DateTime? actionedAt;
  final int? rating;
  final bool canRate;
  final DateTime createdAt;

  ApplicationModel(
      {required this.id,
      required this.status,
      required this.statusLabel,
      required this.applicantId,
      this.applicant,
      required this.advertId,
      this.advert,
      this.actionedAt,
      this.rating,
      this.canRate = false,
      required this.createdAt});

  ApplicationModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        status = ApplicationStatus.values.byName(json['status']),
        applicantId = json['applicant_id'],
        applicant = json['applicant'] != null
            ? ApplicantModel.fromJson(json['applicant'])
            : null,
        advertId = json['advert_id'],
        advert = json['advert'] != null
            ? AdvertModel.fromJson(json['advert'])
            : null,
        statusLabel = json['status_label'],
        actionedAt = json['actioned_at'] != null
            ? DateTime.parse(json['actioned_at'])
            : null,
        rating = json['rating'],
        canRate = json['can_rate'],
        createdAt = DateTime.parse(json['created_at']);

  ApplicationModel copyWith(
          {ApplicationStatus? status,
          String? statusLabel,
          DateTime? actionedAt,
          Wrapped<ApplicantModel?>? applicant}) =>
      ApplicationModel(
          id: id,
          status: status ?? this.status,
          statusLabel: statusLabel ?? this.statusLabel,
          applicantId: applicantId,
          applicant: applicant is Wrapped ? applicant!.value : this.applicant,
          advertId: advertId,
          advert: advert,
          actionedAt: actionedAt ?? this.actionedAt,
          rating: rating,
          canRate: canRate,
          createdAt: createdAt);

  @override
  List<Object?> get props => [
        id,
        status,
        statusLabel,
        applicantId,
        applicant,
        advertId,
        advert,
        actionedAt,
        rating,
        canRate,
        createdAt,
      ];

  @override
  bool? get stringify => true;
}
