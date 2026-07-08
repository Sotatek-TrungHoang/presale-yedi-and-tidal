import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/sign_up/bloc/pages/sign_up_pages_bloc.dart';
import 'package:yedi_app/modules/sign_up/bloc/pages/sign_up_pages_event.dart';
import 'package:yedi_app/modules/sign_up/bloc/pages/sign_up_pages_state.dart';
import 'package:yedi_app/pages/sign_up/steps/ui/step_page_title.dart';
import 'package:yedi_app/ui/spacer.dart';
import 'package:yedi_app/ui/theme/app_theme.dart';

class SignUpAccountCreatedStep extends StatelessWidget {
  const SignUpAccountCreatedStep({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: BlocBuilder<SignUpPagesBloc, SignUpPagesState>(
          buildWhen: (previous, current) => false,
          builder: (context, state) {
            if (state is! SignUpPagesLoaded) {
              throw Exception("Unknown state: $state");
            }

            final currentPage = state.currentPage;

            return Column(
              children: [
                Icon(Icons.check_circle, color: appColours.success, size: 48),
                VSpacer(20),
                StepPageTitle(title: currentPage.title),
                VSpacer(18),
                Text(
                  "Success, your account has now been created. \nYou can now progress onto compliance.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, height: 1.7),
                ),
                VSpacer(56),
                Row(
                  children: [
                    Expanded(
                        child: ElevatedButton(
                            onPressed: () {
                              context
                                  .read<SignUpPagesBloc>()
                                  .add(SignUpPagesCreateProfileCompleted());
                            },
                            child: Text("Next Step"))),
                  ],
                )
              ],
            );
          },
        ));
  }
}
