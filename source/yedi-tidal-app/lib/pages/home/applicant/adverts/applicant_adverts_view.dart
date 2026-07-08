import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yedi_app/modules/adverts/bloc/list_adverts/list_adverts_bloc.dart';
import 'package:yedi_app/modules/adverts/bloc/list_adverts/list_adverts_state.dart';
import 'package:yedi_app/modules/adverts/models/advert_model.dart';
import 'package:yedi_app/pages/home/applicant/adverts/applicant_adverts_content.dart';
import 'package:yedi_app/ui/cubits/tab_controller_cubits.dart';
import 'package:yedi_app/ui/page_error.dart';
import 'package:yedi_app/ui/spacer.dart';
import 'package:yedi_app/ui/theme/app_theme.dart';

class ApplicantAdvertsView extends StatelessWidget {
  const ApplicantAdvertsView({super.key});

  @override
  Widget build(BuildContext context) {
    final tabController =
        context.watch<ApplicantAdvertsTabControllerCubit>().state;

    return SafeArea(
        child: Column(
      children: [
        TabBar(
          padding: EdgeInsets.symmetric(horizontal: 20),
          controller: tabController,
          tabs: [
            Tab(text: 'Day to Day Jobs'),
            Tab(text: 'Long-Term Jobs'),
          ],
        ),
        Expanded(
          child: TabBarView(controller: tabController, children: [
            BlocBuilder<ListApplicantDayToDayAdvertsBloc, ListAdvertsState>(
                buildWhen: (previous, current) =>
                    previous.status != current.status,
                builder: (context, state) =>
                    _blocBuilder<ListApplicantDayToDayAdvertsBloc>(
                        context, state, AdvertType.day_to_day)),
            BlocBuilder<ListApplicantLongTermAdvertsBloc, ListAdvertsState>(
                buildWhen: (previous, current) =>
                    previous.status != current.status,
                builder: (context, state) =>
                    _blocBuilder<ListApplicantLongTermAdvertsBloc>(
                        context, state, AdvertType.long_term)),
          ]),
        )
      ],
    ));
  }

  _blocBuilder<T extends StateStreamable<ListAdvertsState>>(
      BuildContext context, ListAdvertsState state, AdvertType advertType) {
    late Widget body;

    switch (state.status) {
      case ListAdvertsStatus.initial:
      case ListAdvertsStatus.loading:
      case ListAdvertsStatus.refreshing:
        body = Padding(
            padding: EdgeInsets.only(top: 56),
            child: Center(child: CircularProgressIndicator()));
      case ListAdvertsStatus.error:
        body = PageError(
          error: state.error!,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 56),
        );
      case ListAdvertsStatus.loaded:
        if (state.adverts.isEmpty) {
          body = PageError(
              icon: Icons.info,
              iconColour: appColours.accent,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 56),
              error: 'No jobs found');
        } else {
          body = ApplicantAdvertsContent<T>(advertType: advertType);
        }
    }

    return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(
            advertType == AdvertType.day_to_day
                ? 'What are Day to Day Jobs?'
                : 'What are Long Term Jobs?',
            textAlign: TextAlign.center,
            style: GoogleFonts.sora(
              fontSize: 18,
            ),
          ),
          VSpacer(10),
          Text(
            advertType == AdvertType.day_to_day
                ? AppLocalizations.of(context)!.dayToDayExplanationApplicants
                : AppLocalizations.of(context)!.longTermExplanationApplicants,
            textAlign: TextAlign.center,
            style: GoogleFonts.sora(
              fontSize: 14,
              height: 24 / 14,
            ),
          ),
          VSpacer(16),
          body,
        ]));
  }
}
