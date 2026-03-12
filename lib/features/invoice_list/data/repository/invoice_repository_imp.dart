import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/core/network/api_response.dart';
import 'package:kfon_subscriber/core/network/dio_client.dart';
import 'package:kfon_subscriber/features/invoice_list/data/model/invoice_model.dart';
import 'package:kfon_subscriber/features/invoice_list/domain/entity/invoice_entity.dart';
import 'package:kfon_subscriber/features/invoice_list/domain/repository/invoice_repository.dart';
import 'package:kfon_subscriber/service_locator.dart';

class InvoiceRepositoryImp extends InvoiceRepository {
  @override
  Future<Either<Failure, InvoicePageEntity>> getInvoices({
    required int page,
    required int size,
  }) async {
    APIResponse response = await sl<DioClient>().get(
      ApiUrls.invoicesURL,
      queryParameters: {'page': page, 'size': size},
    );
    if (response.isSuccess) {
      final model = InvoicePageModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      return Right(model.toEntity());
    } else {
      return Left(response.failure);
    }
  }
}
