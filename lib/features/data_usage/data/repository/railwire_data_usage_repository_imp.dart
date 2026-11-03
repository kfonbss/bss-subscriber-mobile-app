import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/core/network/railwire_api.dart';
import 'package:kfon_subscriber/features/data_usage/domain/entity/data_usage_entity.dart';
import 'package:kfon_subscriber/features/data_usage/domain/params/get_subscriber_data_usage_params.dart';
import 'package:kfon_subscriber/features/data_usage/domain/repository/data_usage_repository.dart';

/// Built from `showsession` alone: its octets have a known unit, while the unit
/// of the `userdatausage` totals is an open question with the PHP team. The
/// daily graph stays empty until `userdatausage` sends `daily_usage`.
class RailwireDataUsageRepositoryImp extends DataUsageRepository {
  static const _bytesPerMb = 1024 * 1024;
  static const _mbPerGb = 1024;

  @override
  Future<Either<Failure, SubscriberDataUsageResponseEntity>>
  getSubscriberDataUsage(GetSubscriberDataUsageParams params) async {
    final result = await RailwireApi.post(
      ApiUrls.railwireShowSessionURL,
      (session) => session.byUsername,
    );
    return result.map((data) {
      final sessions =
          (data['radData'] as List<dynamic>? ?? [])
              .cast<Map<String, dynamic>>()
              .map(_toSession)
              .whereType<SessionEntity>()
              .toList()
            ..sort((a, b) => b.startTime.compareTo(a.startTime));

      final from = DateTime.now().subtract(_periodLength(params.period));
      final inPeriod = sessions.where((s) => s.startTime.isAfter(from));
      double total(double Function(SessionEntity) mb) =>
          inPeriod.fold<double>(0, (sum, s) => sum + mb(s)) / _mbPerGb;

      return SubscriberDataUsageResponseEntity(
        period: params.period,
        dataUsage: DataUsageEntity(
          period: params.period,
          uploadGb: total((s) => s.uploadMb),
          downloadGb: total((s) => s.downloadMb),
          totalGb: total((s) => s.totalMb),
          graphData: const [],
        ),
        activeSession: sessions.where((s) => s.endTime == null).firstOrNull,
        sessionHistory: sessions.where((s) => s.endTime != null).toList(),
      );
    });
  }

  Duration _periodLength(String period) => switch (period.toLowerCase()) {
    'day' || 'daily' => const Duration(days: 1),
    'week' || 'weekly' => const Duration(days: 7),
    'year' || 'yearly' => const Duration(days: 365),
    _ => const Duration(days: 30),
  };

  /// Null for a session without a readable start time.
  SessionEntity? _toSession(Map<String, dynamic> json) {
    final start = DateTime.tryParse(_text(json['acctstarttime']));
    if (start == null) return null;

    final end = DateTime.tryParse(_text(json['acctstoptime']));
    final uploadMb = RailwireApi.toDouble(json['acctinputoctets']) / _bytesPerMb;
    final downloadMb =
        RailwireApi.toDouble(json['acctoutputoctets']) / _bytesPerMb;
    return SessionEntity(
      startTime: start,
      endTime: end,
      sessionDuration: _duration((end ?? DateTime.now()).difference(start)),
      uploadMb: uploadMb,
      downloadMb: downloadMb,
      totalMb: uploadMb + downloadMb,
      networkDetails: NetworkDetailsEntity(
        mac: _text(json['callingstationid']),
        framedIp: _text(json['framedipaddress']),
        framedIpv6Prefix: _text(json['framedipv6prefix']),
        framedIpv6Delegated: _text(json['delegatedipv6prefix']),
      ),
    );
  }

  /// RailWire pads these values with spaces.
  String _text(dynamic value) => value?.toString().trim() ?? '';

  String _duration(Duration duration) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${twoDigits(duration.inHours)}:'
        '${twoDigits(duration.inMinutes % 60)}:'
        '${twoDigits(duration.inSeconds % 60)}';
  }
}
