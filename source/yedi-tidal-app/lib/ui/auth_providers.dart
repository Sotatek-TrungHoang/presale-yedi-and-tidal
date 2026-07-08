import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/adverts/bloc/list_adverts/list_adverts_bloc.dart';
import 'package:yedi_app/modules/adverts/bloc/list_adverts/list_adverts_event.dart';
import 'package:yedi_app/modules/adverts/bloc/list_applications/list_applications_bloc.dart';
import 'package:yedi_app/modules/adverts/bloc/list_applications/list_applications_event.dart';
import 'package:yedi_app/modules/adverts/bloc/list_bookings/list_applicant_bookings_bloc.dart';
import 'package:yedi_app/modules/adverts/services/advertiser_advert_service.dart';
import 'package:yedi_app/modules/adverts/services/applicant_advert_service.dart';
import 'package:yedi_app/modules/common/services/account_service.dart';
import 'package:yedi_app/modules/common/services/change_email_service.dart';
import 'package:yedi_app/modules/common/services/change_password_service.dart';
import 'package:yedi_app/modules/documents/bloc/list_documents_bloc.dart';
import 'package:yedi_app/modules/documents/bloc/list_documents_event.dart';
import 'package:yedi_app/modules/documents/services/document_service.dart';
import 'package:yedi_app/modules/profile/bloc/profile_blocks_cubit.dart';
import 'package:yedi_app/modules/profile/service/profile_service.dart';
import 'package:yedi_app/ui/cubits/tab_controller_cubits.dart';
import 'package:yedi_app/ui/settings/cubits/change_email_form_cubit.dart';
import 'package:yedi_app/ui/settings/cubits/change_password_form_cubit.dart';
import 'package:yedi_app/ui/settings/cubits/delete_account_cubit.dart';

class ApplicantAuthProviders extends StatefulWidget {
  final Widget child;
  const ApplicantAuthProviders({super.key, required this.child});

  @override
  State<ApplicantAuthProviders> createState() => _ApplicantAuthProvidersState();
}

class _ApplicantAuthProvidersState extends State<ApplicantAuthProviders>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider(
        create: (context) =>
            ApplicantAdvertsTabControllerCubit(length: 2, vsync: this),
      ),
      BlocProvider(
        create: (context) =>
            ApplicantBookingsTabControllerCubit(length: 2, vsync: this),
      ),
      BlocProvider(
        create: (context) =>
            ApplicantSettingsTabControllerCubit(length: 3, vsync: this),
      ),
      BlocProvider(
          create: (context) => ProfileBlocksCubit(
              profileService: context.read<ApplicantProfileService>())
            ..loadBlocks()),
      BlocProvider(
          create: (context) => ListApplicantDayToDayAdvertsBloc(
                advertService: context.read<ApplicantAdvertService>(),
              )..add(ListAdvertsInitialised())),
      BlocProvider(
          create: (context) => ListApplicantLongTermAdvertsBloc(
                advertService: context.read<ApplicantAdvertService>(),
              )..add(ListAdvertsInitialised())),
      BlocProvider(
          create: (context) => ListApplicantConfirmedBookingsBloc(
                advertService: context.read<ApplicantAdvertService>(),
              )..add(ListAdvertsInitialised())),
      BlocProvider(
          create: (context) => ListApplicantAppliedToBookingsBloc(
                advertService: context.read<ApplicantAdvertService>(),
              )..add(ListAdvertsInitialised())),
      BlocProvider(
        create: (context) => ChangeEmailFormCubit(
            changeEmailService: context.read<ChangeEmailService>()),
      ),
      BlocProvider(
        create: (context) => ChangePasswordFormCubit(
            changePasswordService: context.read<ChangePasswordService>()),
      ),
      BlocProvider(
        create: (context) =>
            DeleteAccountCubit(accountService: context.read<AccountService>()),
      ),
      BlocProvider(
        create: (context) =>
            ListPayslipsBloc(documentService: context.read<DocumentService>())
              ..add(ListDocumentsInitialised()),
      ),
      BlocProvider(
        create: (context) => ListApplicantContractsBloc(
            documentService: context.read<DocumentService>())
          ..add(ListDocumentsInitialised()),
      ),
    ], child: widget.child);
  }
}

class AdvertiserAuthProviders extends StatefulWidget {
  final Widget child;
  const AdvertiserAuthProviders({super.key, required this.child});

  @override
  State<AdvertiserAuthProviders> createState() =>
      _AdvertiserAuthProvidersState();
}

class _AdvertiserAuthProvidersState extends State<AdvertiserAuthProviders>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider(
        create: (context) =>
            AdvertiserAdvertsTabControllerCubit(length: 2, vsync: this),
      ),
      BlocProvider(
        create: (context) =>
            AdvertiserApplicationsTabControllerCubit(length: 2, vsync: this),
      ),
      BlocProvider(
        create: (context) =>
            AdvertiserSettingsTabControllerCubit(length: 3, vsync: this),
      ),
      BlocProvider(
          create: (context) => ListAdvertiserDayToDayAdvertsBloc(
                advertService: context.read<AdvertiserAdvertService>(),
              )..add(ListAdvertsInitialised())),
      BlocProvider(
          create: (context) => ListAdvertiserLongTermAdvertsBloc(
                advertService: context.read<AdvertiserAdvertService>(),
              )..add(ListAdvertsInitialised())),
      BlocProvider(
          create: (context) => ListPendingApplicationsBloc(
              advertService: context.read<AdvertiserAdvertService>())
            ..add(ListApplicationsInitialised())),
      BlocProvider(
          create: (context) => ListAcceptedApplicationsBloc(
              advertService: context.read<AdvertiserAdvertService>())
            ..add(ListApplicationsInitialised())),
      BlocProvider(
        create: (context) => ChangeEmailFormCubit(
            changeEmailService: context.read<ChangeEmailService>()),
      ),
      BlocProvider(
        create: (context) => ChangePasswordFormCubit(
            changePasswordService: context.read<ChangePasswordService>()),
      ),
      BlocProvider(
        create: (context) =>
            DeleteAccountCubit(accountService: context.read<AccountService>()),
      ),
      BlocProvider(
        create: (context) =>
            ListInvoicesBloc(documentService: context.read<DocumentService>())
              ..add(ListDocumentsInitialised()),
      ),
      BlocProvider(
        create: (context) => ListAdvertiserContractsBloc(
            documentService: context.read<DocumentService>())
          ..add(ListDocumentsInitialised()),
      ),
    ], child: widget.child);
  }
}
