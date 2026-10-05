import 'package:kfon_subscriber/features/future_recharge/domain/entity/future_recharge_summary_entity.dart';

class FutureRechargeSummaryModel {
  final int total;
  final int wallet;
  final int direct;

  const FutureRechargeSummaryModel({
    required this.total,
    required this.wallet,
    required this.direct,
  });

  factory FutureRechargeSummaryModel.fromJson(Map<String, dynamic> json) {
    return FutureRechargeSummaryModel(
      total: json['total'] as int? ?? 0,
      wallet: json['wallet'] as int? ?? 0,
      direct: json['direct'] as int? ?? 0,
    );
  }

  FutureRechargeSummaryEntity toEntity() {
    return FutureRechargeSummaryEntity(
      total: total,
      wallet: wallet,
      direct: direct,
    );
  }
}
