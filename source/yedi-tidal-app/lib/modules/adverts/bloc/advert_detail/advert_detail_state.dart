import 'package:equatable/equatable.dart';
import 'package:yedi_app/modules/adverts/models/advert_model.dart';
import 'package:yedi_app/util/models.dart';

enum AdvertDetailStatus { initial, loading, loaded, error }

class AdvertDetailState implements Equatable {
  final AdvertModel? advert;
  final AdvertDetailStatus status;
  final String? error;

  AdvertDetailState(
      {this.advert, this.status = AdvertDetailStatus.initial, this.error});

  AdvertDetailState copyWith(
      {Wrapped<AdvertModel?>? advert,
      AdvertDetailStatus? status,
      Wrapped<String?>? error}) {
    return AdvertDetailState(
        advert: advert is Wrapped ? advert!.value : this.advert,
        status: status ?? this.status,
        error: error is Wrapped ? error!.value : this.error);
  }

  @override
  List<Object?> get props => [advert, status, error];

  @override
  bool? get stringify => true;
}
