
import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/core/network/api_response.dart';
import 'package:kfon_subscriber/core/network/dio_client.dart';
import 'package:kfon_subscriber/features/profile/domain/repository/profile_repository.dart';
import 'package:kfon_subscriber/service_locator.dart';

class ProfileRepositoryImp extends ProfileRepository {

  @override
  Future<Either<Failure, void>> logout(String refreshToken) async {
    APIResponse response = await sl<DioClient>().post(
      'ApiUrls.logoutURL',
      data: {'refreshToken': refreshToken},
    );
    if (response.isSuccess) {
      return const Right(null);
    } else {
      return Left(response.failure);
    }
  }
}
