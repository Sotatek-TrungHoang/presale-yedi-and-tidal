import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/l10n/app_localizations.dart';
import 'package:yedi_app/modules/authentication/models/auth_user_model.dart';
import 'package:yedi_app/modules/sign_up/bloc/pages/sign_up_pages_bloc.dart';
import 'package:yedi_app/modules/sign_up/bloc/pages/sign_up_pages_event.dart';
import 'package:yedi_app/modules/sign_up/bloc/pages/sign_up_pages_state.dart';
import 'package:yedi_app/pages/sign_up/steps/ui/account_type_selector.dart';
import 'package:yedi_app/pages/sign_up/steps/ui/step_page_title.dart';
import 'package:yedi_app/ui/spacer.dart';
import 'package:yedi_app/ui/theme/app_theme.dart';
import 'package:yedi_app/util/strings.dart';

class SignUpChooseAccountStep extends StatefulWidget {
  const SignUpChooseAccountStep({super.key});

  @override
  State<SignUpChooseAccountStep> createState() =>
      _SignUpChooseAccountStepState();
}

class _SignUpChooseAccountStepState extends State<SignUpChooseAccountStep> {
  UserType? _selectedType;

  @override
  void initState() {
    super.initState();

    final state = context.read<SignUpPagesBloc>().state;
    if (state is SignUpPagesLoaded) {
      _selectedType = state.userType;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          StepPageTitle(title: "Choose an Account"),
          VSpacer(20),
          Row(
            children: [
              Expanded(
                  child: AccountTypeSelector(
                label: AppLocalizations.of(context)!.applicant.toTitleCase(),
                icon: appIcons.applicant,
                selected: _selectedType == UserType.applicant,
                onPressed: () =>
                    setState(() => _selectedType = UserType.applicant),
              )),
              HSpacer(20),
              Expanded(
                  child: AccountTypeSelector(
                label: AppLocalizations.of(context)!.advertiser.toTitleCase(),
                icon: appIcons.advertiser,
                selected: _selectedType == UserType.advertiser,
                onPressed: () =>
                    setState(() => _selectedType = UserType.advertiser),
              )),
            ],
          ),
          Expanded(child: Container()),
          Row(
            children: [
              Expanded(
                  child: ElevatedButton(
                      onPressed: _selectedType == null
                          ? null
                          : () {
                              context.read<SignUpPagesBloc>().add(
                                  SignUpPagesUserTypeSelected(_selectedType!));
                            },
                      child: Text("Next Step"))),
            ],
          )
        ],
      ),
    );
  }
}
