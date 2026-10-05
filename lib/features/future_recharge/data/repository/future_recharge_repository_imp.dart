import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/core/network/api_response.dart';
import 'package:kfon_subscriber/core/network/dio_client.dart';
import 'package:kfon_subscriber/features/future_recharge/data/model/future_recharges_list_response_model.dart';
import 'package:kfon_subscriber/features/future_recharge/domain/entity/future_recharges_list_response_entity.dart';
import 'package:kfon_subscriber/features/future_recharge/domain/params/get_future_recharges_list_params.dart';
import 'package:kfon_subscriber/features/future_recharge/domain/repository/future_recharge_repository.dart';
import 'package:kfon_subscriber/service_locator.dart';
import 'package:dartz/dartz.dart';

class FutureRechargeRepositoryImp extends FutureRechargeRepository {
  @override
  Future<Either<Failure, FutureRechargesListResponseEntity>> getRechargesList(
    GetFutureRechargesListParams params,
    bool isFutureRecharge,
  ) async {
    APIResponse response = await sl<DioClient>().get(
      ApiUrls.furtureRechargesListURL,
      queryParameters: params.toQueryParams(),
    );

    if (response.isSuccess) {
      final data = response.data as Map<String, dynamic>;
      final model = FutureRechargesListResponseModel.fromJson(data);
      return Right(model.toEntity());
    } else {
      return Left(response.failure);
    }
  }

}
