import 'package:equatable/equatable.dart';

class UploadModel implements Equatable {
  final String id;
  final String fileName;
  final String mimeType;
  final String extension;
  final int size;
  final String url;
  final DateTime createdAt;
  final ImageConversions? imageConversions;

  UploadModel(
      {required this.id,
      required this.fileName,
      required this.mimeType,
      required this.extension,
      required this.size,
      required this.url,
      required this.createdAt,
      this.imageConversions});

  UploadModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        fileName = json['file_name'],
        mimeType = json['mime_type'],
        extension = json['extension'],
        size = json['size'],
        url = json['url'],
        createdAt = DateTime.parse(json['created_at']),
        imageConversions = json['conversions'] != null &&
                json['conversions'] is Map<String, dynamic>
            ? ImageConversions.fromJson(json['conversions'])
            : null;

  @override
  List<Object?> get props =>
      [id, fileName, mimeType, extension, size, url, createdAt];

  @override
  bool? get stringify => true;
}

class ImageConversions implements Equatable {
  final ImageConversionModel? thumbnail;
  final ImageConversionModel? small;
  final ImageConversionModel? medium;
  final ImageConversionModel? large;

  ImageConversions({this.thumbnail, this.small, this.medium, this.large});

  ImageConversions.fromJson(Map<String, dynamic> json)
      : thumbnail = json['thumbnail'] != null
            ? ImageConversionModel.fromJson(json['thumbnail'])
            : null,
        small = json['small'] != null
            ? ImageConversionModel.fromJson(json['small'])
            : null,
        medium = json['medium'] != null
            ? ImageConversionModel.fromJson(json['medium'])
            : null,
        large = json['large'] != null
            ? ImageConversionModel.fromJson(json['large'])
            : null;

  @override
  List<Object?> get props => [thumbnail, small, medium, large];

  @override
  bool? get stringify => true;
}

class ImageConversionModel implements Equatable {
  final int width;
  final int height;
  final String url;

  ImageConversionModel(
      {required this.width, required this.height, required this.url});

  ImageConversionModel.fromJson(Map<String, dynamic> json)
      : width = json['width'],
        height = json['height'],
        url = json['url'];

  @override
  List<Object?> get props => [width, height, url];

  @override
  bool? get stringify => true;
}
