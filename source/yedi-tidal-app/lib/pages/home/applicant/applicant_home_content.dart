import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yedi_app/modules/authentication/bloc/authentication_bloc.dart';
import 'package:yedi_app/modules/authentication/models/auth_user_model.dart';
import 'package:yedi_app/modules/profile/bloc/profile_blocks_cubit.dart';
import 'package:yedi_app/modules/profile/model/profile_block_model.dart';
import 'package:yedi_app/pages/home/applicant/profile/address/applicant_address_page.dart';
import 'package:yedi_app/pages/home/applicant/profile/compliance/applicant_update_compliance_page.dart';
import 'package:yedi_app/pages/home/applicant/profile/declaration/applicant_update_declaration_page.dart';
import 'package:yedi_app/pages/home/applicant/profile/evidence/applicant_update_evidence_page.dart';
import 'package:yedi_app/pages/home/applicant/profile/profile/applicant_update_profile_page.dart';
import 'package:yedi_app/pages/home/applicant/profile/qualifications/applicant_update_qualifications_page.dart';
import 'package:yedi_app/pages/home/applicant/profile/references/applicant_references_page.dart';
import 'package:yedi_app/pages/home/applicant/profile/right_to_work/applicant_update_right_to_work_page.dart';
import 'package:yedi_app/ui/profile/profile_avatar.dart';
import 'package:yedi_app/ui/profile/profile_button.dart';
import 'package:yedi_app/ui/spacer.dart';
import 'package:yedi_app/ui/theme/app_theme.dart';
import 'package:yedi_app/util/dates.dart';

class ApplicantHomeContent extends StatelessWidget {
  const ApplicantHomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthenticationBloc bloc) => bloc.state.user)!;

    return SafeArea(
        child: RefreshIndicator(
      onRefresh: () => context.read<ProfileBlocksCubit>().loadBlocks(),
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star,
                          color: appColours.accent,
                          size: 30,
                        ),
                        HSpacer(5),
                        Text(
                          user.applicant!.rating?.toStringAsFixed(1) ?? "-",
                          style: TextStyle(fontSize: 16),
                        )
                      ],
                    ),
                  ),
                ),
                ProfileAvatar(
                  initials: user.initials,
                  uploadModel: user.applicant?.photograph,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Tooltip(
                          message:
                              "Compliance Status: ${user.applicant!.complianceStatusLabel}",
                          waitDuration: Duration(milliseconds: 200),
                          child: Stack(
                            children: [
                              Icon(
                                user.applicant!.complianceStatus ==
                                        ApplicantComplianceStatus
                                            .pending_approval
                                    ? Icons.shield_outlined
                                    : Icons.shield_rounded,
                                size: 34,
                              ),
                              if (user.applicant!.complianceStatus ==
                                      ApplicantComplianceStatus.compliant ||
                                  user.applicant!.complianceStatus ==
                                      ApplicantComplianceStatus.non_compliant)
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  top: 6,
                                  child: Center(
                                    child: Icon(
                                      user.applicant!.complianceStatus ==
                                              ApplicantComplianceStatus
                                                  .compliant
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
              user.fullName,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            if (user.applicant?.address != null) ...[
              VSpacer(6),
              Text(
                user.applicant!.address!.townCity,
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
            BlocBuilder<ProfileBlocksCubit, ProfileBlocksState>(
              builder: (context, blockState) {
                return GridView.count(
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
                          context.pushNamed(ApplicantUpdateProfilePage.name),
                    ),
                    ProfileButton(
                      label: "Compliance",
                      icon: Icons.shield,
                      onTap: () =>
                          context.pushNamed(ApplicantUpdateCompliancePage.name),
                    ),
                    ProfileButton(
                      label: "Address",
                      icon: Icons.place,
                      onTap: () => context.pushNamed(ApplicantAddressPage.name),
                    ),
                    ProfileButton(
                      label: "Qualifications",
                      icon: Icons.verified_outlined,
                      onTap: () => context
                          .pushNamed(ApplicantUpdateQualificationsPage.name),
                    ),
                    if (blockState.isLoading)
                      ...List.generate(6, (_) => ProfileButtonSkeleton())
                    else
                      ...blockState.blocks.map((block) {
                        return ProfileButton(
                            label: block.title,
                            icon: block.type.icon,
                            required: !block.completed,
                            onTap: () => () {
                                  switch (block.type) {
                                    case ProfileBlockType.evidence:
                                      if (block.evidenceId == null) {
                                        return null;
                                      }
                                      context.pushNamed(
                                          ApplicantUpdateEvidencePage.name,
                                          pathParameters: {
                                            "id": block.evidenceId.toString()
                                          });
                                      break;
                                    case ProfileBlockType.declaration:
                                      if (block.declarationId == null) {
                                        return null;
                                      }

                                      context.pushNamed(
                                          ApplicantUpdateDeclarationPage.name,
                                          pathParameters: {
                                            "id": block.declarationId.toString()
                                          });

                                      break;
                                    case ProfileBlockType.rtw_declaration:
                                      context.pushNamed(
                                          ApplicantUpdateRightToWorkPage.name);
                                      break;
                                    case ProfileBlockType.references:
                                      context.pushNamed(
                                          ApplicantReferencesPage.name);
                                      break;
                                  }
                                }());
                      }),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    ));
  }
}
