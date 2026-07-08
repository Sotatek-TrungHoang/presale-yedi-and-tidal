import 'package:equatable/equatable.dart';
import 'package:yedi_app/modules/common/models/address_model.dart';
import 'package:yedi_app/modules/sign_up/models/declaration_model.dart';
import 'package:yedi_app/modules/sign_up/models/required_evidence_model.dart';
import 'package:yedi_app/modules/sign_up/models/right_to_work_declaration_model.dart';
import 'package:yedi_app/modules/sign_up/models/video_verification_model.dart';
import 'package:yedi_app/modules/common/models/upload_model.dart';
import 'package:yedi_app/util/models.dart';

enum UserType { admin, advertiser, applicant }

enum ApplicantComplianceStatus {
  incomplete,
  pending_approval,
  compliant,
  non_compliant,
}

enum AdvertiserComplianceStatus {
  pending,
  compliant,
  non_compliant,
}

enum ProfileStatus {
  incomplete,
  pending,
  active,
  disabled,
}

class AuthUserModel implements Equatable {
  final int id;
  final UserType type;
  final String title;
  final String titleLabel;
  final String firstName;
  final String lastName;
  final String email;
  final String telephone;
  final DateTime? dateOfBirth;
  final DateTime createdAt;
  final AuthUserApplicantModel? applicant;
  final AuthUserAdvertiserModel? advertiser;

  AuthUserModel(
      {required this.id,
      required this.type,
      required this.title,
      required this.titleLabel,
      required this.firstName,
      required this.lastName,
      required this.email,
      required this.telephone,
      this.dateOfBirth,
      required this.createdAt,
      this.applicant,
      this.advertiser});

  AuthUserModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        type = UserType.values.byName(json['type']),
        title = json['title'],
        titleLabel = json['title_label'],
        firstName = json['first_name'],
        lastName = json['last_name'],
        email = json['email'],
        telephone = json['telephone'],
        dateOfBirth = json['date_of_birth'] != null
            ? DateTime.parse(json['date_of_birth'])
            : null,
        createdAt = DateTime.parse(json['created_at']),
        applicant = json['applicant'] != null
            ? AuthUserApplicantModel.fromJson(json['applicant'])
            : null,
        advertiser = json['advertiser'] != null
            ? AuthUserAdvertiserModel.fromJson(json['advertiser'])
            : null;

  AuthUserModel copyWith({
    int? id,
    UserType? type,
    String? title,
    String? titleLabel,
    String? firstName,
    String? lastName,
    String? email,
    String? telephone,
    Wrapped<DateTime?>? dateOfBirth,
    DateTime? createdAt,
    Wrapped<AuthUserApplicantModel?>? applicant,
    Wrapped<AuthUserAdvertiserModel?>? advertiser,
  }) {
    return AuthUserModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      titleLabel: titleLabel ?? this.titleLabel,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      dateOfBirth:
          dateOfBirth is Wrapped ? dateOfBirth!.value : this.dateOfBirth,
      createdAt: createdAt ?? this.createdAt,
      applicant: applicant is Wrapped ? applicant!.value : this.applicant,
      advertiser: advertiser is Wrapped ? advertiser!.value : this.advertiser,
    );
  }

  String get fullName => "$firstName $lastName";
  String get initials => "${firstName[0]}${lastName[0]}";

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        titleLabel,
        firstName,
        lastName,
        email,
        telephone,
        dateOfBirth,
        createdAt,
        applicant,
        advertiser,
      ];

  @override
  bool? get stringify => true;
}

class AuthUserApplicantModel implements Equatable {
  final int id;
  final ApplicantComplianceStatus complianceStatus;
  final ProfileStatus profileStatus;
  final double? rating;
  final String profileStatusLabel;
  final String complianceStatusLabel;
  final String? qualification;
  final String? qualificationLabel;
  final String? teacherNumber;
  final UploadModel? photograph;
  final UploadModel? evidenceOfId;
  final VideoVerificationModel? videoVerification;
  final AddressModel? address;
  final List<AuthUserReferenceModel> references;
  final List<AuthUserEvidenceModel> applicantEvidence;
  final List<AuthUserDeclarationAgreementModel> declarationAgreements;
  final RightToWorkDeclarationModel? rightToWorkDeclaration;
  final DateTime? signUpCompletedAt;
  final AuthUserJobRoleModel? jobRole;
  final AuthUserTypeOfWorkModel? typeOfWork;

  AuthUserApplicantModel(
      {required this.id,
      required this.complianceStatus,
      required this.complianceStatusLabel,
      required this.profileStatus,
      required this.profileStatusLabel,
      this.rating,
      this.qualification,
      this.qualificationLabel,
      this.teacherNumber,
      this.photograph,
      this.evidenceOfId,
      this.videoVerification,
      this.address,
      this.references = const [],
      this.applicantEvidence = const [],
      this.declarationAgreements = const [],
      this.rightToWorkDeclaration,
      this.signUpCompletedAt,
      this.jobRole,
      this.typeOfWork});

  AuthUserApplicantModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        complianceStatus =
            ApplicantComplianceStatus.values.byName(json['compliance_status']),
        complianceStatusLabel = json['compliance_status_label'],
        profileStatus = ProfileStatus.values.byName(json['profile_status']),
        profileStatusLabel = json['profile_status_label'],
        rating =
            json['rating'] is int ? json['rating'].toDouble() : json['rating'],
        qualification = json['qualification'],
        qualificationLabel = json['qualification_label'],
        teacherNumber = json['teacher_number'],
        photograph = json['photograph'] != null
            ? UploadModel.fromJson(json['photograph'])
            : null,
        evidenceOfId = json['evidence_of_id'] != null
            ? UploadModel.fromJson(json['evidence_of_id'])
            : null,
        videoVerification = json['video_verification'] != null
            ? VideoVerificationModel.fromJson(json['video_verification'])
            : null,
        address = json['address'] != null
            ? AddressModel.fromJson(json['address'])
            : null,
        references = List.from(json['references'])
            .map((reference) => AuthUserReferenceModel.fromJson(reference))
            .toList(),
        applicantEvidence = List.from(json['applicant_evidence'])
            .map((evidence) => AuthUserEvidenceModel.fromJson(evidence))
            .toList(),
        declarationAgreements = List.from(json['declaration_agreements'])
            .map((declarationAgreement) =>
                AuthUserDeclarationAgreementModel.fromJson(
                    declarationAgreement))
            .toList(),
        rightToWorkDeclaration = json['right_to_work_declaration'] != null
            ? RightToWorkDeclarationModel.fromJson(
                json['right_to_work_declaration'])
            : null,
        signUpCompletedAt = json['sign_up_completed_at'] != null
            ? DateTime.parse(json['sign_up_completed_at'])
            : null,
        jobRole = json['job_role'] != null
            ? AuthUserJobRoleModel.fromJson(json['job_role'])
            : null,
        typeOfWork = json['type_of_work'] != null
            ? AuthUserTypeOfWorkModel.fromJson(json['type_of_work'])
            : null;

  @override
  List<Object?> get props => [
        id,
        complianceStatus,
        complianceStatusLabel,
        profileStatus,
        profileStatusLabel,
        rating,
        qualification,
        qualificationLabel,
        teacherNumber,
        photograph,
        evidenceOfId,
        videoVerification,
        address,
        references,
        applicantEvidence,
        declarationAgreements,
        rightToWorkDeclaration,
        signUpCompletedAt,
        jobRole,
        typeOfWork
      ];

  @override
  bool? get stringify => true;
}

class AuthUserReferenceModel implements Equatable {
  final int id;
  final String name;
  final String email;
  final String? telephone;

  AuthUserReferenceModel({
    required this.id,
    required this.name,
    required this.email,
    this.telephone,
  });

  AuthUserReferenceModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        email = json['email'],
        telephone = json['telephone'];

  @override
  List<Object?> get props => [id, name, email, telephone];

  @override
  bool? get stringify => true;
}

class AuthUserEvidenceModel implements Equatable {
  final int id;
  final UploadModel upload;
  final RequiredEvidenceModel requiredEvidence;

  AuthUserEvidenceModel({
    required this.id,
    required this.upload,
    required this.requiredEvidence,
  });

  AuthUserEvidenceModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        upload = UploadModel.fromJson(json['upload']),
        requiredEvidence =
            RequiredEvidenceModel.fromJson(json['required_evidence']);

  @override
  List<Object?> get props => [
        id,
        upload,
        requiredEvidence,
      ];

  @override
  bool? get stringify => true;
}

class AuthUserDeclarationAgreementModel implements Equatable {
  final int id;
  final DeclarationModel declaration;

  AuthUserDeclarationAgreementModel({
    required this.id,
    required this.declaration,
  });

  AuthUserDeclarationAgreementModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        declaration = DeclarationModel.fromJson(json['declaration']);

  @override
  List<Object?> get props => [
        id,
        declaration,
      ];

  @override
  bool? get stringify => true;
}

class AuthUserJobRoleModel implements Equatable {
  final int id;
  final String name;

  AuthUserJobRoleModel({
    required this.id,
    required this.name,
  });

  AuthUserJobRoleModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'];

  @override
  List<Object?> get props => [
        id,
        name,
      ];

  @override
  bool? get stringify => true;
}

class AuthUserTypeOfWorkModel implements Equatable {
  final int id;
  final String name;

  AuthUserTypeOfWorkModel({
    required this.id,
    required this.name,
  });

  AuthUserTypeOfWorkModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'];

  @override
  List<Object?> get props => [
        id,
        name,
      ];

  @override
  bool? get stringify => true;
}

class AuthUserAdvertiserModel implements Equatable {
  final int id;
  final String name;
  final String email;
  final String telephone;
  final String? bio;
  final String? additionalInfo;
  final AdvertiserComplianceStatus complianceStatus;
  final String complianceStatusLabel;
  final ProfileStatus profileStatus;
  final String profileStatusLabel;
  final AddressModel? address;
  final UploadModel? photograph;
  final DateTime? signUpCompletedAt;

  AuthUserAdvertiserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.telephone,
    this.bio,
    this.additionalInfo,
    required this.complianceStatus,
    required this.complianceStatusLabel,
    required this.profileStatus,
    required this.profileStatusLabel,
    this.address,
    this.photograph,
    this.signUpCompletedAt,
  });

  AuthUserAdvertiserModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        email = json['email'],
        telephone = json['telephone'],
        bio = json['bio'],
        additionalInfo = json['additional_info'],
        complianceStatus =
            AdvertiserComplianceStatus.values.byName(json['compliance_status']),
        complianceStatusLabel = json['compliance_status_label'],
        profileStatus = ProfileStatus.values.byName(json['profile_status']),
        profileStatusLabel = json['profile_status_label'],
        address = json['address'] != null
            ? AddressModel.fromJson(json['address'])
            : null,
        photograph = json['photograph'] != null
            ? UploadModel.fromJson(json['photograph'])
            : null,
        signUpCompletedAt = json['sign_up_completed_at'] != null
            ? DateTime.parse(json['sign_up_completed_at'])
            : null;

  String get schoolInitials => name.split(' ').map((e) => e[0]).join();

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        telephone,
        bio,
        additionalInfo,
        complianceStatus,
        complianceStatusLabel,
        profileStatus,
        profileStatusLabel,
        address,
        photograph,
        signUpCompletedAt,
      ];

  @override
  bool? get stringify => true;
}
