import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/features/future_recharge/domain/entity/future_recharges_list_response_entity.dart';
import 'package:kfon_subscriber/features/future_recharge/domain/params/get_future_recharges_list_params.dart';
import 'package:dartz/dartz.dart';

abstract class FutureRechargeRepository {
  Future<Either<Failure, FutureRechargesListResponseEntity>> getRechargesList(
    GetFutureRechargesListParams params,bool isFutureRecharge
  );
}
