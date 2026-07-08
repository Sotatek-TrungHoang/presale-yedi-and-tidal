import 'package:flutter/material.dart';

enum ProfileBlockType {
  references,
  evidence,
  declaration,
  rtw_declaration;

  IconData get icon {
    switch (this) {
      case ProfileBlockType.references:
        return Icons.badge;
      case ProfileBlockType.evidence:
        return Icons.assignment_rounded;
      case ProfileBlockType.declaration:
        return Icons.insert_drive_file;
      case ProfileBlockType.rtw_declaration:
        return Icons.insert_drive_file;
    }
  }
}

class ProfileBlockModel {
  final ProfileBlockType type;
  final String title;
  final int? evidenceId;
  final int? declarationId;
  final bool completed;

  ProfileBlockModel({
    required this.type,
    required this.title,
    required this.evidenceId,
    required this.declarationId,
    required this.completed,
  });

  factory ProfileBlockModel.fromJson(Map<String, dynamic> json) {
    return ProfileBlockModel(
      type: ProfileBlockType.values.byName(json['type']),
      title: json['title'],
      evidenceId: json['evidence_id'],
      declarationId: json['declaration_id'],
      completed: json['completed'],
    );
  }
}
