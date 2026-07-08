import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/adverts/bloc/create_advert/create_advert_event.dart';
import 'package:yedi_app/modules/adverts/bloc/create_advert/create_advert_state.dart';
import 'package:yedi_app/modules/adverts/services/advertiser_advert_service.dart';
import 'package:yedi_app/modules/api/api_exceptions.dart';
import 'package:yedi_app/util/dates.dart';
import 'package:yedi_app/util/models.dart';

class CreateAdvertBloc extends Bloc<CreateAdvertEvent, CreateAdvertState> {
  final AdvertiserAdvertService advertiserAdvertService;

  CreateAdvertBloc({required this.advertiserAdvertService})
      : super(CreateAdvertState.initial()) {
    on<CreateAdvertSubmitted>(_onCreateAdvertSubmitted);
    on<CreateAdvertTitleChanged>(_onCreateAdvertTitleChanged);
    on<CreateAdvertTypeChanged>(_onCreateAdvertTypeChanged);
    on<CreateAdvertDescriptionChanged>(_onCreateAdvertDescriptionChanged);
    on<CreateAdvertStartsAtChanged>(_onCreateAdvertStartsAtChanged);
    on<CreateAdvertEndsAtChanged>(_onCreateAdvertEndsAtChanged);
    on<CreateAdvertShiftStartsAtChanged>(_onCreateAdvertShiftStartsAtChanged);
    on<CreateAdvertShiftEndsAtChanged>(_onCreateAdvertShiftEndsAtChanged);
    on<CreateAdvertPayRateTypeChanged>(_onCreateAdvertPayRateTypeChanged);
    on<CreateAdvertPayRateChanged>(_onCreateAdvertPayRateChanged);
    on<CreateAdvertApplyByDateChanged>(_onCreateAdvertApplyByDateChanged);
    on<CreateAdvertApplyByTimeChanged>(_onCreateAdvertApplyByTimeChanged);
    on<CreateAdvertDayToDayActiveMinutesChanged>(
        _onCreateAdvertDayToDayActiveMinutesChanged);
    on<CreateAdvertContactNameChanged>(_onCreateAdvertContactNameChanged);
    on<CreateAdvertContactPositionChanged>(
        _onCreateAdvertContactPositionChanged);
    on<CreateAdvertContactEmailChanged>(_onCreateAdvertContactEmailChanged);
    on<CreateAdvertContactTelephoneChanged>(
        _onCreateAdvertContactTelephoneChanged);
    on<CreateAdvertDocumentAdded>(_onCreateAdvertDocumentAdded);
    on<CreateAdvertDocumentRemoved>(_onCreateAdvertDocumentRemoved);
  }

  _onCreateAdvertTitleChanged(
      CreateAdvertTitleChanged event, Emitter<CreateAdvertState> emit) {
    emit(state.copyWith(title: event.value));
  }

  _onCreateAdvertTypeChanged(
      CreateAdvertTypeChanged event, Emitter<CreateAdvertState> emit) {
    emit(state.copyWith(type: Wrapped.value(event.value)));
  }

  _onCreateAdvertDescriptionChanged(
      CreateAdvertDescriptionChanged event, Emitter<CreateAdvertState> emit) {
    emit(state.copyWith(description: event.value));
  }

  _onCreateAdvertStartsAtChanged(
      CreateAdvertStartsAtChanged event, Emitter<CreateAdvertState> emit) {
    emit(state.copyWith(
      startsAt: Wrapped.value(event.value),
    ));
  }

  _onCreateAdvertEndsAtChanged(
      CreateAdvertEndsAtChanged event, Emitter<CreateAdvertState> emit) {
    emit(state.copyWith(endsAt: Wrapped.value(event.value)));
  }

  _onCreateAdvertShiftStartsAtChanged(
      CreateAdvertShiftStartsAtChanged event, Emitter<CreateAdvertState> emit) {
    emit(state.copyWith(shiftStartsAt: Wrapped.value(event.value)));
  }

  _onCreateAdvertShiftEndsAtChanged(
      CreateAdvertShiftEndsAtChanged event, Emitter<CreateAdvertState> emit) {
    emit(state.copyWith(shiftEndsAt: Wrapped.value(event.value)));
  }

  _onCreateAdvertPayRateTypeChanged(
      CreateAdvertPayRateTypeChanged event, Emitter<CreateAdvertState> emit) {
    emit(state.copyWith(payRateType: Wrapped.value(event.value)));
  }

  _onCreateAdvertPayRateChanged(
      CreateAdvertPayRateChanged event, Emitter<CreateAdvertState> emit) {
    emit(state.copyWith(payRate: event.value));
  }

  _onCreateAdvertApplyByDateChanged(
      CreateAdvertApplyByDateChanged event, Emitter<CreateAdvertState> emit) {
    emit(state.copyWith(applyByDate: Wrapped.value(event.value)));
  }

  _onCreateAdvertApplyByTimeChanged(
      CreateAdvertApplyByTimeChanged event, Emitter<CreateAdvertState> emit) {
    emit(state.copyWith(applyByTime: Wrapped.value(event.value)));
  }

  _onCreateAdvertDayToDayActiveMinutesChanged(
      CreateAdvertDayToDayActiveMinutesChanged event,
      Emitter<CreateAdvertState> emit) {
    emit(state.copyWith(dayToDayActiveMinutes: event.value));
  }

  _onCreateAdvertContactNameChanged(
      CreateAdvertContactNameChanged event, Emitter<CreateAdvertState> emit) {
    emit(state.copyWith(contactName: event.value));
  }

  _onCreateAdvertContactPositionChanged(
      CreateAdvertContactPositionChanged event,
      Emitter<CreateAdvertState> emit) {
    emit(state.copyWith(contactPosition: event.value));
  }

  _onCreateAdvertContactEmailChanged(
      CreateAdvertContactEmailChanged event, Emitter<CreateAdvertState> emit) {
    emit(state.copyWith(contactEmail: event.value));
  }

  _onCreateAdvertContactTelephoneChanged(
      CreateAdvertContactTelephoneChanged event,
      Emitter<CreateAdvertState> emit) {
    emit(state.copyWith(contactTelephone: event.value));
  }

  _onCreateAdvertDocumentAdded(
      CreateAdvertDocumentAdded event, Emitter<CreateAdvertState> emit) {
    emit(state.copyWith(documents: state.documents + [event.value]));
  }

  _onCreateAdvertDocumentRemoved(
      CreateAdvertDocumentRemoved event, Emitter<CreateAdvertState> emit) {
    final index = event.index;
    emit(state.copyWith(
        documents: state.documents
            .asMap()
            .entries
            .where((e) => e.key != index)
            .map((e) => e.value)
            .toList()));
  }

  _onCreateAdvertSubmitted(
      CreateAdvertSubmitted event, Emitter<CreateAdvertState> emit) async {
    final payload = {
      "type": state.type?.name,
      "title": state.title,
      "description": state.description,
      "starts_at": state.startsAt?.formatDateDB(),
      "ends_at": state.endsAt?.formatDateDB(),
      "shift_start_time": state.shiftStartsAt != null
          ? "${state.shiftStartsAt!.hour.toString().padLeft(2, '0')}:${state.shiftStartsAt!.minute.toString().padLeft(2, '0')}"
          : null,
      "shift_end_time": state.shiftEndsAt != null
          ? "${state.shiftEndsAt!.hour.toString().padLeft(2, '0')}:${state.shiftEndsAt!.minute.toString().padLeft(2, '0')}"
          : null,
      "advertiser_pay_rate": state.payRate,
      "advertiser_pay_rate_type": state.payRateType?.name,
      "day_to_day_active_minutes": state.dayToDayActiveMinutes,
      "contact_name": state.contactName,
      "contact_position": state.contactPosition,
      "contact_email": state.contactEmail,
      "contact_telephone": state.contactTelephone,
      "apply_by": state.applyByDate != null && state.applyByTime != null
          ? DateTime(
                  state.applyByDate!.year,
                  state.applyByDate!.month,
                  state.applyByDate!.day,
                  state.applyByTime!.hour,
                  state.applyByTime!.minute)
              .formatDateTimeDB()
          : null,
      "documents": state.documents
          .map((document) =>
              {"title": document.title, "upload_id": document.upload.id})
          .toList()
    };

    emit(state.copyWith(
        status: CreateAdvertStatus.submitting,
        error: Wrapped.value(null),
        errors: {}));

    try {
      final advert = await advertiserAdvertService.createAdvert(payload);
      emit(state.copyWith(
          status: CreateAdvertStatus.success,
          createdAdvert: Wrapped.value(advert)));
    } on APIValidationException catch (e) {
      emit(state.copyWith(
          status: CreateAdvertStatus.waitingForSubmit,
          error: Wrapped.value(e.message),
          errors: e.errors));
    } on APIException catch (e) {
      emit(state.copyWith(
          status: CreateAdvertStatus.waitingForSubmit,
          error: Wrapped.value(e.message)));
    } catch (e) {
      emit(state.copyWith(
          status: CreateAdvertStatus.waitingForSubmit,
          error: Wrapped.value(e.toString())));
    }
  }
}
