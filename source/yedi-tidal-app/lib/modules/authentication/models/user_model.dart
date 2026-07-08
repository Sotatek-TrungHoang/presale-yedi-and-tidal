import 'package:equatable/equatable.dart';
import 'package:yedi_app/modules/authentication/models/auth_user_model.dart';

class UserModel implements Equatable {
  final int id;
  final UserType type;
  final String title;
  final String titleLabel;
  final String firstName;
  final String lastName;
  final String name;
  final String? email;
  final String? telephone;

  UserModel({
    required this.id,
    required this.type,
    required this.title,
    required this.titleLabel,
    required this.firstName,
    required this.lastName,
    required this.name,
    required this.email,
    required this.telephone,
  });

  UserModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        type = UserType.values.byName(json['type']),
        title = json['title'],
        titleLabel = json['title_label'],
        firstName = json['first_name'],
        lastName = json['last_name'],
        name = json['name'],
        email = json['email'],
        telephone = json['telephone'];

  String get initials => "${firstName[0]}${lastName[0]}";

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        titleLabel,
        firstName,
        lastName,
        name,
        email,
        telephone,
      ];

  @override
  bool? get stringify => true;
}
