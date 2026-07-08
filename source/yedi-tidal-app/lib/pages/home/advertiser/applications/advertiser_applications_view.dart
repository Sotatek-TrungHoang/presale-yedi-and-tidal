import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/adverts/bloc/list_applications/list_applications_bloc.dart';
import 'package:yedi_app/modules/adverts/bloc/list_applications/list_applications_event.dart';
import 'package:yedi_app/modules/adverts/bloc/list_applications/list_applications_state.dart';
import 'package:yedi_app/modules/adverts/models/application_model.dart';
import 'package:yedi_app/pages/home/advertiser/applications/advertiser_applications_content.dart';
import 'package:yedi_app/ui/cubits/tab_controller_cubits.dart';
import 'package:yedi_app/ui/page_error.dart';
import 'package:yedi_app/ui/theme/app_theme.dart';

class AdvertiserApplicationsView extends StatelessWidget {
  const AdvertiserApplicationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final tabController =
        context.watch<AdvertiserApplicationsTabControllerCubit>().state;

    return SafeArea(
        child: Column(
      children: [
        TabBar(
          padding: EdgeInsets.symmetric(horizontal: 20),
          controller: tabController,
          tabs: [
            Tab(text: 'Pending'),
            Tab(text: 'Accepted'),
          ],
        ),
        Expanded(
          child: TabBarView(controller: tabController, children: [
            BlocBuilder<ListPendingApplicationsBloc, ListApplicationsState>(
                buildWhen: (previous, current) =>
                    previous.status != current.status ||
                    previous.applications.length != current.applications.length,
                builder: (context, state) =>
                    _blocBuilder<ListPendingApplicationsBloc>(
                        context, state, ApplicationStatus.pending)),
            BlocBuilder<ListAcceptedApplicationsBloc, ListApplicationsState>(
                buildWhen: (previous, current) =>
                    previous.status != current.status ||
                    previous.applications.length != current.applications.length,
                builder: (context, state) =>
                    _blocBuilder<ListAcceptedApplicationsBloc>(
                        context, state, ApplicationStatus.accepted)),
          ]),
        )
      ],
    ));
  }

  _blocBuilder<T extends ListApplicationsBloc>(BuildContext context,
      ListApplicationsState state, ApplicationStatus status) {
    switch (state.status) {
      case ListApplicationsStatus.initial:
      case ListApplicationsStatus.loading:
      case ListApplicationsStatus.refreshing:
        return Padding(
            padding: EdgeInsets.only(top: 56),
            child: Center(child: CircularProgressIndicator()));
      case ListApplicationsStatus.error:
        return _pageRefreshIndicator<T>(
            context,
            PageError(
              error: state.error!,
            ));
      case ListApplicationsStatus.loaded:
        if (state.applications.isEmpty) {
          final String text;
          switch (status) {
            case ApplicationStatus.pending:
              text = 'No pending applications found';
              break;
            case ApplicationStatus.accepted:
              text = 'No accepted applications found';
              break;
            default:
              text = 'No applications';
          }

          return _pageRefreshIndicator<T>(
              context,
              PageError(
                error: text,
                iconColour: appColours.accent,
                icon: Icons.info,
              ));
        } else {
          return AdvertiserApplicationsContent<T>();
        }
    }
  }

  _pageRefreshIndicator<T extends ListApplicationsBloc>(
      BuildContext context, Widget child) {
    return RefreshIndicator(
      onRefresh: () async => context.read<T>().add(ListApplicationsRefreshed()),
      child: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: SizedBox(height: constraints.maxHeight, child: child),
        );
      }),
    );
  }
}
