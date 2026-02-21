import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/error/failure.dart';

abstract class ProfileRepository {

  Future<Either<Failure, void>> logout(String refreshToken);
}
