import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/profile/model/refence_model.dart';
import 'package:yedi_app/modules/profile/service/references_service.dart';
import 'package:yedi_app/util/models.dart';

enum ReferencesListStatus { loading, loaded, error }

class ReferencesListState implements Equatable {
  final List<ReferenceModel> references;
  final ReferencesListStatus status;
  final String? error;

  ReferencesListState({
    this.status = ReferencesListStatus.loading,
    this.references = const [],
    this.error,
  });

  ReferencesListState copyWith({
    ReferencesListStatus? status,
    List<ReferenceModel>? references,
    Wrapped<String?>? error,
  }) {
    return ReferencesListState(
      status: status ?? this.status,
      references: references ?? this.references,
      error: error is Wrapped ? error!.value : this.error,
    );
  }

  bool get isLoading => status == ReferencesListStatus.loading;
  bool get isLoaded => status == ReferencesListStatus.loaded;
  bool get isError => status == ReferencesListStatus.error;

  @override
  List<Object?> get props => [
        references,
        status,
        error,
      ];

  @override
  bool? get stringify => true;
}

class ReferencesListCubit extends Cubit<ReferencesListState> {
  final ReferencesService referencesService;

  ReferencesListCubit({required this.referencesService})
      : super(ReferencesListState());

  Future loadReferences() async {
    try {
      final references = await referencesService.getReferences();
      emit(state.copyWith(
        status: ReferencesListStatus.loaded,
        references: references,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ReferencesListStatus.loaded,
        error: Wrapped.value(e.toString()),
      ));
    }
  }
}
