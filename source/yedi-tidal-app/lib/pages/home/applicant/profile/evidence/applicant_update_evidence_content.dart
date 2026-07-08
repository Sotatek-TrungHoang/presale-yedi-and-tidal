import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/authentication/bloc/authentication_bloc.dart';
import 'package:yedi_app/modules/authentication/models/auth_user_model.dart';
import 'package:yedi_app/modules/profile/bloc/update_evidence_cubit.dart';
import 'package:yedi_app/pages/sign_up/steps/ui/step_page_title.dart';
import 'package:yedi_app/ui/inputs/file_upload_input.dart';
import 'package:yedi_app/ui/profile/confirm_profile_uodate_alert.dart';
import 'package:yedi_app/ui/spacer.dart';
import 'package:yedi_app/ui/theme/app_theme.dart';

class ApplicantUpdateEvidenceContent extends StatelessWidget {
  const ApplicantUpdateEvidenceContent({super.key});

  @override
  Widget build(BuildContext context) {
    final formState = context.watch<UpdateEvidenceCubit>().state;

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StepPageTitle(title: formState.requiredEvidence!.title),
          VSpacer(20),
          FileUploadInput(
              buttonText: "Upload ${formState.requiredEvidence!.title}",
              uploadModel: formState.applicantEvidence,
              icon: Icons.insert_drive_file,
              onUploaded: (upload) =>
                  context.read<UpdateEvidenceCubit>().fileUpdated(upload)),
          Divider(
            height: 50,
          ),
          ElevatedButton(
              onPressed:
                  formState.isLoaded ? () => _onSubmitPressed(context) : null,
              child: Text(formState.isSubmitting
                  ? "Updating Evidence..."
                  : "Update Evidence...")),
          if (formState.error != null) ...[
            VSpacer(20),
            Text(
              formState.error!,
              style: TextStyle(color: appColours.error),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  _onSubmitPressed(BuildContext context) async {
    final complianceStatus = context
        .read<AuthenticationBloc>()
        .state
        .user
        ?.applicant
        ?.complianceStatus;
    if (complianceStatus == ApplicantComplianceStatus.compliant) {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return ConfirmProfileUpdateAlert(
              dialogContext: dialogContext,
              content:
                  "Are you sure you want to update your evidence?\n\nYour account may need to be re-approved before you will be allowed to apply to jobs.",
              onConfirm: () => context.read<UpdateEvidenceCubit>().submit());
        },
      );
    } else {
      context.read<UpdateEvidenceCubit>().submit();
    }
  }
}
