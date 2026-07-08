import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yedi_app/modules/authentication/bloc/authentication_bloc.dart';
import 'package:yedi_app/modules/authentication/models/auth_user_model.dart';
import 'package:yedi_app/pages/home/advertiser/hearted_applicants/hearted_applicants_page.dart';
import 'package:yedi_app/pages/home/advertiser/profile/address/advertiser_address_page.dart';
import 'package:yedi_app/pages/home/advertiser/profile/profile/advertiser_update_profile_page.dart';
import 'package:yedi_app/ui/profile/profile_avatar.dart';
import 'package:yedi_app/ui/profile/profile_button.dart';
import 'package:yedi_app/ui/spacer.dart';
import 'package:yedi_app/ui/theme/app_theme.dart';
import 'package:yedi_app/util/dates.dart';

class AdvertiserHomeContent extends StatelessWidget {
  const AdvertiserHomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthenticationBloc bloc) => bloc.state.user);

    if (user == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return SafeArea(
        child: SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                          onPressed: () {
                            context.pushNamed(HeartedApplicantsPage.name);
                          },
                          iconSize: 30,
                          icon: Icon(Icons.favorite_outline)),
                    ],
                  ),
                ),
              ),
              ProfileAvatar(
                  initials: user.advertiser!.schoolInitials,
                  uploadModel: user.advertiser!.photograph),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Tooltip(
                        message:
                            "Compliance Status: ${user.advertiser!.complianceStatusLabel}",
                        waitDuration: Duration(milliseconds: 200),
                        child: Stack(
                          children: [
                            Icon(
                              user.advertiser!.complianceStatus ==
                                      AdvertiserComplianceStatus.pending
                                  ? Icons.shield_outlined
                                  : Icons.shield_rounded,
                              size: 34,
                            ),
                            if (user.advertiser!.complianceStatus ==
                                    AdvertiserComplianceStatus.compliant ||
                                user.advertiser!.complianceStatus ==
                                    AdvertiserComplianceStatus.non_compliant)
                              Positioned(
                                left: 0,
                                right: 0,
                                top: 6,
                                child: Center(
                                  child: Icon(
                                    user.advertiser!.complianceStatus ==
                                            AdvertiserComplianceStatus.compliant
                                        ? Icons.check
                                        : Icons.close,
                                    size: 21,
                                    color: appColours.background,
                                  ),
                                ),
                              )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          VSpacer(20),
          Text(
            user.advertiser!.name,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          if (user.advertiser?.address != null) ...[
            VSpacer(6),
            Text(
              "${user.advertiser!.address!.townCity}, ${user.advertiser!.address!.postcode}",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Color(0xFF555555)),
            ),
          ],
          VSpacer(6),
          Text(
            "Member since ${user.createdAt.formatDate()}",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          VSpacer(20),
          GridView.count(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            childAspectRatio: 19 / 12,
            crossAxisCount: 2,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            children: [
              ProfileButton(
                label: "Profile",
                icon: Icons.person_add_sharp,
                onTap: () =>
                    context.pushNamed(AdvertiserUpdateProfilePage.name),
              ),
              ProfileButton(
                label: "Address",
                icon: Icons.place,
                onTap: () => context.pushNamed(AdvertiserAddressPage.name),
              ),
            ],
          ),
        ],
      ),
    ));
  }
}
