import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/common/models/upload_model.dart';
import 'package:yedi_app/util/models.dart';

enum AddDocumentStatus { idle, submitted }

class AddDocumentState extends Equatable {
  final String title;
  final UploadModel? upload;
  final AddDocumentStatus status;

  const AddDocumentState(
      {this.title = '', this.upload, this.status = AddDocumentStatus.idle});

  bool get isSubmitting => status == AddDocumentStatus.submitted;
  bool get canSubmit => !isSubmitting && title.isNotEmpty && upload != null;

  AddDocumentState copyWith({
    String? title,
    Wrapped<UploadModel?>? upload,
    AddDocumentStatus? status,
  }) {
    return AddDocumentState(
      title: title ?? this.title,
      upload: upload is Wrapped ? upload!.value : this.upload,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        title,
        upload,
        status,
      ];
}

class AddDocumentCubit extends Cubit<AddDocumentState> {
  AddDocumentCubit() : super(AddDocumentState());

  setTitle(String title) {
    emit(state.copyWith(title: title));
  }

  setUpload(UploadModel? upload) {
    emit(state.copyWith(upload: Wrapped.value(upload)));
  }

  addDocumentTapped() {
    emit(state.copyWith(status: AddDocumentStatus.submitted));
  }
}
