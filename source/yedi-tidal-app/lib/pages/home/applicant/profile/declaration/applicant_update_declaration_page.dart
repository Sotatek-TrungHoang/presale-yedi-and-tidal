import 'package:flutter/widgets.dart';
import 'package:yedi_app/pages/home/applicant/profile/declaration/applicant_update_declaration_view.dart';

class ApplicantUpdateDeclarationPage extends StatelessWidget {
  const ApplicantUpdateDeclarationPage(
      {super.key, required this.declarationId});

  final int declarationId;

  static const name = 'applicant-declaration';

  @override
  Widget build(BuildContext context) {
    return ApplicantUpdateDeclarationView(declarationId: declarationId);
  }
}
