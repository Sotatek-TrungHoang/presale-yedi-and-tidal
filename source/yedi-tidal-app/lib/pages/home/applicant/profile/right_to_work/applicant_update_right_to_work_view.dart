import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yedi_app/modules/authentication/bloc/authentication_bloc.dart';
import 'package:yedi_app/modules/authentication/bloc/authentication_event.dart';
import 'package:yedi_app/modules/profile/bloc/profile_blocks_cubit.dart';
import 'package:yedi_app/modules/profile/bloc/update_right_to_work_cubit.dart';
import 'package:yedi_app/modules/profile/service/profile_service.dart';
import 'package:yedi_app/pages/home/applicant/profile/right_to_work/applicant_update_right_to_work_content.dart';
import 'package:yedi_app/ui/page_error.dart';
import 'package:yedi_app/util/toast.dart';

class ApplicantUpdateRightToWorkView extends StatelessWidget {
  const ApplicantUpdateRightToWorkView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Update Right To Work Declaration'),
        ),
        body: BlocProvider(
          create: (context) {
            final user = context.read<AuthenticationBloc>().state.user;
            return UpdateRightToWorkCubit(
                profileService: context.read<ApplicantProfileService>(),
                user: user!);
          },
          child: BlocConsumer<UpdateRightToWorkCubit, UpdateRightToWorkState>(
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: (context, state) {
              if (state.isSuccess) {
                showSuccessToast("Right To Work Declaration Updated");
                context.read<AuthenticationBloc>().add(RefreshUser());
                context.read<ProfileBlocksCubit>().loadBlocks();
                context.pop();
              }
            },
            buildWhen: (previous, current) => previous.status != current.status,
            builder: (context, state) {
              switch (state.status) {
                case UpdateRightToWorkStatus.error:
                  return PageError(error: state.error ?? "An error occurred");
                default:
                  return ApplicantUpdateRightToWorkContent();
              }
            },
          ),
        ));
  }
}
