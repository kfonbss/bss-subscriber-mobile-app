import 'package:kfon_subscriber/core/data/entity/file_view_url_result.dart';

class FileViewUrlResultModel {
  final String fileId;
  final String bucket;
  final String objectKey;
  final String contentType;
  final int sizeBytes;
  final int expirySeconds;
  final String url;

  const FileViewUrlResultModel({
    required this.fileId,
    required this.bucket,
    required this.objectKey,
    required this.contentType,
    required this.sizeBytes,
    required this.expirySeconds,
    required this.url,
  });

  factory FileViewUrlResultModel.fromJson(Map<String, dynamic> json) {
    return FileViewUrlResultModel(
      fileId: json['fileId'] as String? ?? '',
      bucket: json['bucket'] as String? ?? '',
      objectKey: json['objectKey'] as String? ?? '',
      contentType: json['contentType'] as String? ?? '',
      sizeBytes: json['sizeBytes'] as int? ?? 0,
      expirySeconds: json['expirySeconds'] as int? ?? 0,
      url: json['url'] as String? ?? '',
    );
  }

  FileViewUrlResult toEntity() {
    return FileViewUrlResult(
      fileId: fileId,
      bucket: bucket,
      objectKey: objectKey,
      contentType: contentType,
      sizeBytes: sizeBytes,
      expirySeconds: expirySeconds,
      url: url,
    );
  }
}
