import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/adverts/bloc/list_adverts/list_adverts_event.dart';
import 'package:yedi_app/modules/adverts/bloc/list_adverts/list_adverts_state.dart';
import 'package:yedi_app/modules/adverts/models/advert_model.dart';
import 'package:yedi_app/modules/adverts/services/advertiser_advert_service.dart';
import 'package:yedi_app/modules/adverts/services/applicant_advert_service.dart';
import 'package:yedi_app/modules/api/api_exceptions.dart';
import 'package:yedi_app/util/models.dart';

abstract class ListAdvertsBloc
    extends Bloc<ListAdvertsEvent, ListAdvertsState> {
  ListAdvertsBloc() : super(ListAdvertsState()) {
    on<ListAdvertsInitialised>(_onListApplicantAdvertsInitialised);
    on<ListAdvertsRefreshed>(_onListApplicantAdvertsRefreshed);
    on<ListAdvertsRefreshAdvert>(_onListAdvertsRefreshAdvert);
    on<ListAdvertsAdvertDeleted>(_onListAdvertsAdvertDeleted);
  }

  _onListApplicantAdvertsInitialised(
      ListAdvertsInitialised event, Emitter<ListAdvertsState> emit) async {
    emit(state.copyWith(status: ListAdvertsStatus.loading));
    await _fetchAdverts(emit);
  }

  _onListApplicantAdvertsRefreshed(
      ListAdvertsRefreshed event, Emitter<ListAdvertsState> emit) async {
    emit(state.copyWith(status: ListAdvertsStatus.refreshing));
    await _fetchAdverts(emit);
  }

  _onListAdvertsRefreshAdvert(
      ListAdvertsRefreshAdvert event, Emitter<ListAdvertsState> emit) async {
    if (state.adverts.where((a) => a.id == event.advertId).isEmpty) {
      return;
    }

    try {
      final advert = await getAdvert(event.advertId);
      final adverts =
          state.adverts.map((a) => a.id == advert.id ? advert : a).toList();
      emit(state.copyWith(
          adverts: adverts, status: ListAdvertsStatus.loaded, error: null));
    } catch (e) {
      print(e);
    }
  }

  _onListAdvertsAdvertDeleted(
    ListAdvertsAdvertDeleted event,
    Emitter<ListAdvertsState> emit,
  ) {
    final adverts = state.adverts.where((a) => a.id != event.id).toList();
    emit(state.copyWith(adverts: adverts));
  }

  _fetchAdverts(Emitter<ListAdvertsState> emit) async {
    try {
      final adverts = await retrieveAdverts();
      emit(state.copyWith(
          adverts: adverts, status: ListAdvertsStatus.loaded, error: null));
    } on APIException catch (e) {
      emit(state.copyWith(
          status: ListAdvertsStatus.error,
          error: Wrapped.value(e.message ?? "Something went wrong")));
    } catch (e) {
      emit(state.copyWith(
          status: ListAdvertsStatus.error, error: Wrapped.value(e.toString())));
    }
  }

  Future<List<AdvertModel>> retrieveAdverts() async {
    throw UnimplementedError();
  }

  Future<AdvertModel> getAdvert(int id) async {
    throw UnimplementedError();
  }
}

class ListApplicantDayToDayAdvertsBloc extends ListAdvertsBloc {
  ListApplicantDayToDayAdvertsBloc({required this.advertService});

  final ApplicantAdvertService advertService;

  @override
  Future<List<AdvertModel>> retrieveAdverts() async {
    return advertService.listAdvertsByType(AdvertType.day_to_day);
  }
}

class ListApplicantLongTermAdvertsBloc extends ListAdvertsBloc {
  ListApplicantLongTermAdvertsBloc({required this.advertService});

  final ApplicantAdvertService advertService;

  @override
  Future<List<AdvertModel>> retrieveAdverts() async {
    return advertService.listAdvertsByType(AdvertType.long_term);
  }
}

class ListAdvertiserDayToDayAdvertsBloc extends ListAdvertsBloc {
  ListAdvertiserDayToDayAdvertsBloc({required this.advertService});

  final AdvertiserAdvertService advertService;

  @override
  Future<List<AdvertModel>> retrieveAdverts() async {
    return advertService.listAdvertsByType(AdvertType.day_to_day);
  }

  @override
  Future<AdvertModel> getAdvert(int id) async {
    return advertService.getAdvert(id);
  }
}

class ListAdvertiserLongTermAdvertsBloc extends ListAdvertsBloc {
  ListAdvertiserLongTermAdvertsBloc({required this.advertService});

  final AdvertiserAdvertService advertService;

  @override
  Future<List<AdvertModel>> retrieveAdverts() async {
    return advertService.listAdvertsByType(AdvertType.long_term);
  }

  @override
  Future<AdvertModel> getAdvert(int id) async {
    return advertService.getAdvert(id);
  }
}
