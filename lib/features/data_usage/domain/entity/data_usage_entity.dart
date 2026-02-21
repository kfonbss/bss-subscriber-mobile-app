import 'package:equatable/equatable.dart';

/// Network details for a session
class NetworkDetailsEntity extends Equatable {
  final String mac;
  final String framedIp;
  final String framedIpv6Prefix;
  final String framedIpv6Delegated;

  const NetworkDetailsEntity({
    required this.mac,
    required this.framedIp,
    required this.framedIpv6Prefix,
    required this.framedIpv6Delegated,
  });

  @override
  List<Object?> get props => [
    mac,
    framedIp,
    framedIpv6Prefix,
    framedIpv6Delegated,
  ];
}

/// Session entity used for both active session and session history
class SessionEntity extends Equatable {
  final DateTime startTime;
  final DateTime? endTime;
  final String sessionDuration;
  final double uploadMb;
  final double downloadMb;
  final double totalMb;
  final NetworkDetailsEntity networkDetails;

  const SessionEntity({
    required this.startTime,
    this.endTime,
    required this.sessionDuration,
    required this.uploadMb,
    required this.downloadMb,
    required this.totalMb,
    required this.networkDetails,
  });

  @override
  List<Object?> get props => [
    startTime,
    endTime,
    sessionDuration,
    uploadMb,
    downloadMb,
    totalMb,
    networkDetails,
  ];
}

/// Data usage graph data point
class GraphDataEntity extends Equatable {
  final String day;
  final double usageGb;

  const GraphDataEntity({required this.day, required this.usageGb});

  @override
  List<Object?> get props => [day, usageGb];
}

/// Data usage entity
class DataUsageEntity extends Equatable {
  final String period;
  final double uploadGb;
  final double downloadGb;
  final double totalGb;
  final List<GraphDataEntity> graphData;

  const DataUsageEntity({
    required this.period,
    required this.uploadGb,
    required this.downloadGb,
    required this.totalGb,
    required this.graphData,
  });

  @override
  List<Object?> get props => [period, uploadGb, downloadGb, totalGb, graphData];
}

/// Subscriber data usage response entity
class SubscriberDataUsageResponseEntity extends Equatable {
  final String period;
  final DataUsageEntity? dataUsage;
  final SessionEntity? activeSession;
  final List<SessionEntity> sessionHistory;

  const SubscriberDataUsageResponseEntity({
    required this.period,
    this.dataUsage,
    this.activeSession,
    this.sessionHistory = const [],
  });

  @override
  List<Object?> get props => [period, dataUsage, activeSession, sessionHistory];
}
