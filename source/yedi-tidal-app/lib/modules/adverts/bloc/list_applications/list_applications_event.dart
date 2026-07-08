import 'package:yedi_app/modules/adverts/models/application_model.dart';

sealed class ListApplicationsEvent {}

class ListApplicationsInitialised extends ListApplicationsEvent {}

class ListApplicationsRefreshed extends ListApplicationsEvent {}

class ListApplicationsUpdateApplication extends ListApplicationsEvent {
  final ApplicationModel updatedApplication;
  ListApplicationsUpdateApplication(this.updatedApplication);
}

class ListApplicationsApplicationAccepted extends ListApplicationsEvent {
  final ApplicationModel acceptedApplication;
  ListApplicationsApplicationAccepted(this.acceptedApplication);
}

class ListApplicationsApplicantHearted extends ListApplicationsEvent {
  final int applicantId;
  final bool hearted;
  ListApplicationsApplicantHearted(this.applicantId, this.hearted);
}
