import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/adverts/bloc/list_advert_applications/list_advert_applications_bloc.dart';
import 'package:yedi_app/modules/adverts/bloc/list_advert_applications/list_advert_applications_event.dart';
import 'package:yedi_app/modules/adverts/bloc/list_advert_applications/list_advert_applications_state.dart';
import 'package:yedi_app/modules/adverts/services/advertiser_advert_service.dart';
import 'package:yedi_app/pages/home/advertiser/adverts/advert_detail/list_advert_applications/advertiser_list_advert_applications_content.dart';
import 'package:yedi_app/ui/page_error.dart';

class AdvertiserListAdvertApplicationsView extends StatelessWidget {
  const AdvertiserListAdvertApplicationsView(
      {required this.advertId, super.key});

  final int advertId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Applications'),
        ),
        body: MultiBlocProvider(
            providers: [
              BlocProvider(
                  create: (context) => ListAdvertApplicationsBloc(
                        advertId: advertId,
                        advertService: context.read<AdvertiserAdvertService>(),
                      )..add(ListAdvertApplicationsInitialised())),
            ],
            child: BlocBuilder<ListAdvertApplicationsBloc,
                ListAdvertApplicationsState>(
              buildWhen: (previous, current) =>
                  previous.status != current.status,
              builder: (context, state) {
                switch (state.status) {
                  case ListAdvertApplicationsStatus.initial:
                  case ListAdvertApplicationsStatus.loading:
                  case ListAdvertApplicationsStatus.refreshing:
                    return Center(child: CircularProgressIndicator());
                  case ListAdvertApplicationsStatus.error:
                    return PageError(error: state.error!);
                  case ListAdvertApplicationsStatus.loaded:
                    return AdvertiserListAdvertApplicantsContent();
                }
              },
            )));
  }
}
