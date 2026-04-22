/// Entity representing a single recharge transaction.
class ViewInvoiceEntity {
  final String fileId;
  final String bucket;
  final String objectKey;
  final String contentType;
  final double sizeBytes;
  final int expirySeconds;
  final String url;

  const ViewInvoiceEntity({
    required this.fileId,
    required this.bucket,
    required this.objectKey,
    required this.contentType,
    required this.sizeBytes,
    required this.expirySeconds,
    required this.url
  });
}
