import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/core/network/dio_client.dart';
import 'package:kfon_subscriber/features/tranasactions/data/model/transaction_model.dart';
import 'package:kfon_subscriber/features/tranasactions/domain/entity/transaction_entity.dart';
import 'package:kfon_subscriber/features/tranasactions/domain/repository/transaction_repository.dart';

class TransactionRepositoryImp extends TransactionRepository {
  final DioClient _client;

  TransactionRepositoryImp({required DioClient client}) : _client = client;

  @override
  Future<Either<Failure, TransactionPageEntity>> getTransactions({
    required int page,
    required int size,
  }) async {
    final response = await _client.get(
      ApiUrls.rechargeTransactionsURL,
      queryParameters: {'page': page, 'size': size},
    );
    if (response.isSuccess) {
      final model = TransactionPageModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      return Right(model.toEntity());
    } else {
      return Left(response.failure);
    }
  }
}
