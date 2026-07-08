enum FormStatus { loading, idle, submitting, success, error }

abstract class GenericFormState {
  final FormStatus status;
  final Map<String, dynamic> data;
  final Map<String, String> errors;
  final String? error;

  GenericFormState(
      {required this.status,
      required this.data,
      required this.errors,
      required this.error});

  bool get isLoading => status == FormStatus.loading;
  bool get isIdle => status == FormStatus.idle;
  bool get isSubmitting => status == FormStatus.submitting;
  bool get isSuccess => status == FormStatus.success;
  bool get isError => status == FormStatus.error;
}
