import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/sign_up/bloc/pages/sign_up_pages_bloc.dart';
import 'package:yedi_app/modules/sign_up/bloc/pages/sign_up_pages_event.dart';
import 'package:yedi_app/modules/sign_up/bloc/pages/sign_up_pages_state.dart';
import 'package:yedi_app/modules/sign_up/models/sign_up_page_model.dart';
import 'package:yedi_app/pages/sign_up/steps/sign_up_account_created_step.dart';
import 'package:yedi_app/pages/sign_up/steps/sign_up_address_step.dart';
import 'package:yedi_app/pages/sign_up/steps/sign_up_advertiser_photo_upload_step.dart';
import 'package:yedi_app/pages/sign_up/steps/sign_up_choose_account_step.dart';
import 'package:yedi_app/pages/sign_up/steps/sign_up_compliance_completed_step.dart';
import 'package:yedi_app/pages/sign_up/steps/sign_up_compliance_step.dart';
import 'package:yedi_app/pages/sign_up/steps/sign_up_create_profile_step.dart';
import 'package:yedi_app/pages/sign_up/steps/sign_up_declaration_step.dart';
import 'package:yedi_app/pages/sign_up/steps/sign_up_evidence_step.dart';
import 'package:yedi_app/pages/sign_up/steps/sign_up_overview_step.dart';
import 'package:yedi_app/pages/sign_up/steps/sign_up_qualifications_step.dart';
import 'package:yedi_app/pages/sign_up/steps/sign_up_references_step.dart';
import 'package:yedi_app/pages/sign_up/steps/sign_up_right_to_work_step.dart';
import 'package:yedi_app/pages/sign_up/steps/sign_up_sign_up_complete_step.dart';

class SignUpContentLoaded extends StatelessWidget {
  const SignUpContentLoaded({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: context.select((SignUpPagesBloc bloc) =>
          bloc.state is SignUpPagesLoaded &&
          (bloc.state as SignUpPagesLoaded).currentPageIndex == 0),
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }

        final pagesState = context.read<SignUpPagesBloc>().state;
        if (pagesState is! SignUpPagesLoaded) {
          return;
        }

        final previousPageIndex = pagesState.currentPageIndex - 1;
        if (previousPageIndex < 0) {
          return;
        }

        final previousPage = pagesState.pages[previousPageIndex];
        if (previousPage.code != SignUpPageCode.create_profile) {
          context.read<SignUpPagesBloc>().add(SignUpPagesPreviousPagePressed());
          return;
        }

        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
              title: const Text("Are you sure?"),
              content: const Text(
                  "If you go back to the previous page, you will lose all the information you have entered so far."),
              actions: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(); // Close the dialog
                  },
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    context.read<SignUpPagesBloc>().add(
                        SignUpPagesCancelTapped(pagesState.userType, false));
                    Navigator.of(dialogContext).pop(); // Close the dialog
                  },
                  child: Text("Continue"),
                ),
              ]),
        );
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: BlocBuilder<SignUpPagesBloc, SignUpPagesState>(
              buildWhen: (previous, current) =>
                  previous is SignUpPagesLoaded &&
                  current is SignUpPagesLoaded &&
                  previous.currentPageIndex != current.currentPageIndex,
              builder: (context, state) {
                if (state is! SignUpPagesLoaded) {
                  return Container();
                }
                return LinearProgressIndicator(
                  value: state.currentPageIndex / state.pages.length,
                );
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<SignUpPagesBloc, SignUpPagesState>(
              buildWhen: (previous, current) =>
                  current is SignUpPagesLoaded &&
                  (previous is! SignUpPagesLoaded ||
                      (previous.currentPageIndex != current.currentPageIndex)),
              builder: (context, state) {
                if (state is! SignUpPagesLoaded) {
                  throw Exception("Unknown state: $state");
                }
                final page = state.currentPage;

                switch (page.code) {
                  case SignUpPageCode.choose_an_account:
                    return SignUpChooseAccountStep();
                  case SignUpPageCode.overview:
                    return SignUpOverviewStep();
                  case SignUpPageCode.create_profile:
                    return SignUpCreateProfileStep();
                  case SignUpPageCode.account_created:
                    return SignUpAccountCreatedStep();
                  case SignUpPageCode.compliance:
                    return SignUpComplianceStep();
                  case SignUpPageCode.address:
                    return SignUpAddressStep();
                  case SignUpPageCode.qualifications:
                    return SignUpQualificationsStep();
                  case SignUpPageCode.references:
                    return SignUpReferencesStep();
                  case SignUpPageCode.evidence:
                    return SignUpEvidenceStep(
                      key: ValueKey("evidence_step_${page.requiredEvidenceId}"),
                      requiredEvidenceId: page.requiredEvidenceId!,
                    );
                  case SignUpPageCode.declaration:
                    return SignUpDeclarationStep(
                      key: ValueKey("declaration_step_${page.declarationId}"),
                      declarationId: page.declarationId!,
                    );
                  case SignUpPageCode.right_to_work_declaration:
                    return SignUpRightToWorkStep();
                  case SignUpPageCode.compliance_completed:
                    return SignUpComplianceCompletedStep();
                  case SignUpPageCode.photo_upload:
                    return SignUpAdvertiserPhotoUploadStep();
                  case SignUpPageCode.sign_up_complete:
                    return SignUpSignUpCompleteStep();
                  // default:
                  //   return Text(page.title);
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
