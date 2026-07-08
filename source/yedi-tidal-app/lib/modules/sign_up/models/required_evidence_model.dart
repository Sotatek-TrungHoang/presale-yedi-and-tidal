import 'package:equatable/equatable.dart';

class RequiredEvidenceModel implements Equatable {
  final int id;
  final String title;

  RequiredEvidenceModel({
    required this.id,
    required this.title,
  });

  RequiredEvidenceModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'];

  @override
  List<Object?> get props => [id, title];

  @override
  bool? get stringify => true;
}
