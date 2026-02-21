import 'package:kfon_subscriber/presentation/page_component/status_badge.dart';

class TransactionItem {
  final String bssNo;
  final String date;
  final TransactionStatus status;

  const TransactionItem({
    required this.bssNo,
    required this.date,
    required this.status,
  });
}