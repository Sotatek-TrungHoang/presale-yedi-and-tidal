import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:yedi_app/modules/documents/bloc/list_documents_bloc.dart';
import 'package:yedi_app/modules/documents/bloc/list_documents_event.dart';
import 'package:yedi_app/modules/documents/bloc/list_documents_state.dart';
import 'package:yedi_app/modules/documents/models/payslip_model.dart';
import 'package:yedi_app/ui/page_error.dart';
import 'package:yedi_app/ui/theme/app_theme.dart';

class ApplicantSettingsContentPayslipsTab extends StatelessWidget {
  const ApplicantSettingsContentPayslipsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ListPayslipsBloc, ListDocumentsState<PayslipModel>>(
      builder: (context, state) {
        switch (state.status) {
          case ListDocumentsStatus.initial:
          case ListDocumentsStatus.loading:
          case ListDocumentsStatus.refreshing:
            return Padding(
                padding: EdgeInsets.only(top: 56),
                child: Center(child: CircularProgressIndicator()));
          case ListDocumentsStatus.error:
            return PageError(
              error: state.error!,
            );
          case ListDocumentsStatus.loaded:
            if (state.documents.isEmpty) {
              return PageError(
                error: "No payslips found",
                iconColour: appColours.accent,
                icon: Icons.info,
              );
            }
            return RefreshIndicator(
              onRefresh: () async => context.read<ListPayslipsBloc>().add(
                    ListDocumentsRefreshed(),
                  ),
              child: ListView.separated(
                physics: AlwaysScrollableScrollPhysics(),
                itemCount: state.documents.length,
                separatorBuilder: (context, index) => Divider(),
                itemBuilder: (context, index) {
                  final payslip = state.documents[index];
                  return ListTile(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    title: Text(
                      payslip.title,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(payslip.payslipNumber,
                        style: TextStyle(fontSize: 14)),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      launchUrlString(payslip.upload.url);
                    },
                  );
                },
              ),
            );
          // return AdvertiserApplicationsContent<T>();
        }
      },
    );
  }
}
