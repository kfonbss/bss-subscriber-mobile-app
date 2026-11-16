import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/features/self_care/domain/entity/speed_test_entity.dart';

abstract class SpeedTestRepository {
  /// Runs a speed test for the logged-in subscriber.
  Future<Either<Failure, SpeedTestEntity>> runSpeedTest();
}
