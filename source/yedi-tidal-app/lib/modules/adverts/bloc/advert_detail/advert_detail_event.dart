import 'package:yedi_app/modules/adverts/models/advert_model.dart';
import 'package:yedi_app/modules/adverts/models/application_model.dart';

sealed class AdvertDetailEvent {}

class AdvertDetailInitialised extends AdvertDetailEvent {
  AdvertDetailInitialised();
}

class AdvertDetailRefreshed extends AdvertDetailEvent {
  final AdvertModel? advert;
  AdvertDetailRefreshed(this.advert);
}

class AdvertDetailUpdateAcceptedApplication extends AdvertDetailEvent {
  final ApplicationModel? application;
  AdvertDetailUpdateAcceptedApplication(this.application);
}

class AdvertDetailApplicantHearted extends AdvertDetailEvent {
  final bool hearted;
  AdvertDetailApplicantHearted(this.hearted);
}
