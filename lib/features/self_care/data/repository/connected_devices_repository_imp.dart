import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/core/network/dio_client.dart';
import 'package:kfon_subscriber/core/util/preference_util.dart';
import 'package:kfon_subscriber/features/self_care/data/model/connected_device_model.dart';
import 'package:kfon_subscriber/features/self_care/domain/entity/connected_device_entity.dart';
import 'package:kfon_subscriber/features/self_care/domain/repository/connected_devices_repository.dart';
import 'package:kfon_subscriber/service_locator.dart';

class ConnectedDevicesRepositoryImp extends ConnectedDevicesRepository {
  @override
  Future<Either<Failure, List<ConnectedDeviceEntity>>>
  getConnectedDevices() async {
    // Saved from the home API response (HomeBloc → setUserDetails).
    final subscriberUuid = await PreferenceUtils.getUserId() ?? '';
    if (subscriberUuid.isEmpty) {
      return const Left(ServerFailure('Subscriber not found'));
    }

    final response = await sl<DioClient>().get(
      ApiUrls.connectedDevicesURL(subscriberUuid: subscriberUuid),
    );

    if (!response.isSuccess) return Left(response.failure);
    // `data: null` means no devices, not an error.
    final data = response.data;
    return Right(data is List ? ConnectedDeviceModel.fromJsonList(data) : []);
  }
}
