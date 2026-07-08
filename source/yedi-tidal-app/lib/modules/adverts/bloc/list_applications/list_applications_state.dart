import 'package:equatable/equatable.dart';
import 'package:yedi_app/modules/adverts/models/advert_model.dart';
import 'package:yedi_app/modules/adverts/models/application_model.dart';
import 'package:yedi_app/util/models.dart';

enum ListApplicationsStatus { initial, loading, loaded, refreshing, error }

class ListApplicationsState implements Equatable {
  final List<ApplicationModel> applications;
  final ListApplicationsStatus status;
  final String? error;
  final bool refreshAdvertOnPop;

  ListApplicationsState(
      {this.applications = const [],
      this.status = ListApplicationsStatus.initial,
      this.error,
      this.refreshAdvertOnPop = false});

  ListApplicationsState copyWith(
      {Wrapped<AdvertModel?>? advert,
      List<ApplicationModel>? applications,
      ListApplicationsStatus? status,
      Wrapped<String?>? error,
      bool? refreshAdvertOnPop}) {
    return ListApplicationsState(
        applications: applications ?? this.applications,
        status: status ?? this.status,
        error: error is Wrapped ? error!.value : this.error,
        refreshAdvertOnPop: refreshAdvertOnPop ?? this.refreshAdvertOnPop);
  }

  @override
  List<Object?> get props => [applications, status, error, refreshAdvertOnPop];

  @override
  bool? get stringify => true;
}
