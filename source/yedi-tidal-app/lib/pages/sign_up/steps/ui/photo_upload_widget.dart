import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yedi_app/modules/api/api_exceptions.dart';
import 'package:yedi_app/modules/common/models/upload_model.dart';
import 'package:yedi_app/modules/common/services/upload_service.dart';
import 'package:yedi_app/ui/spacer.dart';
import 'package:yedi_app/ui/theme/app_theme.dart';

class PhotoUploadWidget extends StatefulWidget {
  const PhotoUploadWidget({
    required this.incompleteButtonText,
    required this.completeButtonText,
    this.label,
    this.uploadModel,
    this.onUploaded,
    this.infoText,
    this.errorText,
    this.uploadFromGoogleName,
    this.uploadFromGooglePostcode,
    super.key,
  });

  final String? label;
  final String? infoText;
  final String incompleteButtonText;
  final String completeButtonText;
  final String? errorText;
  final UploadModel? uploadModel;
  final Function(UploadModel?)? onUploaded;
  final String? uploadFromGoogleName;
  final String? uploadFromGooglePostcode;

  @override
  State<PhotoUploadWidget> createState() => _PhotoUploadWidgetState();
}

class _PhotoUploadWidgetState extends State<PhotoUploadWidget> {
  bool _isUploading = false;
  final UploadService _uploadService = UploadService();
  String? _error;
  double? _uploadProgress;

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.label != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(widget.label!),
                if (widget.uploadModel != null) ...[
                  HSpacer(8),
                  Icon(
                    Icons.check_circle,
                    color: appColours.success,
                    size: 18,
                  ),
                ]
              ],
            ),
          ],
          VSpacer(8),
          if (widget.uploadModel != null)
            Row(children: [
              Container(
                width: 110,
                height: 110,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: appColours.canvasBackground,
                  borderRadius: BorderRadius.circular(themeBorderRadius),
                ),
                child: Image.network(
                  widget.uploadModel!.url,
                  loadingBuilder: (context, child, loadingProgress) =>
                      loadingProgress == null
                          ? child
                          : Center(child: CircularProgressIndicator()),
                  fit: BoxFit.cover,
                ),
              ),
              HSpacer(20),
              Expanded(
                child: ElevatedButton(
                    onPressed: _isUploading || widget.onUploaded == null
                        ? null
                        : _onUploadTapped,
                    child: Text(_isUploading && _uploadProgress != null
                        ? "Uploading (${(_uploadProgress! * 100).toInt()}%)..."
                        : widget.completeButtonText)),
              )
            ])
          else ...[
            ElevatedButton(
                onPressed: _isUploading || widget.onUploaded == null
                    ? null
                    : _onUploadTapped,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt),
                    HSpacer(4),
                    Text(_isUploading && _uploadProgress != null
                        ? "Uploading (${(_uploadProgress! * 100).toInt()}%)..."
                        : widget.incompleteButtonText),
                  ],
                )),
            if (_error != null || widget.errorText != null) ...[
              VSpacer(4),
              Text(
                _error ?? widget.errorText!,
                textAlign: TextAlign.center,
                style: TextStyle(color: appColours.error, fontSize: 14),
              )
            ] else if (widget.infoText != null) ...[
              VSpacer(4),
              Text(
                widget.infoText!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              )
            ],
          ],
          if (widget.uploadFromGoogleName != null &&
              widget.uploadFromGooglePostcode != null) ...[
            VSpacer(20),
            Row(
              children: [
                Expanded(child: Divider()),
                HSpacer(20),
                const Text(
                  "or",
                  textAlign: TextAlign.center,
                ),
                HSpacer(20),
                Expanded(child: Divider()),
              ],
            ),
            VSpacer(20),
            ElevatedButton(
                onPressed: _isUploading || widget.onUploaded == null
                    ? null
                    : _onRetrieveFromGoogleTapped,
                child: Text("Retrieve Photo From Google"))
          ]
        ]);
  }

  _onUploadTapped() async {
    _error = null;
    _uploadProgress = null;
    setState(() {});

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

    if (image == null) {
      return;
    }

    _isUploading = true;
    _uploadProgress = 0;
    setState(() {});

    try {
      final uploadModel = await _uploadService.uploadFile(
        image.path,
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

  _onRetrieveFromGoogleTapped() async {
    _error = null;
    _uploadProgress = null;
    setState(() {});

    _isUploading = true;
    setState(() {});

    try {
      final uploadModel = await _uploadService.fromGoogle(
          widget.uploadFromGoogleName!, widget.uploadFromGooglePostcode!);

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
