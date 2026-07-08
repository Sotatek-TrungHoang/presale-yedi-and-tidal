import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yedi_app/modules/api/api_exceptions.dart';
import 'package:yedi_app/modules/common/models/upload_model.dart';
import 'package:yedi_app/modules/common/services/upload_service.dart';
import 'package:yedi_app/ui/spacer.dart';
import 'package:yedi_app/ui/theme/app_theme.dart';

class FileUploadInput extends StatefulWidget {
  const FileUploadInput({
    required this.buttonText,
    this.uploadModel,
    this.onUploaded,
    this.errorText,
    this.useFilePicker = false,
    this.icon = Icons.camera_alt,
    super.key,
  });

  final String buttonText;
  final String? errorText;
  final UploadModel? uploadModel;
  final Function(UploadModel?)? onUploaded;
  final bool useFilePicker;
  final IconData icon;

  @override
  State<FileUploadInput> createState() => _PhotoUploadWidgetState();
}

class _PhotoUploadWidgetState extends State<FileUploadInput> {
  bool _isUploading = false;
  final UploadService _uploadService = UploadService();
  String? _error;
  double? _uploadProgress;

  @override
  Widget build(BuildContext context) {
    final buttonText = _isUploading && _uploadProgress != null
        ? "Uploading (${(_uploadProgress! * 100).toInt()}%)..."
        : widget.buttonText;

    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
              onPressed: _isUploading || widget.onUploaded == null
                  ? null
                  : _onUploadTapped,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.icon,
                    color: Colors.white,
                  ),
                  HSpacer(4),
                  Text(
                    buttonText,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.uploadModel != null) ...[
                    HSpacer(8),
                    Icon(
                      Icons.check,
                      color: appColours.success,
                    ),
                  ]
                ],
              )),
          if (widget.uploadModel != null) ...[
            VSpacer(4),
            Text(
              widget.uploadModel!.fileName,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            )
          ],
          if (_error != null || widget.errorText != null) ...[
            VSpacer(4),
            Text(
              _error ?? widget.errorText!,
              textAlign: TextAlign.center,
              style: TextStyle(color: appColours.error, fontSize: 14),
            )
          ]
        ]);
  }

  _onUploadTapped() async {
    _error = null;
    _uploadProgress = null;
    setState(() {});

    String? path;

    if (widget.useFilePicker) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );
      path = result?.paths.elementAtOrNull(0);
    } else {
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  leading: Icon(Icons.camera_alt),
                  title: Text('Take a photo'),
                  onTap: () {
                    Navigator.pop(context, ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_library),
                  title: Text('Upload from gallery'),
                  onTap: () {
                    Navigator.pop(context, ImageSource.gallery);
                  },
                ),
              ],
            ),
          );
        },
      );

      if (source == null) {
        return;
      }

      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
      );

      path = image?.path;
    }

    if (path == null) {
      return;
    }

    _isUploading = true;
    _uploadProgress = 0;
    setState(() {});

    try {
      final uploadModel = await _uploadService.uploadFile(
        path,
        onSendProgress: (count, total) {
          _uploadProgress = count / total;
          setState(() {});
        },
      );
      widget.onUploaded?.call(uploadModel);
    } on APIException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isUploading = false;
    }

    setState(() {});
  }
}
