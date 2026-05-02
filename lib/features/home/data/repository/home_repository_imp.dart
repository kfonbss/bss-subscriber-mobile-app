import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/core/network/dio_client.dart';
import 'package:kfon_subscriber/features/change_plan/data/models/package_model.dart';
import 'package:kfon_subscriber/features/change_plan/data/models/package_new_model.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/package_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/package_new_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/params/get_all_packages_parms.dart';
import 'package:kfon_subscriber/features/home/data/model/home_model.dart';
import 'package:kfon_subscriber/features/home/domain/entity/home_entity.dart';
import 'package:kfon_subscriber/features/home/domain/repository/home_repository.dart';

class HomeRepositoryImp extends HomeRepository {
  final DioClient _client;

  HomeRepositoryImp({required DioClient client}) : _client = client;

  @override
  Future<Either<Failure, HomeEntity>> getHomePageData() async {
    final response = await _client.get(ApiUrls.homePageURL);
    if (response.isSuccess) {
      return Right(HomeModel.fromJson(response.data).toEntity());
    } else {
      return Left(response.failure);
    }
  }

  @override
  Future<Either<Failure, PackageNewEntity>> getPackages(
    GetAllPackagesParams params,
  ) async {
    final response = await _client.get(
      ApiUrls.listPackagesURL,
      queryParameters: params.toJson(),
    );
    if (response.isSuccess) {
      // final packagesJson = (response.data as List?) ?? [];
      // final packages = packagesJson
      //     .map((json) =>
      //         PackageModel.fromJson(json as Map<String, dynamic>).toEntity())
      //     .toList();
      // return Right(packages);
      return Right(PackageNewModel.fromJson(response.data).toEntity());
    } else {
      return Left(response.failure);
    }
  }
}
