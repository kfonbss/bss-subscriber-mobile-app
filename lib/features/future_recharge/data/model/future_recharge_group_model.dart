import 'package:kfon_subscriber/features/future_recharge/data/model/future_recharge_item_model.dart';
import 'package:kfon_subscriber/features/future_recharge/domain/entity/future_recharge_group_entity.dart';

class FutureRechargeGroupModel {
  final DateTime date;
  final int count;
  final List<FutureRechargeItemModel> recharges;

  const FutureRechargeGroupModel({
    required this.date,
    required this.count,
    required this.recharges,
  });

  factory FutureRechargeGroupModel.fromJson(Map<String, dynamic> json) {
    return FutureRechargeGroupModel(
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      count: json['count'] as int? ?? 0,
      recharges: (json['recharges'] as List<dynamic>? ?? [])
          .map((e) => FutureRechargeItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  FutureRechargeGroupEntity toEntity() {
    return FutureRechargeGroupEntity(
      date: date,
      count: count,
      recharges: recharges.map((e) => e.toEntity()).toList(),
    );
  }
}
