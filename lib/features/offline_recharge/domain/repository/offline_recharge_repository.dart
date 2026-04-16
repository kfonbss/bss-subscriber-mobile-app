import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/features/offline_recharge/domain/entity/offline_recharge_data_entity.dart';

abstract class OfflineRechargeRepository {
  Future<Either<Failure, OfflineRechargeDataEntity>> getRechargeData(String subscriberUuid);
}
