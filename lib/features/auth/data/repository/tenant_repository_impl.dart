import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:kfon_subscriber/core/network/api_response.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
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
    if (ApiUrls.isRailwire) return _getRailwireStates();

    final response = await sl<DioClient>().get(
      ApiUrls.baseURL == 'https://rwbssdev.sritindia.com/api/'
          ? ApiUrls.lDTenantsURL
          : ApiUrls.tenantsURL,
    );

    if (response.isSuccess) {
      final list = (response.data as List<dynamic>)
          .map(
            (e) => TenantModel.fromJson(e as Map<String, dynamic>).toEntity(),
          )
          .toList();
      // filter only active
      return Right(list.where((e) => e.isActive).toList());
    } else {
      return Left(response.failure);
    }
  }

  Future<Either<Failure, List<TenantEntity>>> _getRailwireStates() async {
    try {
      final json = await sl<DioClient>().getRailwire(
        ApiUrls.railwireStateListURL,
      );
      if (json['status'] != true) {
        final message = json['Message']?.toString() ?? '';
        return Left(
          ServerFailure(message.isNotEmpty ? message : appL10n.somethingWentWrong),
        );
      }
      final list = (json['state_list'] as List<dynamic>)
          .map(
            (e) => TenantModel.fromRailwireJson(
              e as Map<String, dynamic>,
            ).toEntity(),
          )
          .toList();
      return Right(list);
    } catch (e) {
      return Left(APIResponse.fromError(e).failure);
    }
  }
}
