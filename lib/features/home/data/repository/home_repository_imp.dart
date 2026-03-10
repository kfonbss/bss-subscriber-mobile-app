import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/core/network/api_response.dart';
import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:kfon_subscriber/core/network/dio_client.dart';
import 'package:kfon_subscriber/features/change_plan/data/models/package_model.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/package_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/params/get_all_packages_parms.dart';
import 'package:kfon_subscriber/features/home/data/model/home_model.dart';
import 'package:kfon_subscriber/features/home/domain/entity/home_entity.dart';
import 'package:kfon_subscriber/features/home/domain/repository/home_repository.dart';
import 'package:kfon_subscriber/service_locator.dart';

class HomeRepositoryImp extends HomeRepository {
  @override
  Future<Either<Failure, HomeEntity>> getHomePageData() async {
    APIResponse response = await sl<DioClient>().get(
      ApiUrls.homePageURL,
    );
    if (response.isSuccess) {
      final homeModel = HomeModel.fromJson(response.data);
      return Right(homeModel.toEntity());
    } else {
      return Left(response.failure);
    }
  }


  @override
  Future<Either<Failure, List<PackageEntity>>> getPackages(
      GetAllPackagesParams params,
      ) async {
    APIResponse response = await sl<DioClient>().get(
      ApiUrls.listPackagesURL,
      queryParameters: params.toJson(),
    );

    if (response.isSuccess) {
      final List<dynamic> packagesJson = response.data as List<dynamic>? ?? [];
      final packages = packagesJson
          .map(
            (json) =>
            PackageModel.fromJson(json as Map<String, dynamic>).toEntity(),
      )
          .toList();
      return Right(packages);
    } else {
      return Left(response.failure);
    }
  }
}
