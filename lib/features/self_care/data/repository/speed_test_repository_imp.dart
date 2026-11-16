import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/core/network/dio_client.dart';
import 'package:kfon_subscriber/core/util/preference_util.dart';
import 'package:kfon_subscriber/features/self_care/data/model/speed_test_model.dart';
import 'package:kfon_subscriber/features/self_care/domain/entity/speed_test_entity.dart';
import 'package:kfon_subscriber/features/self_care/domain/repository/speed_test_repository.dart';
import 'package:kfon_subscriber/service_locator.dart';

class SpeedTestRepositoryImp extends SpeedTestRepository {
  @override
  Future<Either<Failure, SpeedTestEntity>> runSpeedTest() async {
    // Saved from the home API response (HomeBloc → setUserDetails).
    final subscriberUuid = await PreferenceUtils.getUserId() ?? '';
    if (subscriberUuid.isEmpty) {
      return const Left(ServerFailure('Subscriber not found'));
    }

    final response = await sl<DioClient>().post(
      ApiUrls.speedTestURL(subscriberUuid: subscriberUuid),
    );

    if (response.isSuccess && response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      return Right(SpeedTestModel.fromJson(data).toEntity());
    }
    return Left(response.failure);
  }
}
