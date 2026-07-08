import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:yedi_app/modules/adverts/services/advertiser_advert_service.dart';
import 'package:yedi_app/modules/adverts/services/applicant_advert_service.dart';
import 'package:yedi_app/modules/authentication/bloc/authentication_bloc.dart';
import 'package:yedi_app/modules/authentication/bloc/authentication_state.dart';
import 'package:yedi_app/modules/authentication/models/auth_user_model.dart';
import 'package:yedi_app/modules/authentication/services/authentication_service.dart';
import 'package:yedi_app/modules/common/services/account_service.dart';
import 'package:yedi_app/modules/common/services/change_email_service.dart';
import 'package:yedi_app/modules/common/services/change_password_service.dart';
import 'package:yedi_app/modules/common/services/dropdown_service.dart';
import 'package:yedi_app/modules/common/services/settings_service.dart';
import 'package:yedi_app/modules/documents/services/document_service.dart';
import 'package:yedi_app/modules/hearted_applicants/services/hearted_applicants_service.dart';
import 'package:yedi_app/modules/profile/service/profile_service.dart';
import 'package:yedi_app/modules/profile/service/references_service.dart';
import 'package:yedi_app/modules/sign_up/services/declaration_service.dart';
import 'package:yedi_app/modules/sign_up/services/evidence_service.dart';
import 'package:yedi_app/l10n/app_localizations.dart';
import 'package:yedi_app/pages/router.dart';
import 'package:yedi_app/ui/auth_providers.dart';
import 'package:yedi_app/ui/theme/app_theme.dart';

class App extends StatelessWidget {
  final AuthenticationService authenticationService;
  final AuthUserModel? initialUser;
  const App({
    required this.authenticationService,
    required this.initialUser,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: authenticationService),
          RepositoryProvider.value(value: AccountService()),
          RepositoryProvider.value(value: AdvertiserAdvertService()),
          RepositoryProvider.value(value: AdvertiserProfileService()),
          RepositoryProvider.value(value: ApplicantAdvertService()),
          RepositoryProvider.value(value: ApplicantProfileService()),
          RepositoryProvider.value(value: ChangeEmailService()),
          RepositoryProvider.value(value: ChangePasswordService()),
          RepositoryProvider.value(value: DeclarationService()),
          RepositoryProvider.value(value: DocumentService()),
          RepositoryProvider.value(value: DropdownService()),
          RepositoryProvider.value(value: EvidenceService()),
          RepositoryProvider.value(value: HeartedApplicantsService()),
          RepositoryProvider.value(value: ReferencesService()),
          RepositoryProvider.value(value: SettingsService()),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              lazy: false,
              create: (_) => AuthenticationBloc(
                  authenticationService: authenticationService,
                  initialUser: initialUser),
            ),
          ],
          child: const AppView(),
        ));
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          router.refresh();
        },
        listenWhen: (previous, current) {
          return previous.status != current.status ||
              previous.user != current.user;
        },
        buildWhen: (previous, current) =>
            previous.user?.type != current.user?.type,
        builder: (context, state) {
          final body = MaterialApp.router(
            routerConfig: router,
            restorationScopeId: 'yedi',
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', 'GB'),
            ],
            onGenerateTitle: (BuildContext context) =>
                AppLocalizations.of(context)!.appTitle,
            theme: appTheme,
          );

          if (state.user?.type == UserType.applicant) {
            return ApplicantAuthProviders(child: body);
          } else if (state.user?.type == UserType.advertiser) {
            return AdvertiserAuthProviders(child: body);
          }

          return body;
        });
  }
}
