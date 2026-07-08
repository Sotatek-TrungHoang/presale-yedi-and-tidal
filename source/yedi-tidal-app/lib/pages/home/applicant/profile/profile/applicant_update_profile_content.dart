import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/authentication/bloc/authentication_bloc.dart';
import 'package:yedi_app/modules/authentication/models/auth_user_model.dart';
import 'package:yedi_app/modules/profile/bloc/update_applicant_profile_cubit.dart';
import 'package:yedi_app/ui/inputs/date_input.dart';
import 'package:yedi_app/ui/inputs/dropdown_input.dart';
import 'package:yedi_app/ui/inputs/text_field_input.dart';
import 'package:yedi_app/ui/profile/confirm_profile_uodate_alert.dart';
import 'package:yedi_app/ui/spacer.dart';
import 'package:yedi_app/ui/theme/app_theme.dart';
import 'package:yedi_app/util/dates.dart';

class ApplicantUpdateProfileContent extends StatefulWidget {
  const ApplicantUpdateProfileContent({super.key});

  @override
  State<ApplicantUpdateProfileContent> createState() =>
      AdvertiserUpdateProfileContentState();
}

class AdvertiserUpdateProfileContentState
    extends State<ApplicantUpdateProfileContent> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _dateOfBirthController;
  late final TextEditingController _telephoneController;

  @override
  void initState() {
    super.initState();
    final formState = context.read<UpdateApplicantProfileCubit>().state;

    _firstNameController =
        TextEditingController(text: formState.data['first_name']);
    _lastNameController =
        TextEditingController(text: formState.data['last_name']);
    _dateOfBirthController =
        TextEditingController(text: formState.dateOfBirth?.formatDate());
    _telephoneController =
        TextEditingController(text: formState.data['telephone']);

    _firstNameController.addListener(() => context
        .read<UpdateApplicantProfileCubit>()
        .fieldUpdated('first_name', _firstNameController.text));
    _lastNameController.addListener(() => context
        .read<UpdateApplicantProfileCubit>()
        .fieldUpdated('last_name', _lastNameController.text));
    _telephoneController.addListener(() => context
        .read<UpdateApplicantProfileCubit>()
        .fieldUpdated('telephone', _telephoneController.text));
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dateOfBirthController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = context.watch<UpdateApplicantProfileCubit>().state;

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownInput<String>(
              items: formState.titleItems,
              label: "Title",
              errorText: formState.errors['title'],
              value: formState.data['title'],
              onChanged: formState.isSubmitting
                  ? null
                  : (value) {
                      context
                          .read<UpdateApplicantProfileCubit>()
                          .fieldUpdated('title', value);
                    }),
          TextFieldInput(
            label: "First Name",
            controller: _firstNameController,
            errorText: formState.errors['first_name'],
            textCapitalization: TextCapitalization.words,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            enabled: !formState.isSubmitting,
          ),
          TextFieldInput(
            label: "Last Name",
            controller: _lastNameController,
            errorText: formState.errors['last_name'],
            textCapitalization: TextCapitalization.words,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            enabled: !formState.isSubmitting,
          ),
          DateInput(
            label: "D.O.B",
            controller: _dateOfBirthController,
            errorText: formState.errors['date_of_birth'],
            initialDate: formState.dateOfBirth,
            onChanged: (date) => context
                .read<UpdateApplicantProfileCubit>()
                .dateOfBirthUpdated(date),
            enabled: !formState.isSubmitting,
          ),
          TextFieldInput(
            label: "Telephone Number",
            controller: _telephoneController,
            errorText: formState.errors['telephone'],
            textCapitalization: TextCapitalization.none,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            enabled: !formState.isSubmitting,
          ),
          Divider(
            height: 50,
          ),
          DropdownInput<int>(
              items: formState.jobRoleItems,
              label: "Job Role",
              errorText: formState.errors['job_role_id'],
              value: formState.data['job_role_id'],
              onChanged: formState.isSubmitting
                  ? null
                  : (value) => context
                      .read<UpdateApplicantProfileCubit>()
                      .fieldUpdated('job_role_id', value)),
          DropdownInput<int>(
              items: formState.typeOfWorkItems,
              label: "Type of Work",
              errorText: formState.errors['type_of_work_id'],
              value: formState.data['type_of_work_id'],
              onChanged: formState.isSubmitting
                  ? null
                  : (value) => context
                      .read<UpdateApplicantProfileCubit>()
                      .fieldUpdated('type_of_work_id', value)),
          Divider(
            height: 50,
          ),
          ElevatedButton(
              onPressed: formState.isIdle ? _onSubmitPressed : null,
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

  _onSubmitPressed() async {
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
                  "Are you sure you want to update your profile?\n\nYour account may need to be re-approved before you will be allowed to apply to jobs.",
              dialogContext: dialogContext,
              onConfirm: () =>
                  context.read<UpdateApplicantProfileCubit>().submit());
        },
      );
    } else {
      context.read<UpdateApplicantProfileCubit>().submit();
    }
  }
}
