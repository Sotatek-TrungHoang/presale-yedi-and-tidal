import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum ReferenceStatus {
  created,
  sent_to_referee,
  pending_confirmation,
  confirmed,
  rejected
}

class ReferenceModel implements Equatable {
  final int id;
  final String name;
  final String email;
  final String? telephone;
  final ReferenceStatus status;
  final String statusLabel;

  ReferenceModel({
    required this.id,
    required this.name,
    required this.email,
    this.telephone,
    required this.status,
    required this.statusLabel,
  });

  ReferenceModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        email = json['email'],
        telephone = json['telephone'],
        status = ReferenceStatus.values.byName(json['status']),
        statusLabel = json['status_label'];

  IconData get icon {
    switch (status) {
      case ReferenceStatus.created:
        return Icons.fiber_new_rounded;
      case ReferenceStatus.sent_to_referee:
        return Icons.mail;
      case ReferenceStatus.pending_confirmation:
        return Icons.hourglass_empty;
      case ReferenceStatus.confirmed:
        return Icons.check;
      case ReferenceStatus.rejected:
        return Icons.close;
    }
  }

  @override
  List<Object?> get props => [id, name, email, telephone, status, statusLabel];

  @override
  bool? get stringify => true;
}
