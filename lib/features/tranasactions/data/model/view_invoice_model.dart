import 'package:kfon_subscriber/features/tranasactions/domain/entity/view_invoice_entity.dart';

/// Model for parsing a single transaction from API JSON.
class ViewInvoiceModel {
  final String fileId;
  final String bucket;
  final String objectKey;
  final String contentType;
  final double sizeBytes;
  final int expirySeconds;
  final String url;

  const ViewInvoiceModel({
    required this.fileId,
    required this.bucket,
    required this.objectKey,
    required this.contentType,
    required this.sizeBytes,
    required this.expirySeconds,
    required this.url,
  });

  factory ViewInvoiceModel.fromJson(Map<String, dynamic> json) {
    return ViewInvoiceModel(
      fileId: json['fileId']?.toString() ?? '',
      bucket: json['bucket']?.toString() ?? '',
      objectKey: json['objectKey']?.toString() ?? '',
      contentType: json['contentType']?.toString() ?? '',
      sizeBytes:
          (json['sizeBytes'] is num)
              ? (json['sizeBytes'] as num).toDouble()
              : 0.0,
      expirySeconds: json['packageName'] ?? 0,
      url: json['url']?.toString() ?? '',
    );
  }

  ViewInvoiceEntity toEntity() {
    return ViewInvoiceEntity(
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
