sealed class VideoVerificationEvent {}

class VideoVerificationInitialised extends VideoVerificationEvent {}

class VideoVerificationStartRecordingPressed extends VideoVerificationEvent {}

class VideoVerificationStopRecordingPressed extends VideoVerificationEvent {}

class VideoVerificationDiscardVideoPressed extends VideoVerificationEvent {}

class VideoVerificationSaveVideoPressed extends VideoVerificationEvent {}

class VideoVerificationVideoUpdated extends VideoVerificationEvent {}
