import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/core/network/railwire_api.dart';
import 'package:kfon_subscriber/features/active_package_details/data/model/railwire_package_model.dart';
import 'package:kfon_subscriber/features/change_plan/data/models/package_new_model.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/package_new_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/params/get_all_packages_parms.dart';
import 'package:kfon_subscriber/features/home/domain/entity/home_entity.dart';
import 'package:kfon_subscriber/features/home/domain/repository/home_repository.dart';

class RailwireHomeRepositoryImp extends HomeRepository {
  /// RailWire has no home API, so it's built from the profile and package.
  @override
  Future<Either<Failure, HomeEntity>> getHomePageData() async {
    final (profileResult, packageResult) =
        await (
          RailwireApi.post(
            ApiUrls.railwireUserProfileURL,
            (session) => session.byUsername,
          ),
          RailwireApi.post(
            ApiUrls.railwireCurrentPackageURL,
            (session) => session.bySubscriberId,
          ),
        ).wait;

    return profileResult.flatMap(
      (profile) => packageResult.map((data) {
        final package = RailwirePackageModel.fromJson(data);
        return HomeEntity(
          firstName: profile['firstname']?.toString() ?? '',
          username: profile['username']?.toString() ?? '',
          balance: RailwireApi.toDouble(profile['balance']),
          lastUpdated: DateTime.now(),
          subscriberId: profile['subscriberid']?.toString() ?? '',
          packageDetails: PackageDetailsEntity(
            packageId: package.packageId,
            packageName: package.packageName,
            speedMbps: 0,
            packageType: '',
            daysLeft: package.daysLeft,
            activeUntil: package.activeUntil,
            renewalFee: 0,
            totalPackageCount: 0,
            validity: 0,
            availableVolumeGb: 0,
            totalVolumeGb: 0,
            packageInfoEntity:
                PackageItemModel.fromJson({
                  'id': package.packageId,
                  'packageName': package.packageName,
                }).toEntity(),
            activeAddOns: const [],
          ),
        );
      }),
    );
  }

  @override
  Future<Either<Failure, PackageNewEntity>> getPackages(
    GetAllPackagesParams params,
  ) async => Left(RailwireApi.unavailable);

  @override
  Future<Either<Failure, void>> requestCallback() async =>
      Left(RailwireApi.unavailable);
}
