import 'package:equatable/equatable.dart';
import 'package:yedi_app/modules/hearted_applicants/models/hearted_applicant_model.dart';
import 'package:yedi_app/util/models.dart';

enum HeartedApplicantsStatus { initial, loading, loaded, refreshing, error }

class HeartedApplicantsState implements Equatable {
  final List<HeartedApplicantModel> heartedApplicants;
  final HeartedApplicantsStatus status;
  final String? error;

  HeartedApplicantsState(
      {this.heartedApplicants = const [],
      this.status = HeartedApplicantsStatus.initial,
      this.error});

  HeartedApplicantsState copyWith(
      {List<HeartedApplicantModel>? heartedApplicants,
      HeartedApplicantsStatus? status,
      Wrapped<String?>? error}) {
    return HeartedApplicantsState(
        heartedApplicants: heartedApplicants ?? this.heartedApplicants,
        status: status ?? this.status,
        error: error is Wrapped ? error!.value : this.error);
  }

  @override
  List<Object?> get props => [heartedApplicants, status, error];

  @override
  bool? get stringify => true;
}
