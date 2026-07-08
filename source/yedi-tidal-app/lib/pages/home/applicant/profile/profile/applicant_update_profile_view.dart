import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yedi_app/modules/authentication/bloc/authentication_bloc.dart';
import 'package:yedi_app/modules/authentication/bloc/authentication_event.dart';
import 'package:yedi_app/modules/common/cubits/generic_form_state.dart';
import 'package:yedi_app/modules/common/services/dropdown_service.dart';
import 'package:yedi_app/modules/profile/bloc/profile_blocks_cubit.dart';
import 'package:yedi_app/modules/profile/bloc/update_applicant_profile_cubit.dart';
import 'package:yedi_app/modules/profile/service/profile_service.dart';
import 'package:yedi_app/pages/home/applicant/profile/profile/applicant_update_profile_content.dart';
import 'package:yedi_app/ui/page_error.dart';
import 'package:yedi_app/util/toast.dart';

class ApplicantUpdateProfileView extends StatelessWidget {
  const ApplicantUpdateProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Update Profile'),
        ),
        body: BlocProvider(
          create: (context) {
            final user = context.read<AuthenticationBloc>().state.user;
            return UpdateApplicantProfileCubit(
                dropdownService: context.read<DropdownService>(),
                profileService: context.read<ApplicantProfileService>(),
                user: user!)
              ..init();
          },
          child: BlocConsumer<UpdateApplicantProfileCubit,
              UpdateApplicantProfileState>(
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: (context, state) {
              if (state.isSuccess) {
                showSuccessToast("Profile Updated");
                context.read<AuthenticationBloc>().add(RefreshUser());
                context.read<ProfileBlocksCubit>().loadBlocks();
                context.pop();
              }
            },
            buildWhen: (previous, current) => previous.status != current.status,
            builder: (context, state) {
              switch (state.status) {
                case FormStatus.loading:
                  return const Center(child: CircularProgressIndicator());
                case FormStatus.error:
                  return PageError(error: state.error ?? "An error occurred");
                default:
                  return ApplicantUpdateProfileContent();
              }
            },
          ),
        ));
  }
}
