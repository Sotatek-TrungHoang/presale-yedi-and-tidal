import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/authentication/bloc/authentication_bloc.dart';
import 'package:yedi_app/modules/authentication/models/auth_user_model.dart';
import 'package:yedi_app/modules/profile/bloc/update_right_to_work_cubit.dart';
import 'package:yedi_app/ui/inputs/input_error.dart';
import 'package:yedi_app/ui/inputs/input_label.dart';
import 'package:yedi_app/ui/inputs/yes_no_input.dart';
import 'package:yedi_app/ui/profile/confirm_profile_uodate_alert.dart';
import 'package:yedi_app/ui/spacer.dart';
import 'package:yedi_app/ui/theme/app_theme.dart';

class ApplicantUpdateRightToWorkContent extends StatelessWidget {
  const ApplicantUpdateRightToWorkContent({super.key});

  @override
  Widget build(BuildContext context) {
    final formState = context.watch<UpdateRightToWorkCubit>().state;

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InputLabel(label: "Do you have the right to work in the UK?"),
          VSpacer(6),
          Row(
            children: [
              Expanded(
                  child: YesNoInput(
                      text: "Yes",
                      value: formState.rightToWorkUk == true,
                      onChanged: (_) => context
                          .read<UpdateRightToWorkCubit>()
                          .rightToWorkUkChanged(true))),
              HSpacer(20),
              Expanded(
                  child: YesNoInput(
                text: "No",
                value: formState.rightToWorkUk == false,
                onChanged: (_) => context
                    .read<UpdateRightToWorkCubit>()
                    .rightToWorkUkChanged(false),
              )),
            ],
          ),
          if (formState.errors['right_to_work_uk'] != null) ...[
            VSpacer(6),
            InputError(errorText: formState.errors['right_to_work_uk']!),
          ],
          VSpacer(24),
          InputLabel(label: "Do you require a visa to work in the UK?"),
          VSpacer(6),
          Row(
            children: [
              Expanded(
                  child: YesNoInput(
                text: "Yes",
                value: formState.requireVisaToWorkUk == true,
                onChanged: (_) => context
                    .read<UpdateRightToWorkCubit>()
                    .requireVisaToWorkUkChanged(true),
              )),
              HSpacer(20),
              Expanded(
                  child: YesNoInput(
                text: "No",
                value: formState.requireVisaToWorkUk == false,
                onChanged: (_) => context
                    .read<UpdateRightToWorkCubit>()
                    .requireVisaToWorkUkChanged(false),
              )),
            ],
          ),
          if (formState.errors['require_visa_to_work_uk'] != null) ...[
            VSpacer(6),
            InputError(errorText: formState.errors['require_visa_to_work_uk']!),
          ],
          VSpacer(24),
          InputLabel(
              label:
                  "Have you lived or worked outside of the UK for more than 6 months in the past 5 years?"),
          VSpacer(6),
          Row(
            children: [
              Expanded(
                  child: YesNoInput(
                text: "Yes",
                value: formState.livedOrWorkedOutsideUk6Months == true,
                onChanged: (_) => context
                    .read<UpdateRightToWorkCubit>()
                    .livedOrWorkedOutsideUk6MonthsChanged(true),
              )),
              HSpacer(20),
              Expanded(
                  child: YesNoInput(
                text: "No",
                value: formState.livedOrWorkedOutsideUk6Months == false,
                onChanged: (_) => context
                    .read<UpdateRightToWorkCubit>()
                    .livedOrWorkedOutsideUk6MonthsChanged(false),
              )),
            ],
          ),
          if (formState.errors['lived_or_worked_outside_uk_6_months'] !=
              null) ...[
            VSpacer(6),
            InputError(
                errorText:
                    formState.errors['lived_or_worked_outside_uk_6_months']!),
          ],
          VSpacer(24),
          InputLabel(
              label:
                  "As you are applying to work in a regulated activity (working with children), please confirm, subject to filtering, if you have any spent or unspent criminal convictions or prosecutions pending?"),
          VSpacer(6),
          Row(
            children: [
              Expanded(
                  child: YesNoInput(
                text: "Yes",
                value: formState.hasCriminalConvictionsOrProsecutionsPending ==
                    true,
                onChanged: (_) => context
                    .read<UpdateRightToWorkCubit>()
                    .hasCriminalConvictionsOrProsecutionsPendingChanged(true),
              )),
              HSpacer(20),
              Expanded(
                  child: YesNoInput(
                text: "No",
                value: formState.hasCriminalConvictionsOrProsecutionsPending ==
                    false,
                onChanged: (_) => context
                    .read<UpdateRightToWorkCubit>()
                    .hasCriminalConvictionsOrProsecutionsPendingChanged(false),
              )),
            ],
          ),
          if (formState
                  .errors['has_criminal_convictions_or_prosecutions_pending'] !=
              null) ...[
            VSpacer(6),
            InputError(
                errorText: formState.errors[
                    'has_criminal_convictions_or_prosecutions_pending']!),
          ],
          Divider(
            height: 50,
          ),
          ElevatedButton(
              onPressed:
                  formState.isIdle ? () => _onSubmitPressed(context) : null,
              child: Text(formState.isSubmitting
                  ? "Updating Declaration..."
                  : "Update Declaration")),
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
                  "Are you sure you want to update your right to work declaration?\n\nYour account may need to be re-approved before you will be allowed to apply to jobs.",
              dialogContext: dialogContext,
              onConfirm: () => context.read<UpdateRightToWorkCubit>().submit());
        },
      );
    } else {
      context.read<UpdateRightToWorkCubit>().submit();
    }
  }
}
