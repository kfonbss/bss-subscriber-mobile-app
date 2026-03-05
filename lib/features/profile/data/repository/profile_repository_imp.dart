import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/core/network/api_response.dart';
import 'package:kfon_subscriber/core/network/dio_client.dart';
import 'package:kfon_subscriber/features/profile/data/model/profile_model.dart';
import 'package:kfon_subscriber/features/profile/domain/entity/profile_entity.dart';
import 'package:kfon_subscriber/features/profile/domain/repository/profile_repository.dart';
import 'package:kfon_subscriber/service_locator.dart';

class ProfileRepositoryImp extends ProfileRepository {
  @override
  Future<Either<Failure, ProfileEntity>> getProfile() async {
    APIResponse response = await sl<DioClient>().get(ApiUrls.profileURL);
    if (response.isSuccess) {
      final profile = ProfileModel.fromJson(response.data);
      return Right(profile);
    } else {
      return Left(response.failure);
    }
  }
}
