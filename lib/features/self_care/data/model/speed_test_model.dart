import 'package:kfon_subscriber/features/self_care/domain/entity/speed_test_entity.dart';

/// `data` of GET `/mobile/subscribers/{subscriberUuid}/speed-test`.
class SpeedTestModel {
  final double downloadMbps;
  final double uploadMbps;
  final double latencyMs;
  final String server;
  final String location;
  final DateTime? testedAt;

  const SpeedTestModel({
    required this.downloadMbps,
    required this.uploadMbps,
    required this.latencyMs,
    required this.server,
    required this.location,
    this.testedAt,
  });

  factory SpeedTestModel.fromJson(Map<String, dynamic> json) {
    return SpeedTestModel(
      downloadMbps: _toDouble(json['downloadMbps']),
      uploadMbps: _toDouble(json['uploadMbps']),
      latencyMs: _toDouble(json['latencyMs']),
      server: json['server']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      testedAt: DateTime.tryParse(json['testedAt']?.toString() ?? ''),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  SpeedTestEntity toEntity() => SpeedTestEntity(
    downloadMbps: downloadMbps,
    uploadMbps: uploadMbps,
    latencyMs: latencyMs,
    server: server,
    location: location,
    testedAt: testedAt,
  );
}
