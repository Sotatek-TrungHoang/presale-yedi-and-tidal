import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/adverts/bloc/advert_detail/advert_detail_event.dart';
import 'package:yedi_app/modules/adverts/bloc/advert_detail/advert_detail_state.dart';
import 'package:yedi_app/modules/adverts/models/advert_model.dart';
import 'package:yedi_app/modules/adverts/services/advertiser_advert_service.dart';
import 'package:yedi_app/modules/adverts/services/applicant_advert_service.dart';
import 'package:yedi_app/modules/api/api_exceptions.dart';
import 'package:yedi_app/util/models.dart';

abstract class AdvertDetailBloc
    extends Bloc<AdvertDetailEvent, AdvertDetailState> {
  final int id;

  AdvertDetailBloc({required this.id}) : super(AdvertDetailState()) {
    on<AdvertDetailInitialised>(_onAdvertDetailInitialised);
    on<AdvertDetailRefreshed>(_onAdvertDetailRefreshed);
    on<AdvertDetailUpdateAcceptedApplication>(
        _onAdvertDetailUpdateAcceptedApplication);
    on<AdvertDetailApplicantHearted>(_onAdvertDetailApplicantHearted);
  }

  _onAdvertDetailInitialised(
      AdvertDetailInitialised event, Emitter<AdvertDetailState> emit) async {
    emit(state.copyWith(status: AdvertDetailStatus.loading));
    try {
      final advert = await retrieveAdvert();
      emit(state.copyWith(
          advert: Wrapped.value(advert),
          status: AdvertDetailStatus.loaded,
          error: null));
    } on APIException catch (e) {
      emit(state.copyWith(
          status: AdvertDetailStatus.error,
          error: Wrapped.value(e.message ?? "Something went wrong")));
    } catch (e) {
      emit(state.copyWith(
          status: AdvertDetailStatus.error,
          error: Wrapped.value(e.toString())));
    }
  }

  _onAdvertDetailRefreshed(
      AdvertDetailRefreshed event, Emitter<AdvertDetailState> emit) async {
    if (event.advert != null) {
      emit(state.copyWith(advert: Wrapped.value(event.advert)));
    } else {
      try {
        emit(state.copyWith(status: AdvertDetailStatus.loading));
        final advert = await retrieveAdvert();
        emit(state.copyWith(
            status: AdvertDetailStatus.loaded, advert: Wrapped.value(advert)));
      } on APIException catch (e) {
        emit(state.copyWith(
            status: AdvertDetailStatus.error,
            error: Wrapped.value(e.message ?? "Something went wrong")));
      } catch (e) {
        emit(state.copyWith(
            status: AdvertDetailStatus.error,
            error: Wrapped.value(e.toString())));
      }
    }
  }

  _onAdvertDetailUpdateAcceptedApplication(
    AdvertDetailUpdateAcceptedApplication event,
    Emitter<AdvertDetailState> emit,
  ) {
    final advert =
        state.advert!.copyWith(acceptedApplication: event.application);
    emit(state.copyWith(advert: Wrapped.value(advert)));
  }

  _onAdvertDetailApplicantHearted(
    AdvertDetailApplicantHearted event,
    Emitter<AdvertDetailState> emit,
  ) {
    emit(state.copyWith(
      advert: Wrapped.value(state.advert!.copyWith(
          acceptedApplication: state.advert!.acceptedApplication?.copyWith(
              applicant: Wrapped.value(state
                  .advert!.acceptedApplication!.applicant!
                  .copyWith(hearted: Wrapped.value(event.hearted)))))),
    ));
  }

  Future<AdvertModel> retrieveAdvert() {
    throw UnimplementedError();
  }
}

class ApplicantAdvertDetailBloc extends AdvertDetailBloc {
  final ApplicantAdvertService advertService;

  ApplicantAdvertDetailBloc({required this.advertService, required super.id});

  @override
  Future<AdvertModel> retrieveAdvert() {
    return advertService.getAdvert(id);
  }
}

class AdvertiserAdvertDetailBloc extends AdvertDetailBloc {
  final AdvertiserAdvertService advertService;

  AdvertiserAdvertDetailBloc({required this.advertService, required super.id});

  @override
  Future<AdvertModel> retrieveAdvert() {
    return advertService.getAdvert(id);
  }
}
