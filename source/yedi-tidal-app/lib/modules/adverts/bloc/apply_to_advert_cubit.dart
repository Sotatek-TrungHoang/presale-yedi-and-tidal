import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/adverts/models/advert_model.dart';
import 'package:yedi_app/modules/adverts/services/applicant_advert_service.dart';
import 'package:yedi_app/modules/api/api_exceptions.dart';

class ApplyToAdvertCubitState {
  final bool isApplying;
  final String? error;
  final AdvertModel? updatedAdvert;

  ApplyToAdvertCubitState(
      {required this.isApplying, this.error, this.updatedAdvert});
}

class ApplyToAdvertCubit extends Cubit<ApplyToAdvertCubitState> {
  final int id;
  final ApplicantAdvertService advertService;

  ApplyToAdvertCubit({required this.advertService, required this.id})
      : super(ApplyToAdvertCubitState(isApplying: false));

  apply() async {
    emit(ApplyToAdvertCubitState(isApplying: true));
    try {
      final updatedAdvert = await advertService.apply(id);
      emit(ApplyToAdvertCubitState(
          isApplying: false, updatedAdvert: updatedAdvert));
    } on APIException catch (e) {
      emit(ApplyToAdvertCubitState(
          isApplying: false, error: e.message ?? "Something went wrong"));
    } catch (e) {
      emit(ApplyToAdvertCubitState(isApplying: false, error: e.toString()));
    }
  }
}
