import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/features/tranasactions/domain/entity/transaction_entity.dart';

abstract class TransactionRepository {
  Future<Either<Failure, TransactionPageEntity>> getTransactions({
    required int page,
    required int size,
  });
}
