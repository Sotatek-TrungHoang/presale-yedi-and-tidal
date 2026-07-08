sealed class HeartedApplicantsEvent {}

class HeartedApplicantsInitialised extends HeartedApplicantsEvent {
  HeartedApplicantsInitialised();
}

class HeartedApplicantsRefreshed extends HeartedApplicantsEvent {
  HeartedApplicantsRefreshed();
}

class HeartedApplicantsApplicantHearted extends HeartedApplicantsEvent {
  final int heartedApplicantId;
  final bool hearted;
  HeartedApplicantsApplicantHearted(this.heartedApplicantId, this.hearted);
}
