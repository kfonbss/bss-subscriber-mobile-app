import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:kfon_subscriber/core/network/dio_client.dart';
import 'package:kfon_subscriber/service_locator.dart';

abstract class HomeApiService {
  Future<Either> getHomePageData(String userId);
}

class HomeApiServiceImp extends HomeApiService {
  @override
  Future<Either> getHomePageData(String userId) async {
    var response = await sl<DioClient>().get(
      ApiUrls.homePageURL,
      queryParameters: {'userId': userId},
    );
    if (response.error.isEmpty) {
      return Right(response.data);
    } else {
      return Left(response.message);
    }
  }
}
