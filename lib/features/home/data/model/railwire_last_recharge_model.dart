import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:kfon_subscriber/core/network/railwire_api.dart';
import 'package:kfon_subscriber/features/home/domain/entity/home_entity.dart';

/// The subscriber's latest recharge from RailWire's `lastrechhistory`, for
/// Home's last transaction card.
class RailwireLastRechargeModel {
  /// The `list` object of the response (a single record, despite its name).
  /// Null when there's no recharge or no amount.
  static LastTransactionEntity? fromJson(Map<String, dynamic> json) {
    final record = json['list'];
    if (record is! Map<String, dynamic>) return null;
    final amount = record['amount']?.toString().trim() ?? '';
    if (amount.isEmpty) return null;
    return LastTransactionEntity(
      amount: RailwireApi.toDouble(amount),
      paidOn: DateTime.tryParse(record['lastupdate']?.toString() ?? ''),
    );
  }

  /// Null when the call fails, so Home still loads with the card's placeholder.
  static Future<LastTransactionEntity?> fetch() async {
    final result = await RailwireApi.post(
      ApiUrls.railwireLastRechargeURL,
      (session) => session.bySubscriberId,
    );
    return result.fold((_) => null, fromJson);
  }
}
