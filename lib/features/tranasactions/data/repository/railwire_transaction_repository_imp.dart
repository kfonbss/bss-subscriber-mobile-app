import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/core/network/railwire_api.dart';
import 'package:kfon_subscriber/features/tranasactions/domain/entity/transaction_entity.dart';
import 'package:kfon_subscriber/features/tranasactions/domain/entity/transaction_filter.dart';
import 'package:kfon_subscriber/features/tranasactions/domain/repository/transaction_repository.dart';

class RailwireTransactionRepositoryImp extends TransactionRepository {
  /// The API document only shows this value; what each one means is an open
  /// question with the PHP team.
  static const _historyType = '2';

  /// `recharge_history` has no paging or filters, so both are applied here.
  @override
  Future<Either<Failure, TransactionPageEntity>> getTransactions({
    required int page,
    required int size,
    TransactionFilter filter = TransactionFilter.none,
  }) async {
    final result = await RailwireApi.post(
      ApiUrls.railwireRechargeHistoryURL,
      (session) => {...session.byUsername, 'history_type': _historyType},
    );
    return result.map((data) {
      final transactions =
          (data['recharge_details'] as List<dynamic>? ?? [])
              .cast<Map<String, dynamic>>()
              .map(_toTransaction)
              .where((txn) => _matches(txn, filter))
              .toList();
      return TransactionPageEntity(
        transactions: transactions.skip(page * size).take(size).toList(),
        totalPages: (transactions.length / size).ceil(),
        totalElements: transactions.length,
        isLast: (page + 1) * size >= transactions.length,
      );
    });
  }

  /// Package, expiry, gateway and payer aren't in `recharge_history` yet.
  TransactionEntity _toTransaction(Map<String, dynamic> json) =>
      TransactionEntity(
        transactionId: json['ordernumber']?.toString() ?? '',
        bssNo: json['ordernumber']?.toString() ?? '',
        txnReference: json['txnid']?.toString() ?? '',
        amount: RailwireApi.toDouble(json['amount']),
        packageName: '',
        expiryDate: '',
        status: json['status']?.toString() ?? '',
        paidOn: json['order_time']?.toString() ?? '',
        paidBy: '',
        paymentGateway: '',
        responseMessage: json['respmsg']?.toString() ?? '',
        fileId: '',
      );

  bool _matches(TransactionEntity txn, TransactionFilter filter) {
    final status = filter.status;
    if (status != null && status.toUpperCase() != txn.status.toUpperCase()) {
      return false;
    }
    if (!filter.hasDateRange) return true;

    final paidOn = DateTime.tryParse(txn.paidOn);
    if (paidOn == null) return false;
    final day = DateTime(paidOn.year, paidOn.month, paidOn.day);
    return !day.isBefore(filter.fromDate!) && !day.isAfter(filter.toDate!);
  }
}
