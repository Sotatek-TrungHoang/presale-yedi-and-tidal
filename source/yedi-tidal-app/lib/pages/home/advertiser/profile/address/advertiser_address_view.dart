import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yedi_app/modules/authentication/bloc/authentication_bloc.dart';
import 'package:yedi_app/modules/authentication/bloc/authentication_event.dart';
import 'package:yedi_app/modules/common/services/dropdown_service.dart';
import 'package:yedi_app/modules/profile/bloc/update_address_cubit.dart';
import 'package:yedi_app/modules/profile/service/profile_service.dart';
import 'package:yedi_app/ui/profile/forms/address_form.dart';
import 'package:yedi_app/util/toast.dart';

class AdvertiserAddressView extends StatelessWidget {
  const AdvertiserAddressView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Update Address'),
        ),
        body: BlocProvider(
          create: (context) {
            final user = context.read<AuthenticationBloc>().state.user;
            return UpdateAddressCubit(
              userType: user!.type,
              dropdownService: context.read<DropdownService>(),
              profileService: context.read<AdvertiserProfileService>(),
            )..init(user.advertiser?.address);
          },
          child: BlocListener<UpdateAddressCubit, UpdateAddressState>(
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: (context, state) {
              if (state.isSuccess) {
                showSuccessToast("Address Updated");
                context.read<AuthenticationBloc>().add(RefreshUser());
                context.pop();
              }
            },
            child: AddressForm(),
          ),
        ));
  }
}
