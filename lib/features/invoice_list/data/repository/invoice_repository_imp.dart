import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:kfon_subscriber/core/data/entity/file_view_url_result.dart';
import 'package:kfon_subscriber/core/data/model/file_view_url_result_model.dart';
import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/core/network/dio_client.dart';
import 'package:kfon_subscriber/features/invoice_list/data/model/invoice_model.dart';
import 'package:kfon_subscriber/features/invoice_list/domain/entity/invoice_entity.dart';
import 'package:kfon_subscriber/features/invoice_list/domain/repository/invoice_repository.dart';

class InvoiceRepositoryImp extends InvoiceRepository {
  final DioClient _client;

  InvoiceRepositoryImp({required DioClient client}) : _client = client;

  @override
  Future<Either<Failure, InvoicePageEntity>> getInvoices({
    required int page,
    required int size,
  }) async {
    final response = await _client.get(
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
  @override
  Future<Either<Failure, FileViewUrlResult>> getFileViewUrl(
      String fileId,
      ) async {
    try {
      final response = await _client.get(
        ApiUrls.fileViewUrlByFileId(fileId),
      );

      if (response.isSuccess) {
        final data = response.data;
        if (data is! Map<String, dynamic>) {
          return Left(ServerFailure('Invalid response'));
        }
        final inner = data['data'] as Map<String, dynamic>? ?? data;
        final model = FileViewUrlResultModel.fromJson(inner);
        if (model.url.isEmpty) {
          return Left(ServerFailure('File URL not found'));
        }
        return Right(model.toEntity());
      } else {
        return Left(response.failure);
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  @override
  Future<Either<Failure, FileViewUrlResult>> getFileDownloadUrl(
      String fileId,
      ) async {
    try {
      final response = await _client.get(
        ApiUrls.fileDownloadUrlByFileId(fileId),
      );

      if (response.isSuccess) {
        final data = response.data;
        if (data is! Map<String, dynamic>) {
          return Left(ServerFailure('Invalid response'));
        }
        final inner = data['data'] as Map<String, dynamic>? ?? data;
        final model = FileViewUrlResultModel.fromJson(inner);
        if (model.url.isEmpty) {
          return Left(ServerFailure('File URL not found'));
        }
        return Right(model.toEntity());
      } else {
        return Left(response.failure);
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
