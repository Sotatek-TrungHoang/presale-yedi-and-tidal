import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/adverts/bloc/advert_detail/advert_detail_bloc.dart';
import 'package:yedi_app/modules/adverts/bloc/advert_detail/advert_detail_event.dart';
import 'package:yedi_app/modules/adverts/bloc/advert_detail/advert_detail_state.dart';
import 'package:yedi_app/modules/adverts/bloc/apply_to_advert_cubit.dart';
import 'package:yedi_app/modules/adverts/bloc/cancel_application_cubit.dart';
import 'package:yedi_app/modules/adverts/bloc/list_adverts/list_adverts_event.dart';
import 'package:yedi_app/modules/adverts/bloc/list_bookings/list_applicant_bookings_bloc.dart';
import 'package:yedi_app/modules/adverts/services/applicant_advert_service.dart';
import 'package:yedi_app/pages/home/applicant/adverts/advert_detail/applicant_advert_detail_content.dart';
import 'package:yedi_app/ui/page_error.dart';
import 'package:yedi_app/util/toast.dart';

class ApplicantAdvertDetailView extends StatelessWidget {
  const ApplicantAdvertDetailView({required this.id, super.key});

  final int id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Job Detail'),
        ),
        body: MultiBlocProvider(
          providers: [
            BlocProvider(
                create: (context) => ApplicantAdvertDetailBloc(
                    advertService: context.read<ApplicantAdvertService>(),
                    id: id)
                  ..add(AdvertDetailInitialised())),
            BlocProvider(
                create: (context) => ApplyToAdvertCubit(
                    advertService: context.read<ApplicantAdvertService>(),
                    id: id)),
            BlocProvider(
                create: (context) => CancelApplicationCubit(
                    advertService: context.read<ApplicantAdvertService>(),
                    id: id)),
          ],
          child: MultiBlocListener(
            listeners: [
              BlocListener<ApplyToAdvertCubit, ApplyToAdvertCubitState>(
                listenWhen: (previous, current) =>
                    current.updatedAdvert != null &&
                    previous.updatedAdvert != current.updatedAdvert,
                listener: (context, state) {
                  showSuccessToast("Application submitted");
                  context
                      .read<ListApplicantAppliedToBookingsBloc>()
                      .add(ListAdvertsRefreshed());
                  context
                      .read<ApplicantAdvertDetailBloc>()
                      .add(AdvertDetailRefreshed(state.updatedAdvert!));
                },
              ),
              BlocListener<ApplyToAdvertCubit, ApplyToAdvertCubitState>(
                listenWhen: (previous, current) => current.error != null,
                listener: (context, state) {
                  showErrorToast(state.error!);
                },
              ),
              BlocListener<CancelApplicationCubit, CancelApplicationCubitState>(
                listenWhen: (previous, current) =>
                    current.updatedAdvert != null &&
                    previous.updatedAdvert != current.updatedAdvert,
                listener: (context, state) {
                  showSuccessToast("Application cancelled");
                  context
                      .read<ListApplicantAppliedToBookingsBloc>()
                      .add(ListAdvertsRefreshed());
                  context
                      .read<ApplicantAdvertDetailBloc>()
                      .add(AdvertDetailRefreshed(state.updatedAdvert!));
                },
              ),
              BlocListener<CancelApplicationCubit, CancelApplicationCubitState>(
                listenWhen: (previous, current) => current.error != null,
                listener: (context, state) {
                  showErrorToast(state.error!);
                },
              ),
            ],
            child: BlocBuilder<ApplicantAdvertDetailBloc, AdvertDetailState>(
              buildWhen: (previous, current) =>
                  previous.status != current.status,
              builder: (context, state) {
                switch (state.status) {
                  case AdvertDetailStatus.initial:
                  case AdvertDetailStatus.loading:
                    return Center(child: CircularProgressIndicator());
                  case AdvertDetailStatus.error:
                    return PageError(error: state.error!);
                  case AdvertDetailStatus.loaded:
                    return ApplicantAdvertDetailContent();
                }
              },
            ),
          ),
        ));
  }
}
