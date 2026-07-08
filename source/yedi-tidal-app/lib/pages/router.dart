import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yedi_app/modules/authentication/bloc/authentication_bloc.dart';
import 'package:yedi_app/modules/authentication/models/auth_user_model.dart';
import 'package:yedi_app/modules/authentication/services/authentication_service.dart';
import 'package:yedi_app/pages/home/advertiser/advertiser_home_page.dart';
import 'package:yedi_app/pages/home/advertiser/adverts/advert_detail/advertiser_advert_detail_page.dart';
import 'package:yedi_app/pages/home/advertiser/adverts/advert_detail/list_advert_applications/advertiser_list_advert_applications_page.dart';
import 'package:yedi_app/pages/home/advertiser/adverts/advertiser_adverts_page.dart';
import 'package:yedi_app/pages/home/advertiser/adverts/create_advert/create_advert_page.dart';
import 'package:yedi_app/pages/home/advertiser/adverts/create_advert/create_document/create_document_page.dart';
import 'package:yedi_app/pages/home/advertiser/applications/advertiser_applications_page.dart';
import 'package:yedi_app/pages/home/advertiser/hearted_applicants/hearted_applicants_page.dart';
import 'package:yedi_app/pages/home/advertiser/profile/address/advertiser_address_page.dart';
import 'package:yedi_app/pages/home/advertiser/profile/profile/advertiser_update_profile_page.dart';
import 'package:yedi_app/pages/home/advertiser/settings/advertiser_settings_page.dart';
import 'package:yedi_app/pages/home/applicant/adverts/advert_detail/applicant_advert_detail_page.dart';
import 'package:yedi_app/pages/home/applicant/adverts/applicant_adverts_page.dart';
import 'package:yedi_app/pages/home/applicant/applicant_home_page.dart';
import 'package:yedi_app/pages/home/applicant/bookings/applicant_bookings_page.dart';
import 'package:yedi_app/pages/home/applicant/profile/address/applicant_address_page.dart';
import 'package:yedi_app/pages/home/applicant/profile/compliance/applicant_update_compliance_page.dart';
import 'package:yedi_app/pages/home/applicant/profile/declaration/applicant_update_declaration_page.dart';
import 'package:yedi_app/pages/home/applicant/profile/evidence/applicant_update_evidence_page.dart';
import 'package:yedi_app/pages/home/applicant/profile/profile/applicant_update_profile_page.dart';
import 'package:yedi_app/pages/home/applicant/profile/qualifications/applicant_update_qualifications_page.dart';
import 'package:yedi_app/pages/home/applicant/profile/references/applicant_references_page.dart';
import 'package:yedi_app/pages/home/applicant/profile/right_to_work/applicant_update_right_to_work_page.dart';
import 'package:yedi_app/pages/home/applicant/settings/applicant_settings_page.dart';
import 'package:yedi_app/pages/landing/landing_page.dart';
import 'package:yedi_app/pages/login/forgot_password/forgot_password_page.dart';
import 'package:yedi_app/pages/login/login_page.dart';
import 'package:yedi_app/pages/login/reset_password/reset_password_page.dart';
import 'package:yedi_app/pages/logout/logout_page.dart';
import 'package:yedi_app/pages/sign_up/sign_up_page.dart';
import 'package:yedi_app/pages/sign_up/video_verification/video_verification_page.dart';
import 'package:yedi_app/pages/splash/splash_page.dart';
import 'package:yedi_app/ui/advertiser_scaffold.dart';
import 'package:yedi_app/ui/applicant_scaffold.dart';
import 'package:yedi_app/util/toast.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _applicantNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'applicant_navigator');
final _advertiserNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'advertiser_navigator');

abstract class Routes {
  static const String splash = '/';
  static const String landing = '/landing';
  static const String logout = '/logout';
  static const String signUp = '/landing/sign-up';
  static const String videoVerification = '/landing/sign-up/video-verification';
  static const String login = '/landing/login';
  static const String forgotPassword = '/landing/login/forgot-password';
  static const String resetPassword = '/landing/login/reset-password';
  static const String applicantHome = '/applicant';
  static const String applicantAdverts = '/applicant/adverts';
  static const String applicantAdvertDetail = '/applicant/adverts/:id';
  static const String applicantBookings = '/applicant/bookings';
  static const String applicantSettings = '/applicant/settings';
  static const String applicantUpdateProfile = '/advertiser/update-profile';
  static const String applicantUpdateCompliance =
      '/advertiser/update-compliance';
  static const String applicantAddress = '/applicant/address';
  static const String applicantUpdateQualifications =
      '/applicant/qualifications';
  static const String applicantEvidence = '/applicant/evidence/:id';
  static const String applicantDeclaration = '/applicant/declaration/:id';
  static const String applicantRightToWork = '/applicant/right-to-work';
  static const String applicantReferences = '/applicant/references';

  static const String advertiserHome = '/advertiser';
  static const String advertiserAdverts = '/advertiser/adverts';
  static const String advertiserAdvertsCreate = '/advertiser/adverts/create';
  static const String advertiserAdvertsCreateDocument =
      '/advertiser/adverts/create/document';
  static const String advertiserAdvertDetail = '/advertiser/adverts/:id';
  static const String advertiserAdvertApplications =
      '/advertiser/adverts/:id/applications';
  static const String advertiserApplications = '/advertiser/applications';
  static const String advertiserSettings = '/advertiser/settings';
  static const String advertiserAddress = '/advertiser/address';
  static const String advertiserUpdateProfile = '/advertiser/update-profile';
  static const String advertiserHeartedApplicants =
      '/advertiser/hearted-applicants';

  static List<String> unauthenticatedRoutes = [
    Routes.login,
    Routes.landing,
    Routes.login,
    Routes.forgotPassword,
    Routes.resetPassword,
    Routes.signUp,
  ];
}

final router = GoRouter(
  initialLocation: '/',
  navigatorKey: _rootNavigatorKey,
  debugLogDiagnostics: true,
  errorPageBuilder: (context, state) {
    return MaterialPage(child: Text(state.toString()));
  },
  redirect: (context, state) {
    final authState = context.read<AuthenticationBloc>().state;
    final user = authState.user;
    final path = state.fullPath ?? "";

    if (path == Routes.resetPassword) {
      if (state.uri.queryParameters['email'] == null ||
          state.uri.queryParameters['token'] == null) {
        showErrorToast("Invalid reset password link");
        return Routes.landing;
      }

      return null;
    }

    switch (authState.status) {
      case AuthenticationStatus.unknown:
        // stuck on splash screen until we know the auth state
        break;

      case AuthenticationStatus.authenticated:
        if (user!.applicant?.signUpCompletedAt == null &&
            user.advertiser?.signUpCompletedAt == null) {
          // needs to complete sign up
          if ([Routes.signUp, Routes.videoVerification].contains(path) ||
              Routes.unauthenticatedRoutes.contains(path) &&
                  path != Routes.landing &&
                  path != Routes.login) {
            return null;
          }

          return Routes.signUp;
        }

        if (path == Routes.splash ||
            Routes.unauthenticatedRoutes.contains(path)) {
          // user is authenticated but trying to access unauthenticated route

          if (user.type == UserType.advertiser) {
            return Routes.advertiserHome;
          }

          return Routes.applicantHome;
        }

        if (path == Routes.logout) {
          return null;
        }

        if (path.startsWith("/applicant") && user.type == UserType.advertiser) {
          showErrorToast("You do not have permission to access this page");
          return Routes.advertiserHome;
        }

        if (path.startsWith("/advertiser") && user.type == UserType.applicant) {
          showErrorToast("You do not have permission to access this page");
          return Routes.applicantHome;
        }

        break;

      case AuthenticationStatus.unauthenticated:
        if (!Routes.unauthenticatedRoutes.contains(path)) {
          return Routes.landing;
        }

        break;
    }

    return null;
  },
  routes: [
    GoRoute(
      path: Routes.splash,
      name: SplashPage.name,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: Routes.logout,
      name: LogoutPage.name,
      builder: (context, state) => const LogoutPage(),
    ),
    GoRoute(
        path: Routes.landing,
        name: LandingPage.name,
        builder: (context, state) => const LandingPage(),
        routes: [
          GoRoute(
              path: Routes.signUp.split('/').last,
              name: SignUpPage.name,
              pageBuilder: (context, state) =>
                  CupertinoPage(child: const SignUpPage()),
              routes: [
                GoRoute(
                    path: Routes.videoVerification.split('/').last,
                    name: VideoVerificationPage.name,
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: const VideoVerificationPage())),
              ]),
          GoRoute(
              path: Routes.login.split('/').last,
              name: LoginPage.name,
              pageBuilder: (context, state) =>
                  CupertinoPage(child: const LoginPage()),
              routes: [
                GoRoute(
                  path: Routes.forgotPassword.split('/').last,
                  name: ForgotPasswordPage.name,
                  pageBuilder: (context, state) =>
                      CupertinoPage(child: const ForgotPasswordPage()),
                ),
                GoRoute(
                  path: Routes.resetPassword.split('/').last,
                  name: ResetPasswordPage.name,
                  pageBuilder: (context, state) => CupertinoPage(
                      child: ResetPasswordPage(
                    email: state.uri.queryParameters['email']!,
                    token: state.uri.queryParameters['token']!,
                  )),
                ),
              ]),
        ]),
    ShellRoute(
        navigatorKey: _applicantNavigatorKey,
        builder: (context, state, child) =>
            ApplicantScaffold(location: state.fullPath, child: child),
        routes: [
          GoRoute(
              path: Routes.applicantHome,
              name: ApplicantHomePage.name,
              builder: (context, state) => const ApplicantHomePage(),
              routes: [
                GoRoute(
                    path: Routes.applicantAdverts.split('/').last,
                    name: ApplicantAdvertsPage.name,
                    pageBuilder: (context, state) =>
                        NoTransitionPage(child: ApplicantAdvertsPage()),
                    routes: [
                      GoRoute(
                        parentNavigatorKey: _rootNavigatorKey,
                        path: Routes.applicantAdvertDetail.split('/').last,
                        name: ApplicantAdvertDetailPage.name,
                        pageBuilder: (context, state) => CupertinoPage(
                            child: ApplicantAdvertDetailPage(
                                id: int.parse(state.pathParameters['id']!))),
                      ),
                    ]),
                GoRoute(
                    path: Routes.applicantBookings.split('/').last,
                    name: ApplicantBookingsPage.name,
                    pageBuilder: (context, state) =>
                        NoTransitionPage(child: ApplicantBookingsPage()),
                    routes: []),
                GoRoute(
                  path: Routes.applicantSettings.split('/').last,
                  name: ApplicantSettingsPage.name,
                  pageBuilder: (context, state) =>
                      NoTransitionPage(child: ApplicantSettingsPage()),
                ),
                GoRoute(
                  parentNavigatorKey: _rootNavigatorKey,
                  path: Routes.applicantUpdateProfile.split('/').last,
                  name: ApplicantUpdateProfilePage.name,
                  pageBuilder: (context, state) =>
                      CupertinoPage(child: ApplicantUpdateProfilePage()),
                ),
                GoRoute(
                  parentNavigatorKey: _rootNavigatorKey,
                  path: Routes.applicantUpdateCompliance.split('/').last,
                  name: ApplicantUpdateCompliancePage.name,
                  pageBuilder: (context, state) =>
                      CupertinoPage(child: ApplicantUpdateCompliancePage()),
                ),
                GoRoute(
                  parentNavigatorKey: _rootNavigatorKey,
                  path: Routes.applicantAddress.split('/').last,
                  name: ApplicantAddressPage.name,
                  pageBuilder: (context, state) =>
                      CupertinoPage(child: ApplicantAddressPage()),
                ),
                GoRoute(
                  parentNavigatorKey: _rootNavigatorKey,
                  path: Routes.applicantUpdateQualifications.split('/').last,
                  name: ApplicantUpdateQualificationsPage.name,
                  pageBuilder: (context, state) =>
                      CupertinoPage(child: ApplicantUpdateQualificationsPage()),
                ),
                GoRoute(
                  parentNavigatorKey: _rootNavigatorKey,
                  // path: Routes.applicantEvidence.split('/').last,
                  path: 'evidence/:id',
                  name: ApplicantUpdateEvidencePage.name,
                  pageBuilder: (context, state) => CupertinoPage(
                      child: ApplicantUpdateEvidencePage(
                          requiredEvidenceId:
                              int.parse(state.pathParameters['id']!))),
                ),
                GoRoute(
                  parentNavigatorKey: _rootNavigatorKey,
                  path: 'declaration/:id',
                  // path: Routes.applicantDeclaration.split('/').last,
                  name: ApplicantUpdateDeclarationPage.name,
                  pageBuilder: (context, state) => CupertinoPage(
                      child: ApplicantUpdateDeclarationPage(
                          declarationId:
                              int.parse(state.pathParameters['id']!))),
                ),
                GoRoute(
                  parentNavigatorKey: _rootNavigatorKey,
                  path: Routes.applicantRightToWork.split('/').last,
                  name: ApplicantUpdateRightToWorkPage.name,
                  pageBuilder: (context, state) =>
                      CupertinoPage(child: ApplicantUpdateRightToWorkPage()),
                ),
                GoRoute(
                  parentNavigatorKey: _rootNavigatorKey,
                  path: Routes.applicantReferences.split('/').last,
                  name: ApplicantReferencesPage.name,
                  pageBuilder: (context, state) =>
                      CupertinoPage(child: ApplicantReferencesPage()),
                ),
              ]),
        ]),
    ShellRoute(
        navigatorKey: _advertiserNavigatorKey,
        builder: (context, state, child) =>
            AdvertiserScaffold(location: state.fullPath, child: child),
        routes: [
          GoRoute(
              path: Routes.advertiserHome,
              name: AdvertiserHomePage.name,
              builder: (context, state) => const AdvertiserHomePage(),
              routes: [
                GoRoute(
                    path: Routes.advertiserAdverts.split('/').last,
                    name: AdvertiserAdvertsPage.name,
                    pageBuilder: (context, state) =>
                        NoTransitionPage(child: AdvertiserAdvertsPage()),
                    routes: [
                      GoRoute(
                          parentNavigatorKey: _rootNavigatorKey,
                          path: Routes.advertiserAdvertsCreate.split('/').last,
                          name: CreateAdvertPage.name,
                          pageBuilder: (context, state) =>
                              CupertinoPage(child: CreateAdvertPage()),
                          routes: [
                            GoRoute(
                              parentNavigatorKey: _rootNavigatorKey,
                              path: Routes.advertiserAdvertsCreateDocument
                                  .split('/')
                                  .last,
                              name: CreateDocumentPage.name,
                              pageBuilder: (context, state) =>
                                  CupertinoPage(child: CreateDocumentPage()),
                            )
                          ]),
                      GoRoute(
                          parentNavigatorKey: _rootNavigatorKey,
                          path: Routes.advertiserAdvertDetail.split('/').last,
                          name: AdvertiserAdvertDetailPage.name,
                          pageBuilder: (context, state) => CupertinoPage(
                              child: AdvertiserAdvertDetailPage(
                                  id: int.parse(state.pathParameters['id']!))),
                          routes: [
                            GoRoute(
                              parentNavigatorKey: _rootNavigatorKey,
                              path: Routes.advertiserAdvertApplications
                                  .split('/')
                                  .last,
                              name: AdvertiserListAdvertApplicationsPage.name,
                              pageBuilder: (context, state) => CupertinoPage(
                                  child: AdvertiserListAdvertApplicationsPage(
                                      advertId: int.parse(
                                          state.pathParameters['id']!))),
                            )
                          ])
                    ]),
                GoRoute(
                  path: Routes.advertiserApplications.split('/').last,
                  name: AdvertiserApplicationsPage.name,
                  pageBuilder: (context, state) =>
                      NoTransitionPage(child: AdvertiserApplicationsPage()),
                ),
                GoRoute(
                  path: Routes.advertiserSettings.split('/').last,
                  name: AdvertiserSettingsPage.name,
                  pageBuilder: (context, state) =>
                      NoTransitionPage(child: AdvertiserSettingsPage()),
                ),
                GoRoute(
                  parentNavigatorKey: _rootNavigatorKey,
                  path: Routes.advertiserAddress.split('/').last,
                  name: AdvertiserAddressPage.name,
                  pageBuilder: (context, state) =>
                      CupertinoPage(child: AdvertiserAddressPage()),
                ),
                GoRoute(
                  parentNavigatorKey: _rootNavigatorKey,
                  path: Routes.advertiserUpdateProfile.split('/').last,
                  name: AdvertiserUpdateProfilePage.name,
                  pageBuilder: (context, state) =>
                      CupertinoPage(child: AdvertiserUpdateProfilePage()),
                ),
                GoRoute(
                  parentNavigatorKey: _rootNavigatorKey,
                  path: Routes.advertiserHeartedApplicants.split('/').last,
                  name: HeartedApplicantsPage.name,
                  pageBuilder: (context, state) =>
                      CupertinoPage(child: HeartedApplicantsPage()),
                ),
              ]),
        ]),
  ],
);
