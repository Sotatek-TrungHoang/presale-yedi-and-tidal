import 'package:yedi_app/modules/adverts/models/application_model.dart';

sealed class ListAdvertApplicationsEvent {}

class ListAdvertApplicationsInitialised extends ListAdvertApplicationsEvent {}

class ListAdvertApplicationsRefreshed extends ListAdvertApplicationsEvent {}

class ListAdvertApplicationsUpdateApplication
    extends ListAdvertApplicationsEvent {
  final ApplicationModel updatedApplication;
  ListAdvertApplicationsUpdateApplication(this.updatedApplication);
}

class ListAdvertApplicationsApplicationAccepted
    extends ListAdvertApplicationsEvent {
  final ApplicationModel acceptedApplication;
  ListAdvertApplicationsApplicationAccepted(this.acceptedApplication);
}

class ListAdvertApplicationsSetRefreshOnPop
    extends ListAdvertApplicationsEvent {
  final bool refreshOnPop;
  ListAdvertApplicationsSetRefreshOnPop(this.refreshOnPop);
}

class ListAdvertApplicationsApplicantHearted
    extends ListAdvertApplicationsEvent {
  final int applicantId;
  final bool hearted;
  ListAdvertApplicationsApplicantHearted(this.applicantId, this.hearted);
}
