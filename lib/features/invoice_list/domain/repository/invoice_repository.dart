import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/data/entity/file_view_url_result.dart';
import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/features/invoice_list/domain/entity/invoice_entity.dart';

abstract class InvoiceRepository {
  Future<Either<Failure, InvoicePageEntity>> getInvoices({
    required int page,
    required int size,
  });
  Future<Either<Failure, FileViewUrlResult>> getFileViewUrl(String fileId);
  Future<Either<Failure, FileViewUrlResult>> getFileDownloadUrl(String fileId);
}
