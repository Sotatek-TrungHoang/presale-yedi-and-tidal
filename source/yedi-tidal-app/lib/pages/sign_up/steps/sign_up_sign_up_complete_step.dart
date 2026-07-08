import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/l10n/app_localizations.dart';
import 'package:yedi_app/modules/authentication/bloc/authentication_bloc.dart';
import 'package:yedi_app/modules/authentication/bloc/authentication_event.dart';
import 'package:yedi_app/modules/sign_up/bloc/complete_account/complete_account_bloc.dart';
import 'package:yedi_app/modules/sign_up/bloc/complete_account/complete_account_event.dart';
import 'package:yedi_app/modules/sign_up/bloc/complete_account/complete_account_state.dart';
import 'package:yedi_app/modules/sign_up/bloc/pages/sign_up_pages_bloc.dart';
import 'package:yedi_app/modules/sign_up/bloc/pages/sign_up_pages_event.dart';
import 'package:yedi_app/modules/sign_up/bloc/pages/sign_up_pages_state.dart';
import 'package:yedi_app/modules/sign_up/services/sign_up_service.dart';
import 'package:yedi_app/pages/sign_up/steps/ui/step_page_title.dart';
import 'package:yedi_app/ui/inputs/input_error.dart';
import 'package:yedi_app/ui/spacer.dart';
import 'package:yedi_app/ui/theme/app_theme.dart';

class SignUpSignUpCompleteStep extends StatelessWidget {
  const SignUpSignUpCompleteStep({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.read<SignUpPagesBloc>().state;
    if (state is! SignUpPagesLoaded) {
      throw Exception("Unknown state: $state");
    }

    final currentPage = state.currentPage;

    return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: BlocProvider(
            create: (context) => CompleteAccountBloc(
                userType: state.userType, signUpService: SignUpService()),
            child: BlocConsumer<CompleteAccountBloc, CompleteAccountState>(
                listenWhen: (previous, current) =>
                    current.status == CompleteAccountStatus.success,
                listener: (context, state) {
                  context
                      .read<AuthenticationBloc>()
                      .add(ReplaceUserModel(state.updatedUser!));
                  context
                      .read<SignUpPagesBloc>()
                      .add(SignUpPagesComplianceCompletedCompleted());
                },
                builder: (context, formState) {
                  return Column(
                    children: [
                      Icon(Icons.check_circle,
                          color: appColours.success, size: 48),
                      VSpacer(20),
                      StepPageTitle(title: currentPage.title),
                      VSpacer(18),
                      Text(
                        "Success, your account is now fully created. You can now create Jobs on ${AppLocalizations.of(context)!.appTitle}.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, height: 1.7),
                      ),
                      if (formState.error != null) ...[
                        VSpacer(6),
                        InputError(errorText: formState.error!),
                      ],
                      VSpacer(56),
                      Row(
                        children: [
                          Expanded(
                              child: ElevatedButton(
                                  onPressed: formState.isSubmitting
                                      ? null
                                      : () {
                                          context
                                              .read<CompleteAccountBloc>()
                                              .add(CompleteAccountSubmitted());
                                        },
                                  child: Text("View My Profile"))),
                        ],
                      )
                    ],
                  );
                })));
  }
}
