import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/profile/bloc/profile_blocks_cubit.dart';
import 'package:yedi_app/pages/home/applicant/applicant_home_content.dart';
import 'package:yedi_app/util/toast.dart';

class ApplicantHomeView extends StatelessWidget {
  const ApplicantHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBlocksCubit, ProfileBlocksState>(
      listenWhen: (previous, current) => previous.error != current.error,
      listener: (context, state) {
        if (state.error != null) {
          showErrorToast(state.error!);
        }
      },
      child: ApplicantHomeContent(),
    );
  }
}
