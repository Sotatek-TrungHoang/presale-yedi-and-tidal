import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yedi_app/modules/adverts/bloc/list_adverts/list_adverts_bloc.dart';
import 'package:yedi_app/modules/adverts/bloc/list_adverts/list_adverts_event.dart';
import 'package:yedi_app/modules/adverts/bloc/list_bookings/list_applicant_bookings_bloc.dart';
import 'package:yedi_app/modules/documents/bloc/list_documents_bloc.dart';
import 'package:yedi_app/modules/documents/bloc/list_documents_event.dart';
import 'package:yedi_app/pages/home/applicant/adverts/applicant_adverts_page.dart';
import 'package:yedi_app/pages/home/applicant/applicant_home_page.dart';
import 'package:yedi_app/pages/home/applicant/bookings/applicant_bookings_page.dart';
import 'package:yedi_app/pages/home/applicant/settings/applicant_settings_page.dart';
import 'package:yedi_app/pages/router.dart';
import 'package:yedi_app/ui/cubits/tab_controller_cubits.dart';

class ApplicantScaffold extends StatelessWidget {
  final Widget child;
  final String? location;
  const ApplicantScaffold(
      {super.key, required this.child, required this.location});

  @override
  Widget build(BuildContext context) {
    PreferredSizeWidget? appBar;
    int currentIndex = 0;

    switch (location) {
      case Routes.applicantHome:
        currentIndex = 0;
        break;
      case Routes.applicantAdverts:
        currentIndex = 1;
        break;
      case Routes.applicantBookings:
        currentIndex = 2;
        break;
      case Routes.applicantSettings:
        currentIndex = 3;
        break;
      default:
    }

    return Scaffold(
        appBar: appBar,
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
              label: 'Bookings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          onTap: (value) {
            switch (value) {
              case 0:
                context.goNamed(ApplicantHomePage.name);
                break;
              case 1:
                if (currentIndex == 1) {
                  context
                      .read<ListApplicantDayToDayAdvertsBloc>()
                      .add(ListAdvertsRefreshed());
                  context
                      .read<ListApplicantLongTermAdvertsBloc>()
                      .add(ListAdvertsRefreshed());
                }

                context.goNamed(ApplicantAdvertsPage.name);
                break;
              case 2:
                if (currentIndex == 2) {
                  context
                      .read<ListApplicantConfirmedBookingsBloc>()
                      .add(ListAdvertsRefreshed());
                  context
                      .read<ListApplicantAppliedToBookingsBloc>()
                      .add(ListAdvertsRefreshed());
                }

                context.goNamed(ApplicantBookingsPage.name);
                break;
              case 3:
                final tabController =
                    context.read<ApplicantSettingsTabControllerCubit>().state;

                if (tabController.index == 1) {
                  context
                      .read<ListApplicantContractsBloc>()
                      .add(ListDocumentsRefreshed());
                } else if (tabController.index == 2) {
                  context
                      .read<ListPayslipsBloc>()
                      .add(ListDocumentsRefreshed());
                }

                context.goNamed(ApplicantSettingsPage.name);
                break;
              default:
            }
          },
        ));
  }
}
