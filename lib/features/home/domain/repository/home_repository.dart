import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/package_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/package_new_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/params/get_all_packages_parms.dart';
import 'package:kfon_subscriber/features/home/domain/entity/home_entity.dart';

abstract class HomeRepository {
  Future<Either<Failure, HomeEntity>> getHomePageData();
  Future<Either<Failure, PackageNewEntity>> getPackages(
      GetAllPackagesParams params,
      );
}
