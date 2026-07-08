import 'package:equatable/equatable.dart';
import 'package:yedi_app/modules/adverts/models/applicant_model.dart';
import 'package:yedi_app/util/models.dart';

class HeartedApplicantModel implements Equatable {
  final int id;
  final ApplicantModel applicant;
  final DateTime createdAt;
  final DateTime updatedAt;

  HeartedApplicantModel({
    required this.id,
    required this.applicant,
    required this.createdAt,
    required this.updatedAt,
  });

  HeartedApplicantModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        applicant = ApplicantModel.fromJson(json['applicant']),
        createdAt = DateTime.parse(json['created_at']),
        updatedAt = DateTime.parse(json['updated_at']);

  HeartedApplicantModel setHearted(bool hearted) => HeartedApplicantModel(
      id: id,
      applicant: applicant.copyWith(hearted: Wrapped.value(hearted)),
      createdAt: createdAt,
      updatedAt: hearted ? DateTime.now() : updatedAt);

  @override
  List<Object?> get props => [
        id,
        applicant,
        createdAt,
        updatedAt,
      ];

  @override
  bool? get stringify => true;
}
