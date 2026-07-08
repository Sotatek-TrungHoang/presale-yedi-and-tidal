import 'package:flutter/material.dart';
import 'package:yedi_app/modules/common/models/upload_model.dart';
import 'package:yedi_app/ui/theme/app_theme.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({required this.initials, this.uploadModel, super.key});

  final UploadModel? uploadModel;
  final String initials;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      maxRadius: 90,
      backgroundColor: appColours.accent,
      foregroundColor: Colors.white,
      foregroundImage: uploadModel != null
          ? NetworkImage(
              uploadModel!.imageConversions?.medium?.url ?? uploadModel!.url,
            )
          : null,
      child: Text(
        initials,
        style: TextStyle(fontSize: 38),
      ),
    );
  }
}
