import 'package:flutter/material.dart';
import 'package:yedi_app/modules/adverts/bloc/create_advert/create_advert_state.dart';
import 'package:yedi_app/modules/adverts/models/advert_model.dart';

sealed class CreateAdvertEvent {}

class CreateAdvertTitleChanged extends CreateAdvertEvent {
  final String value;
  CreateAdvertTitleChanged(this.value);
}

class CreateAdvertTypeChanged extends CreateAdvertEvent {
  final AdvertType? value;
  CreateAdvertTypeChanged(this.value);
}

class CreateAdvertDescriptionChanged extends CreateAdvertEvent {
  final String value;
  CreateAdvertDescriptionChanged(this.value);
}

class CreateAdvertStartsAtChanged extends CreateAdvertEvent {
  final DateTime? value;
  CreateAdvertStartsAtChanged(this.value);
}

class CreateAdvertEndsAtChanged extends CreateAdvertEvent {
  final DateTime? value;
  CreateAdvertEndsAtChanged(this.value);
}

class CreateAdvertShiftStartsAtChanged extends CreateAdvertEvent {
  final TimeOfDay? value;
  CreateAdvertShiftStartsAtChanged(this.value);
}

class CreateAdvertShiftEndsAtChanged extends CreateAdvertEvent {
  final TimeOfDay? value;
  CreateAdvertShiftEndsAtChanged(this.value);
}

class CreateAdvertPayRateTypeChanged extends CreateAdvertEvent {
  final PayRateType? value;
  CreateAdvertPayRateTypeChanged(this.value);
}

class CreateAdvertPayRateChanged extends CreateAdvertEvent {
  final String value;
  CreateAdvertPayRateChanged(this.value);
}

class CreateAdvertApplyByDateChanged extends CreateAdvertEvent {
  final DateTime? value;
  CreateAdvertApplyByDateChanged(this.value);
}

class CreateAdvertApplyByTimeChanged extends CreateAdvertEvent {
  final TimeOfDay? value;
  CreateAdvertApplyByTimeChanged(this.value);
}

class CreateAdvertDayToDayActiveMinutesChanged extends CreateAdvertEvent {
  final String? value;
  CreateAdvertDayToDayActiveMinutesChanged(this.value);
}

class CreateAdvertContactNameChanged extends CreateAdvertEvent {
  final String value;
  CreateAdvertContactNameChanged(this.value);
}

class CreateAdvertContactPositionChanged extends CreateAdvertEvent {
  final String value;
  CreateAdvertContactPositionChanged(this.value);
}

class CreateAdvertContactEmailChanged extends CreateAdvertEvent {
  final String value;
  CreateAdvertContactEmailChanged(this.value);
}

class CreateAdvertContactTelephoneChanged extends CreateAdvertEvent {
  final String value;
  CreateAdvertContactTelephoneChanged(this.value);
}

class CreateAdvertDocumentAdded extends CreateAdvertEvent {
  final CreateAdvertDocument value;
  CreateAdvertDocumentAdded(this.value);
}

class CreateAdvertDocumentRemoved extends CreateAdvertEvent {
  final int index;
  CreateAdvertDocumentRemoved(this.index);
}

class CreateAdvertSubmitted extends CreateAdvertEvent {}
