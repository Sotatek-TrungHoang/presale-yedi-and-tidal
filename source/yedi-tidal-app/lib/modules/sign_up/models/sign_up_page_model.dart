import 'package:equatable/equatable.dart';
import 'package:yedi_app/modules/sign_up/models/declaration_model.dart';
import 'package:yedi_app/modules/sign_up/models/required_evidence_model.dart';

enum SignUpPageCode {
  choose_an_account,
  overview,
  create_profile,
  account_created,
  compliance,
  address,
  qualifications,
  references,
  evidence,
  declaration,
  right_to_work_declaration,
  compliance_completed,
  photo_upload,
  sign_up_complete
}

class SignUpPageModel implements Equatable {
  final SignUpPageCode code;
  final String title;
  final String timeToComplete;
  final bool complete;
  final bool showInOverview;
  final int? requiredEvidenceId;
  final RequiredEvidenceModel? requiredEvidence;
  final int? declarationId;
  final DeclarationModel? declaration;
  final bool? requireTeacherNumber;
  final int? referencesRequired;

  SignUpPageModel({
    required this.code,
    required this.title,
    required this.timeToComplete,
    required this.complete,
    required this.showInOverview,
    this.requiredEvidenceId,
    this.requiredEvidence,
    this.declarationId,
    this.declaration,
    this.requireTeacherNumber,
    this.referencesRequired,
  });

  SignUpPageModel.fromJson(Map<String, dynamic> json)
      : code = SignUpPageCode.values.byName(json['code']),
        title = json['title'],
        timeToComplete = json['time_to_complete'],
        complete = json['complete'],
        showInOverview = json['show_in_overview'],
        requiredEvidenceId = json['required_evidence_id'],
        requiredEvidence = json['required_evidence'] != null
            ? RequiredEvidenceModel.fromJson(json['required_evidence'])
            : null,
        declarationId = json['declaration_id'],
        declaration = json['declaration'] != null
            ? DeclarationModel.fromJson(json['declaration'])
            : null,
        requireTeacherNumber = json['require_teacher_number'],
        referencesRequired = json['references_required'];

  @override
  List<Object?> get props => [
        code,
        title,
        timeToComplete,
        complete,
        showInOverview,
        requiredEvidenceId,
        requiredEvidence,
        declarationId,
        declaration,
        requireTeacherNumber,
        referencesRequired,
      ];

  @override
  bool? get stringify => true;
}
