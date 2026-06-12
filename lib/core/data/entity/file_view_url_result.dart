/// Result of file view-url API call.
/// Contains the pre-signed URL to access/preview the file.
class FileViewUrlResult {
  const FileViewUrlResult({
    required this.fileId,
    required this.bucket,
    required this.objectKey,
    required this.contentType,
    required this.sizeBytes,
    required this.expirySeconds,
    required this.url,
  });

  final String fileId;
  final String bucket;
  final String objectKey;
  final String contentType;
  final int sizeBytes;
  final int expirySeconds;
  final String url;

  /// Extracts file extension from objectKey (e.g. "PNG", "pdf", "jpg")
  String get fileExtension {
    final parts = objectKey.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  /// Extracts file name from objectKey
  String get fileName {
    final parts = objectKey.split('/');
    return parts.isNotEmpty ? parts.last : objectKey;
  }
}
