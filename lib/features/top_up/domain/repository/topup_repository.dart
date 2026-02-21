import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/features/top_up/domain/entity/topup_entity.dart';
import 'package:kfon_subscriber/features/top_up/domain/entity/topup_params.dart';

abstract class TopupRepository {

  Future<Either<Failure, TopupRedirectEntity>> initiateTopup(
    TopupParams params,
  );
}
