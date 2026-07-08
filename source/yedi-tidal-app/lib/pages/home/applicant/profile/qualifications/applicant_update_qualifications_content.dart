import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/authentication/bloc/authentication_bloc.dart';
import 'package:yedi_app/modules/authentication/models/auth_user_model.dart';
import 'package:yedi_app/modules/profile/bloc/update_applicant_qualifications_cubit.dart';
import 'package:yedi_app/ui/inputs/dropdown_input.dart';
import 'package:yedi_app/ui/inputs/text_field_input.dart';
import 'package:yedi_app/ui/profile/confirm_profile_uodate_alert.dart';
import 'package:yedi_app/ui/spacer.dart';
import 'package:yedi_app/ui/theme/app_theme.dart';

class ApplicantUpdateQualificationsContent extends StatefulWidget {
  const ApplicantUpdateQualificationsContent({super.key});

  @override
  State<ApplicantUpdateQualificationsContent> createState() =>
      _ApplicantUpdateQualificationsContentState();
}

class _ApplicantUpdateQualificationsContentState
    extends State<ApplicantUpdateQualificationsContent> {
  late final TextEditingController _teacherNumberController;

  @override
  initState() {
    super.initState();
    final formState = context.read<UpdateApplicantQualificationsCubit>().state;
    _teacherNumberController =
        TextEditingController(text: formState.data['teacher_number']);

    _teacherNumberController.addListener(() => context
        .read<UpdateApplicantQualificationsCubit>()
        .fieldUpdated('teacher_number', _teacherNumberController.text));
  }

  @override
  dispose() {
    _teacherNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = context.watch<UpdateApplicantQualificationsCubit>().state;

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (formState.settings?.requireTeacherNumber == true)
            TextFieldInput(
              label: "Teacher Number",
              controller: _teacherNumberController,
              errorText: formState.errors['teacher_number'],
              textCapitalization: TextCapitalization.characters,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              enabled: formState.isIdle,
            ),
          DropdownInput<String>(
              items: formState.qualificationItems,
              label: "Qualification",
              errorText: formState.errors['qualification'],
              value: formState.data['qualification'],
              onChanged: formState.isIdle
                  ? (value) => context
                      .read<UpdateApplicantQualificationsCubit>()
                      .fieldUpdated('qualification', value)
                  : null),
          Divider(
            height: 50,
          ),
          ElevatedButton(
              onPressed:
                  formState.isIdle ? () => _onSubmitPressed(context) : null,
              child: Text(formState.isSubmitting
                  ? "Updating Qualifications..."
                  : "Update Qualifications")),
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
              content:
                  "Are you sure you want to update your qualifications?\n\nYour account may need to be re-approved before you will be allowed to apply to jobs.",
              dialogContext: dialogContext,
              onConfirm: () =>
                  context.read<UpdateApplicantQualificationsCubit>().submit());
        },
      );
    } else {
      context.read<UpdateApplicantQualificationsCubit>().submit();
    }
  }
}
