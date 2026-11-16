import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/features/self_care/domain/entity/connected_device_entity.dart';

abstract class ConnectedDevicesRepository {
  /// Devices connected to the logged-in subscriber's router.
  Future<Either<Failure, List<ConnectedDeviceEntity>>> getConnectedDevices();
}
