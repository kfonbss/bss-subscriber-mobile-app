import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entity/tenant_entity.dart';

abstract class TenantRepository {
  Future<Either<Failure, List<TenantEntity>>> getTenants();
}