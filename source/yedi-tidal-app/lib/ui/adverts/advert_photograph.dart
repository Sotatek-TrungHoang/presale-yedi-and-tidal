import 'package:flutter/material.dart';
import 'package:yedi_app/modules/common/models/upload_model.dart';

class AdvertPhotograph extends StatelessWidget {
  const AdvertPhotograph({
    super.key,
    this.uploadModel,
  });

  final UploadModel? uploadModel;

  @override
  Widget build(BuildContext context) {
    if (uploadModel == null) {
      return Container();
    }

    return AspectRatio(
      aspectRatio: 44 / 25,
      child: Image.network(
          uploadModel!.imageConversions?.large?.url ?? uploadModel!.url,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) =>
              loadingProgress == null
                  ? child
                  : Center(
                      child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ))),
    );
  }
}
