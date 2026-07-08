sealed class ListAdvertsEvent {}

class ListAdvertsInitialised extends ListAdvertsEvent {
  ListAdvertsInitialised();
}

class ListAdvertsRefreshed extends ListAdvertsEvent {
  ListAdvertsRefreshed();
}

class ListAdvertsAdvertDeleted extends ListAdvertsEvent {
  int id;
  ListAdvertsAdvertDeleted(this.id);
}

class ListAdvertsRefreshAdvert extends ListAdvertsEvent {
  final int advertId;
  ListAdvertsRefreshAdvert(this.advertId);
}
