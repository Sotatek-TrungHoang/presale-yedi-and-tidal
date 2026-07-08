import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/adverts/models/advert_model.dart';
import 'package:yedi_app/modules/adverts/services/applicant_advert_service.dart';
import 'package:yedi_app/modules/api/api_exceptions.dart';

class CancelApplicationCubitState {
  final bool isCancelling;
  final String? error;
  final AdvertModel? updatedAdvert;

  CancelApplicationCubitState(
      {required this.isCancelling, this.error, this.updatedAdvert});
}

class CancelApplicationCubit extends Cubit<CancelApplicationCubitState> {
  final int id;
  final ApplicantAdvertService advertService;

  CancelApplicationCubit({required this.advertService, required this.id})
      : super(CancelApplicationCubitState(isCancelling: false));

  cancel() async {
    emit(CancelApplicationCubitState(isCancelling: true));
    try {
      final updatedAdvert = await advertService.cancelApplication(id);
      emit(CancelApplicationCubitState(
          isCancelling: false, updatedAdvert: updatedAdvert));
    } on APIException catch (e) {
      emit(CancelApplicationCubitState(
          isCancelling: false, error: e.message ?? "Something went wrong"));
    } catch (e) {
      emit(CancelApplicationCubitState(
          isCancelling: false, error: e.toString()));
    }
  }
}
