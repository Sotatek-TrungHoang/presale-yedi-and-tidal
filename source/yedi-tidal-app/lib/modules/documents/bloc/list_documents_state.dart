import 'package:equatable/equatable.dart';
import 'package:yedi_app/util/models.dart';

enum ListDocumentsStatus { initial, loading, loaded, refreshing, error }

class ListDocumentsState<T> implements Equatable {
  final List<T> documents;
  final ListDocumentsStatus status;
  final String? error;

  ListDocumentsState(
      {this.documents = const [],
      this.status = ListDocumentsStatus.initial,
      this.error});

  ListDocumentsState<T> copyWith(
      {List<T>? documents,
      ListDocumentsStatus? status,
      Wrapped<String?>? error}) {
    return ListDocumentsState(
        documents: documents ?? this.documents,
        status: status ?? this.status,
        error: error is Wrapped ? error!.value : this.error);
  }

  @override
  List<Object?> get props => [documents, status, error];

  @override
  bool? get stringify => true;
}
