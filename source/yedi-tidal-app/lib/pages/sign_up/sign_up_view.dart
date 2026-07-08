import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:yedi_app/modules/authentication/bloc/authentication_bloc.dart';
import 'package:yedi_app/modules/authentication/bloc/authentication_event.dart';
import 'package:yedi_app/modules/authentication/services/authentication_service.dart';
import 'package:yedi_app/modules/sign_up/bloc/pages/sign_up_pages_bloc.dart';
import 'package:yedi_app/modules/sign_up/bloc/pages/sign_up_pages_event.dart';
import 'package:yedi_app/modules/sign_up/bloc/pages/sign_up_pages_state.dart';
import 'package:yedi_app/modules/sign_up/services/sign_up_service.dart';
import 'package:yedi_app/pages/landing/landing_page.dart';
import 'package:yedi_app/pages/sign_up/sign_up_content_error.dart';
import 'package:yedi_app/pages/sign_up/sign_up_content_initial.dart';
import 'package:yedi_app/pages/sign_up/sign_up_content_loaded.dart';
import 'package:yedi_app/pages/sign_up/sign_up_content_loading.dart';
import 'package:yedi_app/util/toast.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignUpPagesBloc(
          context.read<AuthenticationService>(), SignUpService())
        ..add(SignUpPagesInitialised(
            context.read<AuthenticationBloc>().state.user)),
      child: BlocBuilder<SignUpPagesBloc, SignUpPagesState>(
        buildWhen: (previous, current) =>
            previous.runtimeType != current.runtimeType,
        builder: (context, state) {
          Widget body;

          if (state is SignUpPagesLoading) {
            body = SignUpContentLoading();
          } else if (state is SignUpPagesError) {
            body = SignUpContentError(state.error);
          } else if (state is SignUpPagesLoaded) {
            body = SignUpContentLoaded();
          } else if (state is SignUpPagesInitial) {
            body = SignUpContentInitial();
          } else {
            throw Exception("Unknown state: $state");
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.signUpTitle),
              actions: [
                BlocListener<SignUpPagesBloc, SignUpPagesState>(
                    listenWhen: (previous, current) =>
                        previous is! SignUpPagesLoaded ||
                        (current is SignUpPagesLoaded &&
                            current.cancellingStatus !=
                                previous.cancellingStatus),
                    listener: (context, state) {
                      if (state is! SignUpPagesLoaded) {
                        return;
                      }

                      if (state.cancellationError != null) {
                        showErrorToast(state.cancellationError!);
                      }

                      if (state.cancellingStatus ==
                          CancellingStatus.cancelledSignUp) {
                        context
                            .read<AuthenticationBloc>()
                            .add(AuthenticationLogoutPressed());
                        context.goNamed(LandingPage.name);
                      } else if (state.cancellingStatus ==
                          CancellingStatus.cancelledPage) {
                        // context
                        //     .read<AuthenticationBloc>()
                        //     .add(AuthenticationLogoutPressed());
                        context
                            .read<SignUpPagesBloc>()
                            .add(SignUpPagesPreviousPagePressed());
                      }
                    },
                    child: IconButton(
                        icon: Icon(Icons.exit_to_app),
                        onPressed: () {
                          final user =
                              context.read<AuthenticationBloc>().state.user;
                          if (user == null) {
                            context.goNamed(LandingPage.name);
                          } else {
                            showDialog(
                              context: context,
                              builder: (BuildContext dialogContext) {
                                return AlertDialog(
                                  title: Text('Confirm'),
                                  content: Text(
                                      'Are you sure you want to cancel your sign up?'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text('No'),
                                      onPressed: () {
                                        Navigator.of(dialogContext).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: Text('Yes'),
                                      onPressed: () {
                                        Navigator.of(dialogContext).pop();
                                        context.read<SignUpPagesBloc>().add(
                                            SignUpPagesCancelTapped(
                                                user.type, true));
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        })),
              ],
            ),
            body: body,
          );
        },
      ),
    );
  }
}
