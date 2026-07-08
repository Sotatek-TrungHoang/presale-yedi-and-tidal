import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yedi_app/modules/authentication/bloc/authentication_bloc.dart';
import 'package:yedi_app/modules/authentication/bloc/authentication_event.dart';
import 'package:yedi_app/modules/profile/bloc/profile_blocks_cubit.dart';
import 'package:yedi_app/modules/profile/bloc/update_declaration_cubit.dart';
import 'package:yedi_app/modules/profile/service/profile_service.dart';
import 'package:yedi_app/modules/sign_up/services/declaration_service.dart';
import 'package:yedi_app/pages/home/applicant/profile/declaration/applicant_update_declaration_content.dart';
import 'package:yedi_app/ui/page_error.dart';
import 'package:yedi_app/util/toast.dart';

class ApplicantUpdateDeclarationView extends StatelessWidget {
  const ApplicantUpdateDeclarationView(
      {super.key, required this.declarationId});

  final int declarationId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Update Declaration"),
        ),
        body: BlocProvider(
          create: (context) {
            final user = context.read<AuthenticationBloc>().state.user;
            return UpdateDeclarationCubit(
                declarationId: declarationId,
                declarationService: context.read<DeclarationService>(),
                profileService: context.read<ApplicantProfileService>(),
                user: user!)
              ..init();
          },
          child: BlocConsumer<UpdateDeclarationCubit, UpdateDeclarationState>(
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: (context, state) {
              if (state.isSuccess) {
                showSuccessToast("Declaration Updated");
                context.read<AuthenticationBloc>().add(RefreshUser());
                context.read<ProfileBlocksCubit>().loadBlocks();
                context.pop();
              }
            },
            buildWhen: (previous, current) => previous.status != current.status,
            builder: (context, state) {
              switch (state.status) {
                case UpdateDeclarationStatus.loading:
                  return const Center(child: CircularProgressIndicator());
                case UpdateDeclarationStatus.error:
                  return PageError(error: state.error ?? "An error occurred");
                default:
                  return ApplicantUpdateDeclarationContent();
              }
            },
          ),
        ));
  }
}
