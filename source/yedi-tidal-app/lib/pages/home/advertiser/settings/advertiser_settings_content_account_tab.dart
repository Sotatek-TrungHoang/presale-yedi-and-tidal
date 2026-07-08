import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yedi_app/pages/logout/logout_page.dart';
import 'package:yedi_app/ui/settings/change_email_form.dart';
import 'package:yedi_app/ui/settings/change_password_form.dart';
import 'package:yedi_app/ui/settings/delete_account_widget.dart';
import 'package:yedi_app/ui/spacer.dart';

class AdvertiserSettingsContentAccountTab extends StatelessWidget {
  const AdvertiserSettingsContentAccountTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Change Email Address",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          VSpacer(10),
          ChangeEmailForm(),
          Divider(
            height: 50,
          ),
          Text(
            "Change Password",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          VSpacer(10),
          ChangePasswordForm(),
          Divider(
            height: 50,
          ),
          Text(
            "Delete Account",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          VSpacer(10),
          Text(
              "Warning: This action cannot be undone. All your data will be lost."),
          VSpacer(10),
          DeleteAccountWidget(),
          Divider(
            height: 50,
          ),
          ElevatedButton(
              onPressed: () => context.goNamed(LogoutPage.name),
              child: Text("Log Out"))
        ],
      ),
    );
  }
}
