import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/core/network/railwire_api.dart';
import 'package:kfon_subscriber/features/active_package_details/data/model/railwire_package_model.dart';
import 'package:kfon_subscriber/features/active_package_details/domain/entity/active_packages_details_entity.dart';
import 'package:kfon_subscriber/features/active_package_details/domain/repository/package_details_repository.dart';

class RailwirePackageDetailsRepositoryImp extends PackageDetailsRepository {
  @override
  Future<Either<Failure, ActivePackagesDetailsEntity>> getPackageDetails(
    String subscriberUuid,
  ) async {
    final result = await RailwireApi.post(
      ApiUrls.railwireCurrentPackageURL,
      (session) => session.bySubscriberId,
    );
    return result.map((data) {
      final package = RailwirePackageModel.fromJson(data);
      return ActivePackagesDetailsEntity(
        packageId: package.packageId,
        packageName: package.packageName,
        speedMbps: 0,
        packageType: '',
        daysLeft: package.daysLeft,
        activeUntil: package.activeUntil,
        renewalFee: 0,
        totalPackageCount: 0,
        availableVolumeGb: 0,
        totalVolumeGb: 0,
        activeAddOns: const [],
      );
    });
  }
}
