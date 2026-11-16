import 'package:equatable/equatable.dart';

/// Result of a server-side speed test for the subscriber's connection.
class SpeedTestEntity extends Equatable {
  final double downloadMbps;
  final double uploadMbps;
  final double latencyMs;
  final String server;
  final String location;
  final DateTime? testedAt;

  const SpeedTestEntity({
    required this.downloadMbps,
    required this.uploadMbps,
    required this.latencyMs,
    required this.server,
    required this.location,
    this.testedAt,
  });

  @override
  List<Object?> get props => [
    downloadMbps,
    uploadMbps,
    latencyMs,
    server,
    location,
    testedAt,
  ];
}
