// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Tidal';

  @override
  String get appTagline => 'Get hired, with Tidal!';

  @override
  String get applicant => 'candidate';

  @override
  String get advertiser => 'brand';

  @override
  String get applicants => 'candidates';

  @override
  String get advertisers => 'brands';

  @override
  String get signUpTitle => 'Tidal Sign Up';

  @override
  String get dayToDayExplanationApplicants => 'Day to Day Jobs are an urgent requirement. They wont be available for long, so apply now.';

  @override
  String get dayToDayExplanationAdvertisers => 'Day to Day Jobs are an urgent requirement. They wont be available for long, so candidates will need to apply quickly.';

  @override
  String get longTermExplanationApplicants => 'Long Term Jobs are a long term requirement. They will be available for a while, so you have time to apply.';

  @override
  String get longTermExplanationAdvertisers => 'Long Term Jobs are a long term requirement. They will be available for a while, so candidates will have time to apply.';
}
