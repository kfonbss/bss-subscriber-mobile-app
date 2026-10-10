import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/core/network/dio_client.dart';
import 'package:kfon_subscriber/features/autopay/data/model/autopay_model.dart';
import 'package:kfon_subscriber/features/autopay/domain/entity/autopay_entity.dart';
import 'package:kfon_subscriber/features/autopay/domain/repository/autopay_repository.dart';
import 'package:kfon_subscriber/service_locator.dart';

class AutopayRepositoryImp extends AutopayRepository {
  AutopayRepositoryImp();

  @override
  Future<Either<Failure, AutopayStatus>> getStatus() async {
    try {
      final response = await sl<DioClient>().get(ApiUrls.upiMandateStatus);
      if (!response.isSuccess) return Left(response.failure);
      return Right(parseAutopayStatus(response.data));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AutopayQuoteEntity>> getQuote() async {
    try {
      final response = await sl<DioClient>().get(ApiUrls.upiMandateQuote);
      if (!response.isSuccess) return Left(response.failure);
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        return Left(ServerFailure('Invalid response'));
      }
      return Right(AutopayQuoteModel.fromJson(data).toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> initiate({required String upiId}) async {
    try {
      final response = await sl<DioClient>().post(
        ApiUrls.upiMandateInitiate,
        data: {'upiId': upiId},
      );
      if (!response.isSuccess) return Left(response.failure);
      return Right(response.message);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> revoke() async {
    try {
      final response = await sl<DioClient>().post(ApiUrls.upiMandateRevoke);
      if (!response.isSuccess) return Left(response.failure);
      return Right(response.message);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
