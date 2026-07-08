import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/adverts/services/advertiser_advert_service.dart';

enum DeleteAdvertState { initial, deleting, deleted, error }

class DeleteAdvertCubit extends Cubit<DeleteAdvertState> {
  final int id;
  final AdvertiserAdvertService advertService;

  DeleteAdvertCubit({required this.advertService, required this.id})
      : super(DeleteAdvertState.initial);

  delete() async {
    emit(DeleteAdvertState.deleting);
    try {
      await advertService.delete(id);
      emit(DeleteAdvertState.deleted);
    } catch (e) {
      emit(DeleteAdvertState.error);
    }
  }
}
