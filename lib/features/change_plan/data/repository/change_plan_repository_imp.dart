import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/core/network/dio_client.dart';
import 'package:kfon_subscriber/features/change_plan/data/models/package_new_model.dart';
import 'package:kfon_subscriber/features/change_plan/data/models/recharge_change_plan_response_model.dart';
import 'package:kfon_subscriber/features/change_plan/data/models/recharge_payment_status_model.dart';
import 'package:kfon_subscriber/features/change_plan/data/models/seasonal_discount_model.dart';
import 'package:kfon_subscriber/features/change_plan/data/models/subscriber_discount_response_model.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/package_new_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/recharge_change_plan_redirect_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/recharge_payment_status_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/seasonal_discount_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/discount_details_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/params/get_all_packages_parms.dart';
import 'package:kfon_subscriber/features/change_plan/domain/params/recharge_change_plan_params.dart';
import 'package:kfon_subscriber/features/change_plan/domain/params/subscriber_discount_request_params.dart';
import 'package:kfon_subscriber/features/change_plan/domain/repository/change_plan_repository.dart';

class ChangePlanRepositoryImp extends ChangePlanRepository {
  final DioClient _client;

  ChangePlanRepositoryImp({required DioClient client}) : _client = client;

  @override
  Future<Either<Failure, PackageNewEntity>> getPackages(
    GetAllPackagesParams params,
  ) async {
    final response = await _client.get(
      ApiUrls.listPackagesURL,
      queryParameters: params.toJson(),
    );

    if (response.isSuccess) {
      // final List<dynamic> packagesJson = response.data as List<dynamic>? ?? [];
      // final packages =
      //     packagesJson
      //         .map(
      //           (json) =>
      //               PackageNewModel.fromJson(
      //                 json as Map<String, dynamic>,
      //               ).toEntity(),
      //         )
      //         .toList();
      // return Right(packages);
      return Right(PackageNewModel.fromJson(response.data).toEntity());
    } else {
      return Left(response.failure);
    }
  }

  @override
  Future<Either<Failure, RechargeChangePlanResponseEntity>> rechargeChangePlan(
    RechargeChangePlanParams params,
  ) async {
    final response = await _client.post(
      ApiUrls.rechargeChangePlanURL,
      data: params.toJson(),
    );

    if (response.isSuccess) {
      final responseModel = RechargeChangePlanResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      return Right(responseModel.toEntity());
    } else {
      return Left(response.failure);
    }
  }

  @override
  Future<Either<Failure, RechargePaymentStatusEntity>> getRechargePaymentStatus(
    String orderId,
  ) async {
    final response = await _client.get(
      ApiUrls.rechargePaymentStatus(orderId: orderId),
    );

    if (response.isSuccess) {
      final model = RechargePaymentStatusModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      return Right(model.toEntity());
    } else {
      return Left(response.failure);
    }
  }

  @override
  Future<Either<Failure, SeasonalDiscountEntity>> getSeasonalDiscount(
    String packageId,
  ) async {
    final response = await _client.get(
      ApiUrls.rechargeSeasonId,
      queryParameters: {'packageId': packageId},
    );

    if (response.isSuccess) {
      if (response.data == null) return const Right(SeasonalDiscountEntity());
      final seasonalDiscount = SeasonalDiscountModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      return Right(seasonalDiscount.toEntity());
    } else {
      return Left(response.failure);
    }
  }

  @override
  Future<Either<Failure, List<DiscountDetailsEntity>>> getSubscriberDiscounts(
    List<SubscriberDiscountRequestParams> params,
  ) async {
    final response = await _client.post(
      ApiUrls.subscriberDiscountRuleEngineURL,
      data: params.map((e) => e.toJson()).toList(),
    );

    if (response.isSuccess) {
      final model = SubscriberDiscountResponseModel.fromDynamic(response.data);

      return Right(model.toEntity());
    } else {
      return Left(response.failure);
    }
  }
}
