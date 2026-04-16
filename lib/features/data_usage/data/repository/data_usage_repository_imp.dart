import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/core/network/dio_client.dart';
import 'package:kfon_subscriber/features/data_usage/data/model/data_usage_model.dart';
import 'package:kfon_subscriber/features/data_usage/domain/entity/data_usage_entity.dart';
import 'package:kfon_subscriber/features/data_usage/domain/params/get_subscriber_data_usage_params.dart';
import 'package:kfon_subscriber/features/data_usage/domain/repository/data_usage_repository.dart';

class DataUsageRepositoryImp extends DataUsageRepository {
  final DioClient _client;

  DataUsageRepositoryImp({required DioClient client}) : _client = client;

  @override
  Future<Either<Failure, SubscriberDataUsageResponseEntity>>
  getSubscriberDataUsage(GetSubscriberDataUsageParams params) async {
    final response = await _client.get(
      ApiUrls.subscriberDataUsageURL(subscriberUuid: params.subscriberUuid),
      queryParameters: params.toJson(),
    );

    if (response.isSuccess) {
      final data = response.data as Map<String, dynamic>;
      final model = SubscriberDataUsageResponseModel.fromJson(data);
      return Right(model.toEntity());
    } else {
      return Left(response.failure);
    }
  }
}
