import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/pages/home/applicant/settings/applicant_settings_content_account_tab.dart';
import 'package:yedi_app/pages/home/applicant/settings/applicant_settings_content_contracts_tab.dart';
import 'package:yedi_app/pages/home/applicant/settings/applicant_settings_content_payslips_tab.dart';
import 'package:yedi_app/ui/cubits/tab_controller_cubits.dart';

class ApplicantSettingsView extends StatelessWidget {
  const ApplicantSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final tabController =
        context.watch<ApplicantSettingsTabControllerCubit>().state;

    return SafeArea(
        child: Column(
      children: [
        TabBar(
          padding: EdgeInsets.symmetric(horizontal: 20),
          controller: tabController,
          tabs: [
            Tab(text: 'Account'),
            Tab(text: 'Contracts'),
            Tab(text: 'Payslips'),
          ],
        ),
        Expanded(
          child: TabBarView(controller: tabController, children: [
            ApplicantSettingsContentAccountTab(),
            ApplicantSettingsContentContractsTab(),
            ApplicantSettingsContentPayslipsTab(),
          ]),
        )
      ],
    ));
  }
}
