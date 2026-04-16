import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/core/network/dio_client.dart';
import 'package:kfon_subscriber/features/top_up/data/model/topup_model.dart';
import 'package:kfon_subscriber/features/top_up/domain/entity/topup_entity.dart';
import 'package:kfon_subscriber/features/top_up/domain/entity/topup_params.dart';
import 'package:kfon_subscriber/features/top_up/domain/repository/topup_repository.dart';

class ToupRepositoryImp extends TopupRepository {
  final DioClient _client;

  ToupRepositoryImp({required DioClient client}) : _client = client;

  @override
  Future<Either<Failure, TopupRedirectEntity>> initiateTopup(
    TopupParams params,
  ) async {
    final response = await _client.post(
      ApiUrls.walletTopupURL,
      data: params.toJson(),
    );
    if (response.isSuccess) {
      final model = TopupRedirectModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      return Right(model.toEntity());
    } else {
      return Left(response.failure);
    }
  }
}
