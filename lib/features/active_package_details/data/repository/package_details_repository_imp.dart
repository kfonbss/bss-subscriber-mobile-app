import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/core/network/api_response.dart';
import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:kfon_subscriber/core/network/dio_client.dart';
import 'package:kfon_subscriber/features/active_package_details/data/model/active_packages_details_model.dart';
import 'package:kfon_subscriber/features/active_package_details/domain/entity/active_packages_details_entity.dart';
import 'package:kfon_subscriber/features/active_package_details/domain/repository/package_details_repository.dart';
import 'package:kfon_subscriber/service_locator.dart';

class PackageDetailsRepositoryImp extends PackageDetailsRepository {
  @override
  Future<
      Either<Failure, ActivePackagesDetailsEntity>> getPackageDetails(String subscriberUuid) async {
    APIResponse response = await sl<DioClient>().get(
      ApiUrls.packageDetailsURL(subscriberUuid: subscriberUuid),
    );
    if (response.isSuccess) {
      final detailsModel = ActivePackagesDetailsModel.fromJson(response.data);
      return Right(detailsModel.toEntity());
    } else {
      return Left(response.failure);
    }
  }
}
