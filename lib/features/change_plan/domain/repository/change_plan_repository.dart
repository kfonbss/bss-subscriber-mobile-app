import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/package_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/package_new_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/recharge_change_plan_redirect_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/recharge_payment_status_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/params/change_plan_request_params.dart';
import 'package:kfon_subscriber/features/change_plan/domain/params/get_all_packages_parms.dart';
import 'package:kfon_subscriber/features/change_plan/domain/params/recharge_change_plan_params.dart';

abstract class ChangePlanRepository {
  Future<Either<Failure, PackageNewEntity>> getPackages(
    GetAllPackagesParams params,
  );

  Future<Either<Failure, void>> changePlan(
    String subscriberUuid,
    ChangePlanRequestParams params,
  );

  Future<Either<Failure, RechargeChangePlanResponseEntity>> rechargeChangePlan(
    RechargeChangePlanParams params,
  );

  Future<Either<Failure, RechargePaymentStatusEntity>> getRechargePaymentStatus(
    String orderId,
  );
}
