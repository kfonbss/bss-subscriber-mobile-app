import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/core/network/api_response.dart';
import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:kfon_subscriber/core/network/dio_client.dart';
import 'package:kfon_subscriber/features/offline_recharge/data/model/offline_recharge_data_model.dart';
import 'package:kfon_subscriber/features/offline_recharge/domain/entity/offline_recharge_data_entity.dart';
import 'package:kfon_subscriber/features/offline_recharge/domain/repository/offline_recharge_repository.dart';
import 'package:kfon_subscriber/service_locator.dart';

class OfflineRechargeRepositoryImp extends OfflineRechargeRepository {
  @override
  Future<Either<Failure, OfflineRechargeDataEntity>> getRechargeData(String subscriberUuid) async {
    APIResponse response = await sl<DioClient>().get(ApiUrls.subscriberDetailsURL(subscriberUuid: subscriberUuid));
    if (response.isSuccess) {
      final offlineRechargeData = OfflineRechargeDataModel.fromJson(response.data);
      return Right(offlineRechargeData.toEntity());
    } else {
      return Left(response.failure);
    }
  }
}
