import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/core/network/api_response.dart';
import 'package:kfon_subscriber/core/network/dio_client.dart';
import 'package:kfon_subscriber/features/change_plan/data/models/package_new_model.dart';
import 'package:kfon_subscriber/features/change_plan/data/models/package_tab_model.dart';
import 'package:kfon_subscriber/features/change_plan/data/models/payment_gateway_model.dart';
import 'package:kfon_subscriber/features/change_plan/data/models/recharge_change_plan_response_model.dart';
import 'package:kfon_subscriber/features/change_plan/data/models/recharge_payment_status_model.dart';
import 'package:kfon_subscriber/features/change_plan/data/models/seasonal_discount_model.dart';
import 'package:kfon_subscriber/features/change_plan/data/models/seasonal_package_model.dart';
import 'package:kfon_subscriber/features/change_plan/data/models/subscriber_discount_response_model.dart';
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
import 'package:kfon_subscriber/features/change_plan/domain/repository/change_plan_repository.dart';
import 'package:kfon_subscriber/service_locator.dart';

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
        message: response.message,
      );
      return Right(responseModel.toEntity());
    } else {
      return Left(response.failure);
    }
  }

  @override
  Future<Either<Failure, PackageTabEntity>> getPackageTabs({
    required String subscriberId,
    required String packageId,
  }) async {
    final response = await sl<DioClient>().post(
      ApiUrls.packageTabURL,
      data: {'subscriberId': subscriberId, 'packageId': packageId},
    );
    if (response.isSuccess) {
      final model = PackageTabModel.fromJson(response.data);
      return Right(model.toEntity());
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

  @override
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
  }) async {
    final queryParameters = <String, dynamic>{
      'page': page,
      'size': size,
      if (subscriptionType != null && subscriptionType.trim().isNotEmpty)
        'subscriptionType': subscriptionType.trim(),
      if (packageType != null && packageType.trim().isNotEmpty)
        'packageType': packageType.trim(),
      if (type != null && type.trim().isNotEmpty) 'type': type.trim(),
      if (type != null &&
          type.trim().isNotEmpty &&
          type.trim() == 'CHANGE_PACKAGE')
        if (targetKind != null && targetKind.trim().isNotEmpty)
          'targetKind': targetKind.trim(),
      if (targetKind != null && targetKind.trim().isNotEmpty)
        'serviceType': targetKind.trim(),
      if (subscriberId.trim().isNotEmpty) 'subscriberId': subscriberId.trim(),

      if (packageId.trim().isNotEmpty) 'packageId': packageId.trim(),
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
    };
    final dioClient = sl<DioClient>();
    final APIResponse response = await dioClient.post(
      ApiUrls.seasonalPreviewPackagesURL,
      data: queryParameters,
    );

    if (!response.isSuccess) {
      return Left(response.failure);
    }

    final dynamic raw = response.data;
    final Map<String, dynamic> map = raw is Map<String, dynamic> ? raw : {};
    final dynamic nestedData = map['data'];
    final Map<String, dynamic> payload =
        nestedData is Map<String, dynamic> ? nestedData : map;
    final List<dynamic> content = payload['content'] as List<dynamic>? ?? [];

    final packages =
        content
            .map(
              (json) =>
                  SeasonalPackageModel.fromJson(
                    json as Map<String, dynamic>,
                  ).toEntity(),
            )
            .toList();

    final totalPages = (payload['totalPages'] as num?)?.toInt() ?? 0;
    final totalElements = (payload['totalElements'] as num?)?.toInt() ?? 0;
    final number = (payload['number'] as num?)?.toInt() ?? page;
    final pageSize = (payload['size'] as num?)?.toInt() ?? size;
    final last = payload['last'] as bool? ?? (number + 1 >= totalPages);

    return Right(
      PaginatedPackagesEntity(
        content: packages,
        totalPages: totalPages,
        totalElements: totalElements,
        last: last,
        number: number,
        size: pageSize,
      ),
    );
  }

  @override
  Future<Either<Failure, List<PaymentGatewayEntity>>>
  getPaymentGateways() async {
    try {
      final APIResponse response = await sl<DioClient>().get(
        ApiUrls.paymentGateways,
      );

      if (response.isSuccess) {
        final list =
            (response.data as List<dynamic>)
                .map(
                  (e) =>
                      PaymentGatewayModel.fromJson(e as Map<String, dynamic>),
                )
                .map((m) => m.toEntity())
                .toList();
        return Right(list);
      }
      return Left(response.failure);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
