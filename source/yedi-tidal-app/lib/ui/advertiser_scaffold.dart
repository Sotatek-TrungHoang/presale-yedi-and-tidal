import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yedi_app/modules/adverts/bloc/list_adverts/list_adverts_bloc.dart';
import 'package:yedi_app/modules/adverts/bloc/list_adverts/list_adverts_event.dart';
import 'package:yedi_app/modules/adverts/bloc/list_applications/list_applications_bloc.dart';
import 'package:yedi_app/modules/adverts/bloc/list_applications/list_applications_event.dart';
import 'package:yedi_app/modules/documents/bloc/list_documents_bloc.dart';
import 'package:yedi_app/modules/documents/bloc/list_documents_event.dart';
import 'package:yedi_app/pages/home/advertiser/advertiser_home_page.dart';
import 'package:yedi_app/pages/home/advertiser/adverts/advertiser_adverts_page.dart';
import 'package:yedi_app/pages/home/advertiser/adverts/create_advert/create_advert_page.dart';
import 'package:yedi_app/pages/home/advertiser/applications/advertiser_applications_page.dart';
import 'package:yedi_app/pages/home/advertiser/settings/advertiser_settings_page.dart';
import 'package:yedi_app/pages/router.dart';
import 'package:yedi_app/ui/cubits/tab_controller_cubits.dart';

class AdvertiserScaffold extends StatelessWidget {
  final Widget child;
  final String? location;
  const AdvertiserScaffold(
      {super.key, required this.child, required this.location});

  @override
  Widget build(BuildContext context) {
    PreferredSizeWidget? appBar;
    Widget? floatingActionButton;
    int currentIndex = 0;

    switch (location) {
      case Routes.advertiserHome:
        currentIndex = 0;
        break;
      case Routes.advertiserAdverts:
        currentIndex = 1;
        floatingActionButton = FloatingActionButton.extended(
            onPressed: () {
              context.pushNamed(CreateAdvertPage.name);
            },
            icon: Icon(Icons.add_rounded),
            label: Text("Create Job"));
        break;
      case Routes.advertiserApplications:
        currentIndex = 2;
        break;
      case Routes.advertiserSettings:
        currentIndex = 3;
        break;
      default:
    }

    return Scaffold(
        appBar: appBar,
        floatingActionButton: floatingActionButton,
        body: child,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.cases_outlined),
              label: 'Jobs',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: 'Applications',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          onTap: (value) {
            switch (value) {
              case 0:
                context.goNamed(AdvertiserHomePage.name);
                break;
              case 1:
                if (currentIndex == 1) {
                  context
                      .read<ListAdvertiserDayToDayAdvertsBloc>()
                      .add(ListAdvertsRefreshed());
                  context
                      .read<ListAdvertiserLongTermAdvertsBloc>()
                      .add(ListAdvertsRefreshed());
                }

                context.goNamed(AdvertiserAdvertsPage.name);
                break;
              case 2:
                if (currentIndex == 2) {
                  context
                      .read<ListPendingApplicationsBloc>()
                      .add(ListApplicationsRefreshed());
                  context
                      .read<ListAcceptedApplicationsBloc>()
                      .add(ListApplicationsRefreshed());
                }

                context.goNamed(AdvertiserApplicationsPage.name);
                break;
              case 3:
                final tabController =
                    context.read<AdvertiserSettingsTabControllerCubit>().state;

                if (tabController.index == 1) {
                  context
                      .read<ListAdvertiserContractsBloc>()
                      .add(ListDocumentsRefreshed());
                } else if (tabController.index == 2) {
                  context
                      .read<ListInvoicesBloc>()
                      .add(ListDocumentsRefreshed());
                }

                context.goNamed(AdvertiserSettingsPage.name);
                break;
              default:
            }
          },
        ));
  }
}
