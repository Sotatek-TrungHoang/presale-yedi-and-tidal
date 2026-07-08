import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/adverts/models/application_model.dart';
import 'package:yedi_app/modules/adverts/services/advertiser_advert_service.dart';
import 'package:yedi_app/modules/api/api_exceptions.dart';

class RateApplicationCubitState {
  final bool isRating;
  final String? error;
  final ApplicationModel? updatedApplication;

  RateApplicationCubitState(
      {required this.isRating, this.error, this.updatedApplication});
}

class RateApplicationCubit extends Cubit<RateApplicationCubitState> {
  final int applicationId;
  final AdvertiserAdvertService advertService;

  RateApplicationCubit(
      {required this.advertService, required this.applicationId})
      : super(RateApplicationCubitState(isRating: false));

  rateApplication(int rating) async {
    emit(RateApplicationCubitState(isRating: true));
    try {
      final updatedApplication =
          await advertService.rateApplication(applicationId, rating);
      emit(RateApplicationCubitState(
          isRating: false, updatedApplication: updatedApplication));
    } on APIException catch (e) {
      emit(RateApplicationCubitState(
          isRating: false, error: e.message ?? "Something went wrong"));
    } catch (e) {
      emit(RateApplicationCubitState(isRating: false, error: e.toString()));
    }
  }
}
