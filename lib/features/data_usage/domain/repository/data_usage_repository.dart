import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/features/data_usage/domain/entity/data_usage_entity.dart';
import 'package:kfon_subscriber/features/data_usage/domain/params/get_subscriber_data_usage_params.dart';
import 'package:dartz/dartz.dart';


abstract class DataUsageRepository {

  Future<Either<Failure, SubscriberDataUsageResponseEntity>>
  getSubscriberDataUsage(GetSubscriberDataUsageParams params);
}
