import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/core/network/dio_client.dart';
import 'package:kfon_subscriber/features/profile/data/model/account_information_model.dart';
import 'package:kfon_subscriber/features/profile/data/model/profile_model.dart';
import 'package:kfon_subscriber/features/profile/domain/entity/account_information_entity.dart';
import 'package:kfon_subscriber/features/profile/domain/entity/profile_entity.dart';
import 'package:kfon_subscriber/features/profile/domain/repository/profile_repository.dart';

class ProfileRepositoryImp extends ProfileRepository {
  final DioClient _client;

  ProfileRepositoryImp({required DioClient client}) : _client = client;

  @override
  Future<Either<Failure, ProfileEntity>> getProfile() async {
    final response = await _client.get(ApiUrls.profileURL);
    if (response.isSuccess) {
      final profile = ProfileModel.fromJson(response.data);
      return Right(profile);
    } else {
      return Left(response.failure);
    }
  }

  @override
  Future<Either<Failure, AccountInformationEntity>> getAccountInformation() async {
    final response = await _client.get(ApiUrls.accountInformationURL);
    if (response.isSuccess) {
      final accountInfo = AccountInformationModel.fromJson(response.data);
      return Right(accountInfo);
    } else {
      return Left(response.failure);
    }
  }
}
