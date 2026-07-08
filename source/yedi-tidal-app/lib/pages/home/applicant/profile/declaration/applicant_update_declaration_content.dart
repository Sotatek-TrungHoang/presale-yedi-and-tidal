import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yedi_app/modules/profile/bloc/update_declaration_cubit.dart';
import 'package:yedi_app/pages/sign_up/steps/ui/step_page_title.dart';
import 'package:yedi_app/ui/inputs/yes_no_input.dart';
import 'package:yedi_app/ui/spacer.dart';
import 'package:yedi_app/ui/theme/app_theme.dart';

class ApplicantUpdateDeclarationContent extends StatelessWidget {
  const ApplicantUpdateDeclarationContent({super.key});

  @override
  Widget build(BuildContext context) {
    final formState = context.watch<UpdateDeclarationCubit>().state;

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StepPageTitle(title: formState.declaration!.title),
          VSpacer(20),
          Text(formState.declaration!.description),
          VSpacer(20),
          Row(
            children: [
              Expanded(
                  child: ElevatedButton(
                      onPressed: () {
                        launchUrl(Uri.parse(formState.declaration!.upload.url));
                      },
                      child: Text("View PDF"))),
            ],
          ),
          VSpacer(20),
          YesNoInput(
              text: "I have read and agreed these terms",
              value: formState.agreed,
              onChanged: formState.isLoaded && !formState.locked
                  ? (value) {
                      context
                          .read<UpdateDeclarationCubit>()
                          .agreedChanged(value);
                    }
                  : null),
          Divider(
            height: 50,
          ),
          ElevatedButton(
              onPressed:
                  formState.isLoaded && !formState.locked && formState.agreed
                      ? () => context.read<UpdateDeclarationCubit>().submit()
                      : null,
              child:
                  Text(formState.isSubmitting ? "Confirming..." : "Confirm")),
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
}
