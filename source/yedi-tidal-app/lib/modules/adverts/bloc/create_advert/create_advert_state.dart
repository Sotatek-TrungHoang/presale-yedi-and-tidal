import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:yedi_app/modules/adverts/models/advert_model.dart';
import 'package:yedi_app/modules/common/models/upload_model.dart';
import 'package:yedi_app/util/dates.dart';
import 'package:yedi_app/util/models.dart';

enum CreateAdvertStatus { waitingForSubmit, submitting, success, error }

class CreateAdvertState implements Equatable {
  final AdvertType? type;
  final String title;
  final String description;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final TimeOfDay? shiftStartsAt;
  final TimeOfDay? shiftEndsAt;
  final PayRateType? payRateType;
  final String payRate;
  final DateTime? applyByDate;
  final TimeOfDay? applyByTime;
  final String dayToDayActiveMinutes;

  final String contactName;
  final String contactPosition;
  final String contactEmail;
  final String contactTelephone;

  final List<CreateAdvertDocument> documents;

  final CreateAdvertStatus status;
  final Map<String, String> errors;
  final String? error;
  final AdvertModel? createdAdvert;

  CreateAdvertState({
    this.type,
    this.title = '',
    this.description = '',
    this.startsAt,
    this.endsAt,
    this.shiftStartsAt,
    this.shiftEndsAt,
    this.payRateType,
    this.payRate = '',
    this.applyByDate,
    this.applyByTime,
    this.dayToDayActiveMinutes = '',
    this.contactName = '',
    this.contactPosition = '',
    this.contactEmail = '',
    this.contactTelephone = '',
    this.documents = const [],
    this.status = CreateAdvertStatus.waitingForSubmit,
    this.error,
    this.errors = const {},
    this.createdAdvert,
  });

  factory CreateAdvertState.initial() {
    return CreateAdvertState();
  }

  CreateAdvertState copyWith({
    Wrapped<AdvertType?>? type,
    String? title,
    String? description,
    Wrapped<DateTime?>? startsAt,
    Wrapped<DateTime?>? endsAt,
    Wrapped<TimeOfDay?>? shiftStartsAt,
    Wrapped<TimeOfDay?>? shiftEndsAt,
    Wrapped<PayRateType?>? payRateType,
    String? payRate,
    Wrapped<DateTime?>? applyByDate,
    Wrapped<TimeOfDay?>? applyByTime,
    String? dayToDayActiveMinutes,
    String? contactName,
    String? contactPosition,
    String? contactEmail,
    String? contactTelephone,
    List<CreateAdvertDocument>? documents,
    CreateAdvertStatus? status,
    Wrapped<String?>? error,
    Map<String, String>? errors,
    Wrapped<AdvertModel?>? createdAdvert,
  }) {
    return CreateAdvertState(
      type: type is Wrapped ? type!.value : this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      startsAt: startsAt is Wrapped ? startsAt!.value : this.startsAt,
      endsAt: endsAt is Wrapped ? endsAt!.value : this.endsAt,
      shiftStartsAt:
          shiftStartsAt is Wrapped ? shiftStartsAt!.value : this.shiftStartsAt,
      shiftEndsAt:
          shiftEndsAt is Wrapped ? shiftEndsAt!.value : this.shiftEndsAt,
      payRateType:
          payRateType is Wrapped ? payRateType!.value : this.payRateType,
      payRate: payRate ?? this.payRate,
      applyByDate:
          applyByDate is Wrapped ? applyByDate!.value : this.applyByDate,
      applyByTime:
          applyByTime is Wrapped ? applyByTime!.value : this.applyByTime,
      dayToDayActiveMinutes:
          dayToDayActiveMinutes ?? this.dayToDayActiveMinutes,
      contactName: contactName ?? this.contactName,
      contactPosition: contactPosition ?? this.contactPosition,
      contactEmail: contactEmail ?? this.contactEmail,
      contactTelephone: contactTelephone ?? this.contactTelephone,
      documents: documents ?? this.documents,
      status: status ?? this.status,
      error: error is Wrapped ? error!.value : this.error,
      errors: errors ?? this.errors,
      createdAdvert:
          createdAdvert is Wrapped ? createdAdvert!.value : this.createdAdvert,
    );
  }

  Map<String, dynamic> get payload => {};
  bool get isSubmitting => status == CreateAdvertStatus.submitting;
  bool get canSubmit =>
      status == CreateAdvertStatus.waitingForSubmit &&
      type != null &&
      title.isNotEmpty &&
      description.isNotEmpty &&
      startsAt != null &&
      endsAt != null &&
      shiftStartsAt != null &&
      shiftEndsAt != null &&
      payRateType != null &&
      payRate.isNotEmpty &&
      contactName.isNotEmpty &&
      (contactEmail.isNotEmpty || contactTelephone.isNotEmpty) &&
      ((type == AdvertType.day_to_day && dayToDayActiveMinutes.isNotEmpty) ||
          (type == AdvertType.long_term &&
              applyByDate != null &&
              applyByTime != null));

  List<Map<String, DateTime>>? get shifts {
    if (this.startsAt == null ||
        endsAt == null ||
        shiftStartsAt == null ||
        shiftEndsAt == null) {
      return null;
    }

    DateTime startsAt = DateTime(this.startsAt!.year, this.startsAt!.month,
        this.startsAt!.day, shiftStartsAt!.hour, shiftStartsAt!.minute);
    DateTime pointer = startsAt.copyWith();
    List<Map<String, DateTime>> shifts = [];
    do {
      final shiftStartsAt = pointer.copyWith(
          hour: this.shiftStartsAt!.hour, minute: this.shiftStartsAt!.minute);
      DateTime shiftEndsAt = pointer.copyWith(
          hour: this.shiftEndsAt!.hour, minute: this.shiftEndsAt!.minute);
      if (shiftEndsAt.isBefore(shiftStartsAt)) {
        shiftEndsAt = shiftEndsAt.add(Duration(days: 1));
      }

      shifts.add({
        "starts_at": shiftStartsAt,
        "ends_at": shiftEndsAt,
      });

      pointer = pointer.add(Duration(days: 1));
    } while (pointer.formatDateDB().compareTo(endsAt!.formatDateDB()) <= 0);
    return shifts;
  }

  @override
  List<Object?> get props => [
        type,
        title,
        description,
        startsAt,
        endsAt,
        shiftStartsAt,
        shiftEndsAt,
        payRateType,
        payRate,
        applyByDate,
        applyByTime,
        dayToDayActiveMinutes,
        contactName,
        contactPosition,
        contactEmail,
        contactTelephone,
        documents,
        status,
        error,
        errors,
        createdAdvert
      ];

  @override
  bool? get stringify => false;
}

class CreateAdvertDocument implements Equatable {
  final String title;
  final UploadModel upload;

  CreateAdvertDocument({required this.title, required this.upload});

  @override
  List<Object?> get props => [
        title,
        upload,
      ];

  @override
  bool? get stringify => true;
}
