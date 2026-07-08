import 'package:equatable/equatable.dart';
import 'package:yedi_app/modules/adverts/models/advert_model.dart';
import 'package:yedi_app/modules/adverts/models/application_model.dart';
import 'package:yedi_app/util/models.dart';

enum ListAdvertApplicationsStatus {
  initial,
  loading,
  loaded,
  refreshing,
  error
}

class ListAdvertApplicationsState implements Equatable {
  final AdvertModel? advert;
  final List<ApplicationModel> applications;
  final ListAdvertApplicationsStatus status;
  final String? error;
  final bool refreshAdvertOnPop;

  ListAdvertApplicationsState(
      {this.advert,
      this.applications = const [],
      this.status = ListAdvertApplicationsStatus.initial,
      this.error,
      this.refreshAdvertOnPop = false});

  ListAdvertApplicationsState copyWith(
      {Wrapped<AdvertModel?>? advert,
      List<ApplicationModel>? applications,
      ListAdvertApplicationsStatus? status,
      Wrapped<String?>? error,
      bool? refreshAdvertOnPop}) {
    return ListAdvertApplicationsState(
        advert: advert is Wrapped ? advert!.value : this.advert,
        applications: applications ?? this.applications,
        status: status ?? this.status,
        error: error is Wrapped ? error!.value : this.error,
        refreshAdvertOnPop: refreshAdvertOnPop ?? this.refreshAdvertOnPop);
  }

  @override
  List<Object?> get props =>
      [advert, applications, status, error, refreshAdvertOnPop];

  @override
  bool? get stringify => true;
}
