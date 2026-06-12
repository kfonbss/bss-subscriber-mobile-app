import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../service_locator.dart';
import '../../domain/entity/tenant_entity.dart';
import '../../domain/repository/tenant_repository.dart';
import '../model/tenant_model.dart';

class TenantRepositoryImpl implements TenantRepository {
  @override
  Future<Either<Failure, List<TenantEntity>>> getTenants() async {
    final response = await sl<DioClient>().get(ApiUrls.tenantsURL);

    if (response.isSuccess) {
      final list = (response.data as List<dynamic>)
          .map((e) => TenantModel.fromJson(e as Map<String, dynamic>)
          .toEntity())
          .toList();
      // filter only active
      return Right(list.where((e) => e.isActive).toList());
    } else {
      return Left(response.failure);
    }
  }
}