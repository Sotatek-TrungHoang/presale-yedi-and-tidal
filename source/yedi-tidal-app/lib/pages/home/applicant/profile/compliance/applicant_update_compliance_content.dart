import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/authentication/bloc/authentication_bloc.dart';
import 'package:yedi_app/modules/authentication/models/auth_user_model.dart';
import 'package:yedi_app/modules/profile/bloc/update_applicant_compliance_cubit.dart';
import 'package:yedi_app/pages/sign_up/steps/ui/photo_upload_widget.dart';
import 'package:yedi_app/ui/profile/confirm_profile_uodate_alert.dart';
import 'package:yedi_app/ui/spacer.dart';
import 'package:yedi_app/ui/theme/app_theme.dart';

class ApplicantUpdateComplianceContent extends StatelessWidget {
  const ApplicantUpdateComplianceContent({super.key});

  @override
  Widget build(BuildContext context) {
    final formState = context.watch<UpdateApplicantComplianceCubit>().state;

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PhotoUploadWidget(
              uploadModel: formState.photograph,
              onUploaded: formState.isSubmitting
                  ? null
                  : (upload) => context
                      .read<UpdateApplicantComplianceCubit>()
                      .photographUpdated(upload),
              incompleteButtonText: "Upload Your Photograph",
              completeButtonText: "Retake Photo",
              label: "Your Photograph",
              errorText: formState.errors['photograph_id']),
          VSpacer(26),
          PhotoUploadWidget(
              uploadModel: formState.evidenceOfId,
              onUploaded: formState.isSubmitting
                  ? null
                  : (upload) => context
                      .read<UpdateApplicantComplianceCubit>()
                      .evidenceOfIdUpdated(upload),
              incompleteButtonText: "Evidence of I.D",
              completeButtonText: "Retake Photo",
              label: "Upload Evidence of I.D",
              infoText: "(Passport or Driving Licence)",
              errorText: formState.errors['photograph_id']),
          Divider(
            height: 50,
          ),
          ElevatedButton(
              onPressed:
                  formState.isIdle ? () => _onSubmitPressed(context) : null,
              child: Text(formState.isSubmitting
                  ? "Updating Profile"
                  : "Update Profile")),
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
                  "Are you sure you want to update your compliance documents?\n\nYour account may need to be re-approved before you will be allowed to apply to jobs.",
              onConfirm: () =>
                  context.read<UpdateApplicantComplianceCubit>().submit());
        },
      );
    } else {
      context.read<UpdateApplicantComplianceCubit>().submit();
    }
  }
}
