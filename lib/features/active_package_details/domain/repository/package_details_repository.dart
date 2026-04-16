import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/features/active_package_details/domain/entity/active_packages_details_entity.dart';

abstract class PackageDetailsRepository {
  Future<Either<Failure, ActivePackagesDetailsEntity>> getPackageDetails(String subscriberUuid);
}
