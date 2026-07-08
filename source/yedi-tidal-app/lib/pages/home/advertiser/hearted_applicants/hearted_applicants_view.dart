import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/l10n/app_localizations.dart';
import 'package:yedi_app/modules/hearted_applicants/bloc/hearted_applicants_bloc.dart';
import 'package:yedi_app/modules/hearted_applicants/bloc/hearted_applicants_event.dart';
import 'package:yedi_app/modules/hearted_applicants/bloc/hearted_applicants_state.dart';
import 'package:yedi_app/modules/hearted_applicants/services/hearted_applicants_service.dart';
import 'package:yedi_app/pages/home/advertiser/hearted_applicants/hearted_applicants_content.dart';
import 'package:yedi_app/ui/page_error.dart';
import 'package:yedi_app/ui/theme/app_theme.dart';
import 'package:yedi_app/util/strings.dart';

class HeartedApplicantsView extends StatelessWidget {
  const HeartedApplicantsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
              'Hearted ${AppLocalizations.of(context)!.applicants.toTitleCase()}'),
        ),
        body: BlocProvider(
          create: (context) => HeartedApplicantsBloc(
            heartedApplicantsService: context.read<HeartedApplicantsService>(),
          )..add(HeartedApplicantsInitialised()),
          child: BlocBuilder<HeartedApplicantsBloc, HeartedApplicantsState>(
            builder: (context, state) {
              switch (state.status) {
                case HeartedApplicantsStatus.initial:
                case HeartedApplicantsStatus.loading:
                case HeartedApplicantsStatus.refreshing:
                  return Padding(
                      padding: EdgeInsets.only(top: 56),
                      child: Center(child: CircularProgressIndicator()));
                case HeartedApplicantsStatus.error:
                  return PageError(
                    error: state.error!,
                  );
                case HeartedApplicantsStatus.loaded:
                  if (state.heartedApplicants.isEmpty) {
                    return PageError(
                      error:
                          "No ${AppLocalizations.of(context)!.applicants} found",
                      iconColour: appColours.accent,
                      icon: Icons.info,
                    );
                  }
                  return HeartedApplicantsContent();
              }
            },
          ),
        ));
  }
}
