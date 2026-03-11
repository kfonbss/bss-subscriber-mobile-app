import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/core/network/api_response.dart';
import 'package:kfon_subscriber/core/network/dio_client.dart';
import 'package:kfon_subscriber/features/change_plan/data/models/package_model.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/package_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/params/change_plan_request_params.dart';
import 'package:kfon_subscriber/features/change_plan/domain/params/recharge_change_plan_params.dart';
import 'package:kfon_subscriber/features/change_plan/data/models/recharge_change_plan_response_model.dart';
import 'package:kfon_subscriber/features/change_plan/data/models/recharge_payment_status_model.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/recharge_change_plan_redirect_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/recharge_payment_status_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/params/get_all_packages_parms.dart';
import 'package:kfon_subscriber/features/change_plan/domain/repository/change_plan_repository.dart';
import 'package:kfon_subscriber/service_locator.dart';

class ChangePlanRepositoryImp extends ChangePlanRepository {
  @override
  Future<Either<Failure, List<PackageEntity>>> getPackages(
    GetAllPackagesParams params,
  ) async {
    APIResponse response = await sl<DioClient>().get(
      ApiUrls.listPackagesURL,
      queryParameters: params.toJson(),
    );

    if (response.isSuccess) {
      final List<dynamic> packagesJson = response.data as List<dynamic>? ?? [];
      final packages =
          packagesJson
              .map(
                (json) =>
                    PackageModel.fromJson(
                      json as Map<String, dynamic>,
                    ).toEntity(),
              )
              .toList();
      return Right(packages);
    } else {
      return Left(response.failure);
    }
  }

  @override
  Future<Either<Failure, void>> changePlan(
    String subscriberUuid,
    ChangePlanRequestParams params,
  ) async {
    APIResponse response = await sl<DioClient>().patch(
      ApiUrls.changePlanURL(subscriberUuid: subscriberUuid),
      data: params.toJson(),
    );

    if (response.isSuccess) {
      return const Right(null);
    } else {
      return Left(response.failure);
    }
  }

  @override
  Future<Either<Failure, RechargeChangePlanResponseEntity>> rechargeChangePlan(
    RechargeChangePlanParams params,
  ) async {
    APIResponse response = await sl<DioClient>().post(
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
    APIResponse response = await sl<DioClient>().get(
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
}
