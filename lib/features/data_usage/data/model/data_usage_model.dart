import 'package:kfon_subscriber/features/data_usage/domain/entity/data_usage_entity.dart';

class NetworkDetailsModel {
  final String mac;
  final String framedIp;
  final String framedIpv6Prefix;
  final String framedIpv6Delegated;

  NetworkDetailsModel({
    required this.mac,
    required this.framedIp,
    required this.framedIpv6Prefix,
    required this.framedIpv6Delegated,
  });

  factory NetworkDetailsModel.fromJson(Map<String, dynamic> json) {
    return NetworkDetailsModel(
      mac: json['mac'] as String? ?? '',
      framedIp: json['framedIp'] as String? ?? '',
      framedIpv6Prefix: json['framedIpv6Prefix'] as String? ?? '',
      framedIpv6Delegated: json['framedIpv6Delegated'] as String? ?? '',
    );
  }

  NetworkDetailsEntity toEntity() {
    return NetworkDetailsEntity(
      mac: mac,
      framedIp: framedIp,
      framedIpv6Prefix: framedIpv6Prefix,
      framedIpv6Delegated: framedIpv6Delegated,
    );
  }
}

class SessionModel {
  final String startTime;
  final String? endTime;
  final String sessionDuration;
  final double uploadMb;
  final double downloadMb;
  final double totalMb;
  final NetworkDetailsModel networkDetails;

  SessionModel({
    required this.startTime,
    this.endTime,
    required this.sessionDuration,
    required this.uploadMb,
    required this.downloadMb,
    required this.totalMb,
    required this.networkDetails,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      startTime: json['startTime'] as String? ?? '',
      endTime: json['endTime'] as String?,
      sessionDuration: json['sessionDuration'] as String? ?? '',
      uploadMb: (json['uploadMb'] as num?)?.toDouble() ?? 0.0,
      downloadMb: (json['downloadMb'] as num?)?.toDouble() ?? 0.0,
      totalMb: (json['totalMb'] as num?)?.toDouble() ?? 0.0,
      networkDetails: NetworkDetailsModel.fromJson(
        json['networkDetails'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  SessionEntity toEntity() {
    return SessionEntity(
      startTime: DateTime.tryParse(startTime) ?? DateTime.now(),
      endTime: endTime != null ? DateTime.tryParse(endTime!) : null,
      sessionDuration: sessionDuration,
      uploadMb: uploadMb,
      downloadMb: downloadMb,
      totalMb: totalMb,
      networkDetails: networkDetails.toEntity(),
    );
  }
}

class GraphDataModel {
  final String day;
  final double usageGb;

  GraphDataModel({required this.day, required this.usageGb});

  factory GraphDataModel.fromJson(Map<String, dynamic> json) {
    return GraphDataModel(
      day: json['day'] as String? ?? '',
      usageGb: (json['usageGb'] as num?)?.toDouble() ?? 0.0,
    );
  }

  GraphDataEntity toEntity() {
    return GraphDataEntity(day: day, usageGb: usageGb);
  }
}

class DataUsageModel {
  final String period;
  final double uploadGb;
  final double downloadGb;
  final double totalGb;
  final List<GraphDataModel> graphData;

  DataUsageModel({
    required this.period,
    required this.uploadGb,
    required this.downloadGb,
    required this.totalGb,
    required this.graphData,
  });

  factory DataUsageModel.fromJson(Map<String, dynamic> json) {
    return DataUsageModel(
      period: json['period'] as String? ?? '',
      uploadGb: (json['uploadGb'] as num?)?.toDouble() ?? 0.0,
      downloadGb: (json['downloadGb'] as num?)?.toDouble() ?? 0.0,
      totalGb: (json['totalGb'] as num?)?.toDouble() ?? 0.0,
      graphData:
          (json['graphData'] as List<dynamic>?)
              ?.map((e) => GraphDataModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  DataUsageEntity toEntity() {
    return DataUsageEntity(
      period: period,
      uploadGb: uploadGb,
      downloadGb: downloadGb,
      totalGb: totalGb,
      graphData: graphData.map((e) => e.toEntity()).toList(),
    );
  }
}

class SubscriberDataUsageResponseModel {
  final String period;
  final DataUsageModel? dataUsage;
  final SessionModel? activeSession;
  final List<SessionModel> sessionHistory;

  SubscriberDataUsageResponseModel({
    required this.period,
    this.dataUsage,
    this.activeSession,
    required this.sessionHistory,
  });

  factory SubscriberDataUsageResponseModel.fromJson(Map<String, dynamic> json) {
    return SubscriberDataUsageResponseModel(
      period: json['period'] as String? ?? '',
      dataUsage: json['dataUsage'] != null
          ? DataUsageModel.fromJson(json['dataUsage'] as Map<String, dynamic>)
          : null,
      activeSession: json['activeSession'] != null
          ? SessionModel.fromJson(json['activeSession'] as Map<String, dynamic>)
          : null,
      sessionHistory:
          (json['sessionHistory'] as List<dynamic>?)
              ?.map((e) => SessionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  SubscriberDataUsageResponseEntity toEntity() {
    return SubscriberDataUsageResponseEntity(
      period: period,
      dataUsage: dataUsage?.toEntity(),
      activeSession: activeSession?.toEntity(),
      sessionHistory: sessionHistory.map((e) => e.toEntity()).toList(),
    );
  }
}
