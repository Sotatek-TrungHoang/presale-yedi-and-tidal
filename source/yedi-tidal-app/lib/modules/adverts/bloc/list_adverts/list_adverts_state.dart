import 'package:equatable/equatable.dart';
import 'package:yedi_app/modules/adverts/models/advert_model.dart';
import 'package:yedi_app/util/models.dart';

enum ListAdvertsStatus { initial, loading, loaded, refreshing, error }

class ListAdvertsState implements Equatable {
  final List<AdvertModel> adverts;
  final ListAdvertsStatus status;
  final String? error;

  ListAdvertsState(
      {this.adverts = const [],
      this.status = ListAdvertsStatus.initial,
      this.error});

  ListAdvertsState copyWith(
      {List<AdvertModel>? adverts,
      ListAdvertsStatus? status,
      Wrapped<String?>? error}) {
    return ListAdvertsState(
        adverts: adverts ?? this.adverts,
        status: status ?? this.status,
        error: error is Wrapped ? error!.value : this.error);
  }

  @override
  List<Object?> get props => [adverts, status, error];

  @override
  bool? get stringify => true;
}
