import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/adverts/models/application_model.dart';
import 'package:yedi_app/modules/adverts/services/advertiser_advert_service.dart';
import 'package:yedi_app/modules/api/api_exceptions.dart';

class AcceptApplicationCubitState {
  final bool isAccepting;
  final String? error;
  final ApplicationModel? updatedApplication;

  AcceptApplicationCubitState(
      {required this.isAccepting, this.error, this.updatedApplication});
}

class AcceptApplicationCubit extends Cubit<AcceptApplicationCubitState> {
  final int applicationId;
  final AdvertiserAdvertService advertService;

  AcceptApplicationCubit(
      {required this.advertService, required this.applicationId})
      : super(AcceptApplicationCubitState(isAccepting: false));

  acceptApplication() async {
    emit(AcceptApplicationCubitState(isAccepting: true));
    try {
      final updatedApplication =
          await advertService.acceptApplication(applicationId);
      emit(AcceptApplicationCubitState(
          isAccepting: false, updatedApplication: updatedApplication));
    } on APIException catch (e) {
      emit(AcceptApplicationCubitState(
          isAccepting: false, error: e.message ?? "Something went wrong"));
    } catch (e) {
      emit(
          AcceptApplicationCubitState(isAccepting: false, error: e.toString()));
    }
  }
}
