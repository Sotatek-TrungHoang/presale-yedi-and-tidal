import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/adverts/models/application_model.dart';
import 'package:yedi_app/modules/adverts/services/advertiser_advert_service.dart';
import 'package:yedi_app/modules/api/api_exceptions.dart';

class DeclineApplicationCubitState {
  final bool isDeclining;
  final String? error;
  final ApplicationModel? updatedApplication;

  DeclineApplicationCubitState(
      {required this.isDeclining, this.error, this.updatedApplication});
}

class DeclineApplicationCubit extends Cubit<DeclineApplicationCubitState> {
  final int applicationId;
  final AdvertiserAdvertService advertService;

  DeclineApplicationCubit(
      {required this.advertService, required this.applicationId})
      : super(DeclineApplicationCubitState(isDeclining: false));

  declineApplication() async {
    emit(DeclineApplicationCubitState(isDeclining: true));
    try {
      final updatedApplication =
          await advertService.declineApplication(applicationId);
      emit(DeclineApplicationCubitState(
          isDeclining: false, updatedApplication: updatedApplication));
    } on APIException catch (e) {
      emit(DeclineApplicationCubitState(
          isDeclining: false, error: e.message ?? "Something went wrong"));
    } catch (e) {
      emit(DeclineApplicationCubitState(
          isDeclining: false, error: e.toString()));
    }
  }
}
