import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:kfon_subscriber/core/data/entity/file_view_url_result.dart';
import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/core/network/railwire_api.dart';
import 'package:kfon_subscriber/features/invoice_list/domain/entity/invoice_entity.dart';
import 'package:kfon_subscriber/features/invoice_list/domain/repository/invoice_repository.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';

class RailwireInvoiceRepositoryImp extends InvoiceRepository {
  /// `invoicelist` isn't paged, so the pages are cut here.
  @override
  Future<Either<Failure, InvoicePageEntity>> getInvoices({
    required int page,
    required int size,
  }) async {
    final result = await RailwireApi.post(
      ApiUrls.railwireInvoiceListURL,
      (session) => {...session.byUsername, 'slno': ''},
    );
    return result.map((data) {
      final invoices =
          (data['invoice_data'] as List<dynamic>? ?? [])
              .cast<Map<String, dynamic>>()
              .map(_toInvoice)
              .toList();
      final end = (page + 1) * size;
      return InvoicePageEntity(
        invoices: invoices.skip(page * size).take(size).toList(),
        totalPages: (invoices.length / size).ceil(),
        totalElements: invoices.length,
        isLast: end >= invoices.length,
      );
    });
  }

  /// [InvoiceEntity.fileId] holds the `slno` that `invoicepdf` is keyed by.
  InvoiceEntity _toInvoice(Map<String, dynamic> json) {
    final slno = json['slno']?.toString() ?? '';
    return InvoiceEntity(
      invoiceId: slno,
      invoiceNo: json['invoiceno']?.toString() ?? '',
      amount: RailwireApi.toDouble(json['grossamount']),
      invoiceDate: json['invoicedate']?.toString() ?? '',
      fileId: slno,
    );
  }

  @override
  Future<Either<Failure, FileViewUrlResult>> getFileViewUrl(
    String fileId,
  ) async {
    final result = await RailwireApi.post(
      ApiUrls.railwireInvoicePdfURL,
      (session) => {...session.byUsername, 'slno': fileId},
    );
    return result.flatMap((json) {
      final link = json['invoicelink'];
      final url = link is Map<String, dynamic> ? link['invoicelink'] : null;
      if (url is! String || url.isEmpty) {
        return Left(ServerFailure(appL10n.invoiceFileNotAvailable));
      }
      return Right(
        FileViewUrlResult(
          fileId: fileId,
          bucket: '',
          objectKey: 'invoice_$fileId.pdf',
          contentType: 'application/pdf',
          sizeBytes: 0,
          expirySeconds: 0,
          url: url,
        ),
      );
    });
  }

  @override
  Future<Either<Failure, FileViewUrlResult>> getFileDownloadUrl(
    String fileId,
  ) => getFileViewUrl(fileId);
}
