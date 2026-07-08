import 'package:equatable/equatable.dart';
import 'package:yedi_app/modules/adverts/models/advertiser_model.dart';
import 'package:yedi_app/modules/adverts/models/application_model.dart';
import 'package:yedi_app/modules/common/models/address_model.dart';
import 'package:yedi_app/modules/common/models/document_model.dart';
import 'package:yedi_app/modules/common/models/money_model.dart';
import 'package:yedi_app/util/dates.dart';
import 'package:yedi_app/util/models.dart';

enum AdvertType { day_to_day, long_term }

enum AdvertStatus {
  pending_approval,
  rejected,
  approved,
  pending_allocation,
  filled,
  not_filled
}

enum PayRateType {
  daily,
  hourly;

  String unit() {
    switch (this) {
      case PayRateType.daily:
        return 'day';
      case PayRateType.hourly:
        return 'hour';
    }
  }
}

enum ApplyAction { none, apply, cancel }

class AdvertModel implements Equatable {
  final int id;
  final String title;
  final String description;
  final AdvertType type;
  final String typeLabel;
  final AdvertStatus status;
  final String statusLabel;
  final DateTime startsAt;
  final DateTime endsAt;
  final String shiftStartTime;
  final String shiftEndTime;
  final DateTime applyBy;
  final int? dayToDayActiveMinutes;
  final List<DocumentModel> documents;
  final PayRateType advertiserPayRateType;
  final String advertiserPayRateTypeLabel;

  final String? contactName;
  final String? contactPosition;
  final String? contactEmail;
  final String? contactTelephone;

  final DateTime createdAt;

  // Advertiser only
  final MoneyModel? advertiserPayRate;
  final int? applicationsCount;
  final ApplicationModel? acceptedApplication;

  // Applicant Only
  final MoneyModel? applicantPay;
  final MoneyModel? applicantPayRate;
  final ApplicationModel? application;

  final AddressModel address;
  final AdvertiserModel? advertiser;

  AdvertModel(
      {required this.id,
      required this.title,
      required this.description,
      required this.type,
      required this.typeLabel,
      required this.status,
      required this.statusLabel,
      required this.startsAt,
      required this.endsAt,
      required this.shiftStartTime,
      required this.shiftEndTime,
      required this.applyBy,
      this.dayToDayActiveMinutes,
      this.documents = const [],
      required this.advertiserPayRateType,
      required this.advertiserPayRateTypeLabel,
      this.contactName,
      this.contactPosition,
      this.contactEmail,
      this.contactTelephone,
      required this.createdAt,
      this.advertiserPayRate,
      this.applicationsCount,
      this.acceptedApplication,
      this.applicantPay,
      this.applicantPayRate,
      this.application,
      required this.address,
      this.advertiser});

  AdvertModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        description = json['description'],
        type = AdvertType.values.byName(json['type']),
        typeLabel = json['type_label'],
        status = AdvertStatus.values.byName(json['status']),
        statusLabel = json['status_label'],
        startsAt = DateTime.parse(json['starts_at']),
        endsAt = DateTime.parse(json['ends_at']),
        shiftStartTime = json['shift_start_time'],
        shiftEndTime = json['shift_end_time'],
        applyBy = DateTime.parse(json['apply_by']),
        dayToDayActiveMinutes = json['day_to_day_active_minutes'],
        documents = json['documents'] != null
            ? List<DocumentModel>.from(
                json['documents'].map((x) => DocumentModel.fromJson(x)))
            : [],
        advertiserPayRateType =
            PayRateType.values.byName(json['advertiser_pay_rate_type']),
        advertiserPayRateTypeLabel = json['advertiser_pay_rate_type_label'],
        contactName = json['contact_name'],
        contactPosition = json['contact_position'],
        contactEmail = json['contact_email'],
        contactTelephone = json['contact_telephone'],
        createdAt = DateTime.parse(json['created_at']),
        advertiserPayRate = json['advertiser_pay_rate'] != null
            ? MoneyModel.fromJson(json['advertiser_pay_rate'])
            : null,
        applicationsCount = json['applications_count'],
        acceptedApplication = json['accepted_application'] != null
            ? ApplicationModel.fromJson(json['accepted_application'])
            : null,
        applicantPay = json['applicant_pay'] != null
            ? MoneyModel.fromJson(json['applicant_pay'])
            : null,
        applicantPayRate = json['applicant_pay_rate'] != null
            ? MoneyModel.fromJson(json['applicant_pay_rate'])
            : null,
        application = json['application'] != null
            ? ApplicationModel.fromJson(json['application'])
            : null,
        address = AddressModel.fromJson(json['address']),
        advertiser = json['advertiser'] != null
            ? AdvertiserModel.fromJson(json['advertiser'])
            : null;

  AdvertModel copyWith({
    int? id,
    String? title,
    String? description,
    AdvertType? type,
    String? typeLabel,
    AdvertStatus? status,
    String? statusLabel,
    DateTime? startsAt,
    DateTime? endsAt,
    String? shiftStartTime,
    String? shiftEndTime,
    DateTime? applyBy,
    Wrapped<int?>? dayToDayActiveMinutes,
    List<DocumentModel>? documents,
    PayRateType? advertiserPayRateType,
    String? advertiserPayRateTypeLabel,
    String? contactName,
    String? contactPosition,
    String? contactEmail,
    String? contactTelephone,
    DateTime? createdAt,
    MoneyModel? advertiserPayRate,
    int? applicationsCount,
    ApplicationModel? acceptedApplication,
    MoneyModel? applicantPay,
    MoneyModel? applicantPayRate,
    ApplicationModel? application,
    AddressModel? address,
    AdvertiserModel? advertiser,
  }) {
    return AdvertModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      typeLabel: typeLabel ?? this.typeLabel,
      status: status ?? this.status,
      statusLabel: statusLabel ?? this.statusLabel,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt ?? this.endsAt,
      shiftStartTime: shiftStartTime ?? this.shiftStartTime,
      shiftEndTime: shiftEndTime ?? this.shiftEndTime,
      applyBy: applyBy ?? this.applyBy,
      dayToDayActiveMinutes: dayToDayActiveMinutes is Wrapped
          ? dayToDayActiveMinutes!.value
          : this.dayToDayActiveMinutes,
      documents: documents ?? this.documents,
      advertiserPayRateType:
          advertiserPayRateType ?? this.advertiserPayRateType,
      advertiserPayRateTypeLabel:
          advertiserPayRateTypeLabel ?? this.advertiserPayRateTypeLabel,
      contactName: contactName ?? this.contactName,
      contactPosition: contactPosition ?? this.contactPosition,
      contactEmail: contactEmail ?? this.contactEmail,
      contactTelephone: contactTelephone ?? this.contactTelephone,
      createdAt: createdAt ?? this.createdAt,
      advertiserPayRate: advertiserPayRate ?? this.advertiserPayRate,
      applicationsCount: applicationsCount ?? this.applicationsCount,
      acceptedApplication: acceptedApplication ?? this.acceptedApplication,
      applicantPay: applicantPay ?? this.applicantPay,
      applicantPayRate: applicantPayRate ?? this.applicantPayRate,
      application: application ?? this.application,
      address: address ?? this.address,
      advertiser: advertiser ?? this.advertiser,
    );
  }

  String get dateLabel {
    if (startsAt.isSameDay(endsAt)) {
      return "${startsAt.formatDate(format: 'EEE d MMM')}, $shiftStartTime - $shiftEndTime";
    } else {
      return "${startsAt.formatDate(format: 'EEE d MMM')} - ${endsAt.formatDate(format: 'EEE d MMM')}, $shiftStartTime - $shiftEndTime";
    }
  }

  String applyByLabel() {
    if (type == AdvertType.long_term) {
      return "Apply By";
    }

    if ([AdvertStatus.pending_approval, AdvertStatus.rejected]
        .contains(status)) {
      return "Apply Within";
    } else if (status == AdvertStatus.approved) {
      return "Apply Within";
    }
    return "Apply By";
  }

  String applyByLabelValue() {
    if (type == AdvertType.long_term) {
      return applyBy.formatDateTime();
    }

    if ([AdvertStatus.pending_approval, AdvertStatus.rejected]
        .contains(status)) {
      return "$dayToDayActiveMinutes mins after approval";
    } else if (status == AdvertStatus.approved) {
      return applyBy.applyByLabel();
    }
    return applyBy.formatDateTime();
  }

  ApplyAction get applyAction {
    switch (status) {
      case AdvertStatus.pending_allocation:
        if (application != null &&
            application!.status == ApplicationStatus.pending) {
          return ApplyAction.cancel;
        }
        break;
      case AdvertStatus.approved:
        // Advert is live and accepting applications
        if (application == null) {
          return ApplyAction.apply;
        } else if (application!.status == ApplicationStatus.pending) {
          return ApplyAction.cancel;
        }
      default:
        break;
    }
    return ApplyAction.none;
  }

  bool get canDelete =>
      status == AdvertStatus.pending_approval ||
      status == AdvertStatus.rejected ||
      (status == AdvertStatus.approved && applicationsCount == 0);

  bool get hasContactInfo =>
      (contactName != null && contactName!.isNotEmpty) ||
      (contactPosition != null && contactPosition!.isNotEmpty) ||
      (contactEmail != null && contactEmail!.isNotEmpty) ||
      (contactTelephone != null && contactTelephone!.isNotEmpty);

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        typeLabel,
        status,
        statusLabel,
        startsAt,
        endsAt,
        shiftStartTime,
        shiftEndTime,
        applyBy,
        dayToDayActiveMinutes,
        documents,
        advertiserPayRateType,
        advertiserPayRateTypeLabel,
        contactName,
        contactPosition,
        contactEmail,
        contactTelephone,
        createdAt,
        advertiserPayRate,
        applicationsCount,
        acceptedApplication,
        applicantPay,
        applicantPayRate,
        application,
        address,
        advertiser
      ];

  @override
  bool? get stringify => true;
}
