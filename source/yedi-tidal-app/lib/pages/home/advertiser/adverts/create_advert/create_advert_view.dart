import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yedi_app/modules/adverts/bloc/create_advert/create_advert_bloc.dart';
import 'package:yedi_app/modules/adverts/bloc/create_advert/create_advert_state.dart';
import 'package:yedi_app/modules/adverts/bloc/list_adverts/list_adverts_bloc.dart';
import 'package:yedi_app/modules/adverts/bloc/list_adverts/list_adverts_event.dart';
import 'package:yedi_app/modules/adverts/models/advert_model.dart';
import 'package:yedi_app/modules/adverts/services/advertiser_advert_service.dart';
import 'package:yedi_app/pages/home/advertiser/adverts/advert_detail/advertiser_advert_detail_page.dart';
import 'package:yedi_app/pages/home/advertiser/adverts/create_advert/create_advert_content.dart';
import 'package:yedi_app/util/toast.dart';

class CreateAdvertView extends StatelessWidget {
  const CreateAdvertView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Create Job"),
        ),
        body: BlocProvider(
          create: (context) => CreateAdvertBloc(
              advertiserAdvertService: context.read<AdvertiserAdvertService>()),
          child: MultiBlocListener(
            listeners: [
              BlocListener<CreateAdvertBloc, CreateAdvertState>(
                listenWhen: (previous, current) =>
                    previous.error != current.error,
                listener: (context, state) {
                  if (state.error != null) {
                    showErrorToast(state.error!);
                  }
                },
              ),
              BlocListener<CreateAdvertBloc, CreateAdvertState>(
                  listenWhen: (previous, current) =>
                      current.createdAdvert != null,
                  listener: (context, state) {
                    showSuccessToast("Job created successfully");

                    if (state.createdAdvert!.type == AdvertType.day_to_day) {
                      context
                          .read<ListAdvertiserDayToDayAdvertsBloc>()
                          .add(ListAdvertsRefreshed());
                    } else {
                      context
                          .read<ListAdvertiserLongTermAdvertsBloc>()
                          .add(ListAdvertsRefreshed());
                    }

                    context.goNamed(AdvertiserAdvertDetailPage.name,
                        pathParameters: {
                          "id": state.createdAdvert!.id.toString()
                        });
                  })
            ],
            child: CreateAdvertContent(),
          ),
        ));
  }
}
