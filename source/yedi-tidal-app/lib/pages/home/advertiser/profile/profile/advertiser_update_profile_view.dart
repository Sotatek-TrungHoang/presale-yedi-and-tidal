import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yedi_app/modules/authentication/bloc/authentication_bloc.dart';
import 'package:yedi_app/modules/authentication/bloc/authentication_event.dart';
import 'package:yedi_app/modules/common/services/dropdown_service.dart';
import 'package:yedi_app/modules/profile/bloc/update_advertiser_profile_cubit.dart';
import 'package:yedi_app/modules/profile/service/profile_service.dart';
import 'package:yedi_app/pages/home/advertiser/profile/profile/advertiser_update_profile_content.dart';
import 'package:yedi_app/util/toast.dart';

class AdvertiserUpdateProfileView extends StatelessWidget {
  const AdvertiserUpdateProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Update Profile'),
        ),
        body: BlocProvider(
          create: (context) {
            final user = context.read<AuthenticationBloc>().state.user;
            return UpdateAdvertiserProfileCubit(
                dropdownService: context.read<DropdownService>(),
                profileService: context.read<AdvertiserProfileService>(),
                advertiser: user!.advertiser!);
          },
          child: BlocListener<UpdateAdvertiserProfileCubit,
              UpdateAdvertiserProfileState>(
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: (context, state) {
              if (state.isSuccess) {
                showSuccessToast("Profile Updated");
                context.read<AuthenticationBloc>().add(RefreshUser());
                context.pop();
              }
            },
            child: AdvertiserUpdateProfileContent(),
          ),
        ));
  }
}
