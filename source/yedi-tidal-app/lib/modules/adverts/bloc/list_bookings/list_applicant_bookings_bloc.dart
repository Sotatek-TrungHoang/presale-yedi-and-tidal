import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/adverts/bloc/list_adverts/list_adverts_event.dart';
import 'package:yedi_app/modules/adverts/bloc/list_adverts/list_adverts_state.dart';
import 'package:yedi_app/modules/adverts/services/applicant_advert_service.dart';
import 'package:yedi_app/modules/api/api_exceptions.dart';
import 'package:yedi_app/util/models.dart';

enum BookingType { confirmed, appliedTo }

abstract class ListApplicantBookingsBloc
    extends Bloc<ListAdvertsEvent, ListAdvertsState> {
  final ApplicantAdvertService advertService;
  final BookingType bookingType;

  ListApplicantBookingsBloc(
      {required this.advertService, required this.bookingType})
      : super(ListAdvertsState()) {
    on<ListAdvertsInitialised>(_onListApplicantAdvertsInitialised);
    on<ListAdvertsRefreshed>(_onListApplicantAdvertsRefreshed);
  }

  _onListApplicantAdvertsInitialised(
      ListAdvertsInitialised event, Emitter<ListAdvertsState> emit) async {
    emit(state.copyWith(status: ListAdvertsStatus.loading));
    await _fetchBookings(emit);
  }

  _onListApplicantAdvertsRefreshed(
      ListAdvertsRefreshed event, Emitter<ListAdvertsState> emit) async {
    emit(state.copyWith(status: ListAdvertsStatus.refreshing));
    await _fetchBookings(emit);
  }

  _fetchBookings(Emitter<ListAdvertsState> emit) async {
    try {
      final adverts = bookingType == BookingType.confirmed
          ? await advertService.listConfirmedBookings()
          : await advertService.listAppliedTo();
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
}

class ListApplicantConfirmedBookingsBloc extends ListApplicantBookingsBloc {
  ListApplicantConfirmedBookingsBloc({required super.advertService})
      : super(bookingType: BookingType.confirmed);
}

class ListApplicantAppliedToBookingsBloc extends ListApplicantBookingsBloc {
  ListApplicantAppliedToBookingsBloc({required super.advertService})
      : super(bookingType: BookingType.appliedTo);
}
