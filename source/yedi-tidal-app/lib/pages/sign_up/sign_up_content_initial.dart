import 'package:flutter/material.dart';
import 'package:yedi_app/pages/sign_up/steps/sign_up_choose_account_step.dart';

class SignUpContentInitial extends StatelessWidget {
  const SignUpContentInitial({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          child: LinearProgressIndicator(
            value: 0,
          ),
        ),
        Expanded(
          child: SignUpChooseAccountStep(),
        ),
      ],
    );
  }
}
