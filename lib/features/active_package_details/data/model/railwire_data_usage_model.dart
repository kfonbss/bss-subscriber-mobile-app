import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:kfon_subscriber/core/network/railwire_api.dart';

/// The plan's data from RailWire's `userdatausage`, in GB.
class RailwireDataUsageModel {
  /// The unit of `total_alloted` and `total_consumed` when the response has no
  /// `unit` field. Still an open question with the PHP team.
  static const defaultUnit = 'GB';

  static const _bytesPerGb = 1024 * 1024 * 1024;
  static const _mbPerGb = 1024;

  final double totalVolumeGb;
  final double consumedVolumeGb;

  const RailwireDataUsageModel({
    required this.totalVolumeGb,
    required this.consumedVolumeGb,
  });

  static const empty = RailwireDataUsageModel(
    totalVolumeGb: 0,
    consumedVolumeGb: 0,
  );

  double get availableVolumeGb {
    final available = totalVolumeGb - consumedVolumeGb;
    return available < 0 ? 0 : available;
  }

  factory RailwireDataUsageModel.fromJson(Map<String, dynamic> json) {
    final unit = json['unit']?.toString().trim().toUpperCase() ?? '';
    double toGb(dynamic value) {
      final amount = RailwireApi.toDouble(value);
      return switch (unit.isEmpty ? defaultUnit : unit) {
        'B' || 'BYTES' => amount / _bytesPerGb,
        'MB' => amount / _mbPerGb,
        _ => amount,
      };
    }

    return RailwireDataUsageModel(
      totalVolumeGb: toGb(json['total_alloted']),
      consumedVolumeGb: toGb(json['total_consumed']),
    );
  }

  /// [empty] when the call fails, so the plan still shows without its data.
  static Future<RailwireDataUsageModel> fetch() async {
    final result = await RailwireApi.post(
      ApiUrls.railwireUserDataUsageURL,
      (session) => session.bySubscriberId,
    );
    return result.fold((_) => empty, RailwireDataUsageModel.fromJson);
  }
}
