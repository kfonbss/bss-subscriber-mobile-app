import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/features/profile/domain/entity/account_information_entity.dart';
import 'package:kfon_subscriber/features/profile/domain/entity/profile_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileEntity>> getProfile();
  Future<Either<Failure, AccountInformationEntity>> getAccountInformation();
}
