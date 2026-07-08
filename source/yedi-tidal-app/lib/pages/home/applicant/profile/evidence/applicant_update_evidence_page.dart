import 'package:flutter/widgets.dart';
import 'package:yedi_app/pages/home/applicant/profile/evidence/applicant_update_evidence_view.dart';

class ApplicantUpdateEvidencePage extends StatelessWidget {
  const ApplicantUpdateEvidencePage(
      {super.key, required this.requiredEvidenceId});

  final int requiredEvidenceId;

  static const name = 'applicant-evidence';

  @override
  Widget build(BuildContext context) {
    return ApplicantUpdateEvidenceView(requiredEvidenceId: requiredEvidenceId);
  }
}
