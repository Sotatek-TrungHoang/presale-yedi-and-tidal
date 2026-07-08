import 'package:equatable/equatable.dart';

class RightToWorkDeclarationModel implements Equatable {
  final int id;
  final bool rightToWorkUk;
  final bool requireVisaToWorkUk;
  final bool livedOrWorkedOutsideUk6Months;
  final bool hasCriminalConvictionsOrProsecutionsPending;

  RightToWorkDeclarationModel({
    required this.id,
    required this.rightToWorkUk,
    required this.requireVisaToWorkUk,
    required this.livedOrWorkedOutsideUk6Months,
    required this.hasCriminalConvictionsOrProsecutionsPending,
  });

  RightToWorkDeclarationModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        rightToWorkUk = json['right_to_work_uk'],
        requireVisaToWorkUk = json['require_visa_to_work_uk'],
        livedOrWorkedOutsideUk6Months =
            json['lived_or_worked_outside_uk_6_months'],
        hasCriminalConvictionsOrProsecutionsPending =
            json['has_criminal_convictions_or_prosecutions_pending'];

  @override
  List<Object?> get props => [
        id,
        rightToWorkUk,
        requireVisaToWorkUk,
        livedOrWorkedOutsideUk6Months,
        hasCriminalConvictionsOrProsecutionsPending,
      ];

  @override
  bool? get stringify => true;
}
