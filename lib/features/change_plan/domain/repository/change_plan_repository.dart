import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/package_new_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/package_tab_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/paginated_packages_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/payment_gateway_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/recharge_change_plan_redirect_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/recharge_payment_status_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/seasonal_discount_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/discount_details_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/params/get_all_packages_parms.dart';
import 'package:kfon_subscriber/features/change_plan/domain/params/recharge_change_plan_params.dart';
import 'package:kfon_subscriber/features/change_plan/domain/params/subscriber_discount_request_params.dart';

abstract class ChangePlanRepository {
  Future<Either<Failure, PackageNewEntity>> getPackages(
    GetAllPackagesParams params,
  );

  Future<Either<Failure, PaginatedPackagesEntity>> getSeasonalPackages({
    required int page,
    required int size,

    required String subscriberId,
    required String packageId,

    String? type,
    String? targetKind,

    String? subscriptionType,
    String? packageType,
    String? search,
  });

  Future<Either<Failure, RechargeChangePlanResponseEntity>> rechargeChangePlan(
    RechargeChangePlanParams params,
  );

  Future<Either<Failure, RechargePaymentStatusEntity>> getRechargePaymentStatus(
    String orderId,
  );

  Future<Either<Failure, SeasonalDiscountEntity>> getSeasonalDiscount(
    String packageId,
  );

  Future<Either<Failure, List<PaymentGatewayEntity>>> getPaymentGateways();
  Future<Either<Failure, List<DiscountDetailsEntity>>> getSubscriberDiscounts(
    List<SubscriberDiscountRequestParams> params,
  );

  Future<Either<Failure, PackageTabEntity>> getPackageTabs({
    required String subscriberId,
    required String packageId,
  });
}
