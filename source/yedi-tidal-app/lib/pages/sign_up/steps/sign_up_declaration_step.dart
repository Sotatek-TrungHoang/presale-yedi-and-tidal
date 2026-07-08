import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yedi_app/modules/authentication/bloc/authentication_bloc.dart';
import 'package:yedi_app/modules/authentication/bloc/authentication_event.dart';
import 'package:yedi_app/modules/sign_up/bloc/declaration/declaration_bloc.dart';
import 'package:yedi_app/modules/sign_up/bloc/declaration/declaration_event.dart';
import 'package:yedi_app/modules/sign_up/bloc/declaration/declaration_state.dart';
import 'package:yedi_app/modules/sign_up/bloc/pages/sign_up_pages_bloc.dart';
import 'package:yedi_app/modules/sign_up/bloc/pages/sign_up_pages_event.dart';
import 'package:yedi_app/modules/sign_up/bloc/pages/sign_up_pages_state.dart';
import 'package:yedi_app/modules/sign_up/services/declaration_service.dart';
import 'package:yedi_app/modules/sign_up/services/sign_up_service.dart';
import 'package:yedi_app/pages/sign_up/steps/ui/step_page_title.dart';
import 'package:yedi_app/ui/inputs/yes_no_input.dart';
import 'package:yedi_app/ui/page_error.dart';
import 'package:yedi_app/ui/spacer.dart';

class SignUpDeclarationStep extends StatelessWidget {
  const SignUpDeclarationStep({required this.declarationId, super.key});

  final int declarationId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => DeclarationBloc(
              declarationId: declarationId,
              signUpService: SignUpService(),
              declarationService: DeclarationService(),
            )..add(DeclarationInitialised(
                context.read<AuthenticationBloc>().state.user)),
        child: BlocConsumer<DeclarationBloc, DeclarationState>(
          listenWhen: (previous, current) =>
              previous.status != current.status &&
              current.status == DeclarationStatus.success,
          listener: (context, state) {
            final updatedUser = state.updatedUser;
            if (updatedUser == null) {
              return;
            }

            context
                .read<AuthenticationBloc>()
                .add(ReplaceUserModel(updatedUser));
            context
                .read<SignUpPagesBloc>()
                .add(SignUpPagesDeclarationCompleted());
          },
          builder: (context, state) {
            if (state.status == DeclarationStatus.error) {
              return PageError(
                error: state.error ?? "An error occurred",
              );
            }
            return _SignUpDeclarationStepWidget();
          },
        ));
  }
}

class _SignUpDeclarationStepWidget extends StatefulWidget {
  const _SignUpDeclarationStepWidget();

  @override
  State<_SignUpDeclarationStepWidget> createState() =>
      _SignUpCreateProfileStepLoadedWidgetState();
}

class _SignUpCreateProfileStepLoadedWidgetState
    extends State<_SignUpDeclarationStepWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<SignUpPagesBloc>().state;
    if (state is! SignUpPagesLoaded) {
      throw Exception("Unknown state: $state");
    }

    final currentPage = state.currentPage;
    final declaration = currentPage.declaration!;

    return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: BlocBuilder<DeclarationBloc, DeclarationState>(
            builder: (context, formState) {
          return Column(
            children: [
              StepPageTitle(title: currentPage.title),
              VSpacer(20),
              Text(declaration.description),
              VSpacer(20),
              Row(
                children: [
                  Expanded(
                      child: ElevatedButton(
                          onPressed: () {
                            launchUrl(Uri.parse(declaration.upload.url));
                          },
                          child: Text("View PDF"))),
                ],
              ),
              VSpacer(20),
              YesNoInput(
                  text: "I have read and agreed these terms",
                  value: formState.agreed,
                  onChanged: formState.isSubmitting
                      ? null
                      : (value) {
                          context
                              .read<DeclarationBloc>()
                              .add(DeclarationAgreedChanged(value));
                        }),
              VSpacer(56),
              Row(
                children: [
                  Expanded(
                      child: ElevatedButton(
                          onPressed: !formState.canSubmit
                              ? null
                              : () {
                                  context
                                      .read<DeclarationBloc>()
                                      .add(DeclarationSubmitted());
                                },
                          child: Text(formState.isSubmitting
                              ? "Processing..."
                              : "Next Step"))),
                ],
              )
            ],
          );
        }));
  }
}
