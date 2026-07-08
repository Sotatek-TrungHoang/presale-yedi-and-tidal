import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/adverts/bloc/list_adverts/list_adverts_state.dart';
import 'package:yedi_app/modules/adverts/bloc/list_bookings/list_applicant_bookings_bloc.dart';
import 'package:yedi_app/modules/adverts/models/advert_model.dart';
import 'package:yedi_app/pages/home/applicant/bookings/applicant_bookings_content.dart';
import 'package:yedi_app/ui/cubits/tab_controller_cubits.dart';
import 'package:yedi_app/ui/page_error.dart';
import 'package:yedi_app/ui/theme/app_theme.dart';

class ApplicantBookingsView extends StatelessWidget {
  const ApplicantBookingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final tabController =
        context.watch<ApplicantBookingsTabControllerCubit>().state;

    return SafeArea(
        child: Column(
      children: [
        TabBar(
          padding: EdgeInsets.symmetric(horizontal: 20),
          controller: tabController,
          tabs: [
            Tab(text: 'Confirmed'),
            Tab(text: 'Applications'),
          ],
        ),
        Expanded(
          child: TabBarView(controller: tabController, children: [
            BlocBuilder<ListApplicantConfirmedBookingsBloc, ListAdvertsState>(
                buildWhen: (previous, current) =>
                    previous.status != current.status,
                builder: (context, state) =>
                    _blocBuilder<ListApplicantConfirmedBookingsBloc>(
                        context, state, AdvertType.day_to_day)),
            BlocBuilder<ListApplicantAppliedToBookingsBloc, ListAdvertsState>(
                buildWhen: (previous, current) =>
                    previous.status != current.status,
                builder: (context, state) =>
                    _blocBuilder<ListApplicantAppliedToBookingsBloc>(
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
              error: 'No bookings found');
        } else {
          body = ApplicantBookingsContent<T>();
        }
    }

    return body;
  }
}
