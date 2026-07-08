import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yedi_app/modules/adverts/bloc/advert_detail/advert_detail_bloc.dart';
import 'package:yedi_app/modules/adverts/bloc/advert_detail/advert_detail_event.dart';
import 'package:yedi_app/modules/adverts/bloc/advert_detail/advert_detail_state.dart';
import 'package:yedi_app/modules/adverts/bloc/delete_advert_cubit.dart';
import 'package:yedi_app/modules/adverts/bloc/list_adverts/list_adverts_bloc.dart';
import 'package:yedi_app/modules/adverts/bloc/list_adverts/list_adverts_event.dart';
import 'package:yedi_app/modules/adverts/services/advertiser_advert_service.dart';
import 'package:yedi_app/pages/home/advertiser/adverts/advert_detail/advertiser_advert_detail_content.dart';
import 'package:yedi_app/ui/page_error.dart';
import 'package:yedi_app/util/toast.dart';

class AdvertiserAdvertDetailView extends StatelessWidget {
  const AdvertiserAdvertDetailView({required this.id, super.key});

  final int id;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) => AdvertiserAdvertDetailBloc(
                advertService: context.read<AdvertiserAdvertService>(), id: id)
              ..add(AdvertDetailInitialised())),
        BlocProvider(
          create: (context) => DeleteAdvertCubit(
            id: id,
            advertService: context.read<AdvertiserAdvertService>(),
          ),
        )
      ],
      child: BlocBuilder<AdvertiserAdvertDetailBloc, AdvertDetailState>(
        buildWhen: (previous, current) => previous.status != current.status,
        builder: (context, state) {
          Widget body;

          switch (state.status) {
            case AdvertDetailStatus.initial:
            case AdvertDetailStatus.loading:
              body = Center(child: CircularProgressIndicator());
              break;
            case AdvertDetailStatus.error:
              body = PageError(error: state.error!);
              break;
            case AdvertDetailStatus.loaded:
              body = AdvertiserAdvertDetailContent();
              break;
          }

          return Scaffold(
              appBar: AppBar(
                title: Text('Job Detail'),
                actions: state.advert?.canDelete == true
                    ? [
                        BlocConsumer<DeleteAdvertCubit, DeleteAdvertState>(
                          listenWhen: (previous, current) =>
                              previous != current,
                          listener: (context, state) {
                            switch (state) {
                              case DeleteAdvertState.error:
                                showErrorToast("Failed to delete job");
                                break;
                              case DeleteAdvertState.deleted:
                                context
                                    .read<ListAdvertiserDayToDayAdvertsBloc>()
                                    .add(ListAdvertsAdvertDeleted(id));
                                context
                                    .read<ListAdvertiserLongTermAdvertsBloc>()
                                    .add(ListAdvertsAdvertDeleted(id));
                                showSuccessToast("Job deleted");
                                context.pop();
                                break;
                              default:
                            }
                          },
                          builder: (context, deleteState) {
                            return IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: deleteState ==
                                      DeleteAdvertState.deleting
                                  ? null
                                  : () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext dialogContext) {
                                          return AlertDialog(
                                            title: Text("Confirm Deletion"),
                                            content: Text(
                                                "Are you sure you want to delete this job?"),
                                            actions: [
                                              OutlinedButton(
                                                onPressed: () {
                                                  Navigator.of(dialogContext)
                                                      .pop(); // Close the dialog
                                                },
                                                child: Text("Cancel"),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.of(dialogContext)
                                                      .pop(); // Close the dialog
                                                  context
                                                      .read<DeleteAdvertCubit>()
                                                      .delete();
                                                },
                                                child: Text("Approve"),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                            );
                          },
                        )
                      ]
                    : null,
              ),
              body: body);
        },
      ),
    );
  }
}
