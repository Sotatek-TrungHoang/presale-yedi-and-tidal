class SettingsModel {
  final int referencesRequired;
  final bool requireTeacherNumber;

  SettingsModel({
    required this.referencesRequired,
    required this.requireTeacherNumber,
  });

  SettingsModel.fromJson(Map<String, dynamic> json)
      : referencesRequired = json['references_required'],
        requireTeacherNumber = json['require_teacher_number'];
}
