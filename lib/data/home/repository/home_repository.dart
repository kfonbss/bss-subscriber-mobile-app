import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/data/home/source/home_api_service.dart';
import 'package:kfon_subscriber/domain/home/repository/home_repository.dart';
import 'package:kfon_subscriber/service_locator.dart';

class HomeRepositoryImp extends HomeRepository {

  @override
  Future<Either> getHomePageData(String userId)async {
    return await sl<HomeApiService>().getHomePageData(userId);
  }
}
