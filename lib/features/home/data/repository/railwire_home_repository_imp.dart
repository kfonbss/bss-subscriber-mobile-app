import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/core/network/railwire_api.dart';
import 'package:kfon_subscriber/features/active_package_details/data/model/railwire_data_usage_model.dart';
import 'package:kfon_subscriber/features/active_package_details/data/model/railwire_package_model.dart';
import 'package:kfon_subscriber/features/change_plan/data/models/package_new_model.dart';
import 'package:kfon_subscriber/features/change_plan/data/source/railwire_online_amount_source.dart';
import 'package:kfon_subscriber/features/change_plan/data/models/railwire_package_change_model.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/package_new_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/params/get_all_packages_parms.dart';
import 'package:kfon_subscriber/features/home/data/model/railwire_last_recharge_model.dart';
import 'package:kfon_subscriber/features/home/domain/entity/home_entity.dart';
import 'package:kfon_subscriber/features/home/domain/repository/home_repository.dart';

class RailwireHomeRepositoryImp extends HomeRepository {
  RailwireHomeRepositoryImp({required RailwireOnlineAmountSource onlineAmount})
    : _onlineAmount = onlineAmount;

  final RailwireOnlineAmountSource _onlineAmount;

  /// RailWire has no home API, so it's built from the profile, the package,
  /// its data usage, its renewal amount and the last recharge.
  @override
  Future<Either<Failure, HomeEntity>> getHomePageData() async {
    final (profileResult, packageResult, usage, online, lastRecharge) =
        await (
          RailwireApi.post(
            ApiUrls.railwireUserProfileURL,
            (session) => session.byUsername,
          ),
          RailwireApi.post(
            ApiUrls.railwireCurrentPackageURL,
            (session) => session.bySubscriberId,
          ),
          RailwireDataUsageModel.fetch(),
          _onlineAmount.fetch(),
          RailwireLastRechargeModel.fetch(),
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
          lastTransaction: lastRecharge,
          packageDetails: PackageDetailsEntity(
            packageId: package.packageId,
            packageName: package.packageName,
            speedMbps: 0,
            packageType: '',
            daysLeft: package.daysLeft,
            activeUntil: package.activeUntil,
            renewalFee: online.amount,
            totalPackageCount: 0,
            validity: 0,
            availableVolumeGb: usage.availableVolumeGb,
            totalVolumeGb: usage.totalVolumeGb,
            packageInfoEntity:
                PackageItemModel.fromJson({
                  'id': package.packageId,
                  'packageName': package.packageName,
                  'category': package.category,
                }).toEntity(),
            activeAddOns: const [],
          ),
        );
      }),
    );
  }

  /// The plans the subscriber can change to, from `Subpackagechange`.
  @override
  Future<Either<Failure, PackageNewEntity>> getPackages(
    GetAllPackagesParams params,
  ) async {
    final result = await RailwirePackageChangeModel.fetch();
    return result.map(
      (model) => RailwirePackageChangeModel.packagePage(
        model.matching(params.search),
        params.page,
        params.size,
      ),
    );
  }

  @override
  Future<Either<Failure, void>> requestCallback() async =>
      Left(RailwireApi.unavailable);
}
