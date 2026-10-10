import 'package:kfon_subscriber/features/future_recharge/domain/entity/future_recharge_item_entity.dart';

class FutureRechargeGroupEntity {
  final DateTime date;
  final int count;
  final List<FutureRechargeItemEntity> recharges;

  const FutureRechargeGroupEntity({
    required this.date,
    required this.count,
    required this.recharges,
  });
}
