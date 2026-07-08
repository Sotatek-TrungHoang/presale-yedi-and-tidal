sealed class ListDocumentsEvent {}

class ListDocumentsInitialised extends ListDocumentsEvent {
  ListDocumentsInitialised();
}

class ListDocumentsRefreshed extends ListDocumentsEvent {
  ListDocumentsRefreshed();
}
