import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:kfon_subscriber/core/network/railwire_api.dart';
import 'package:kfon_subscriber/features/change_plan/data/models/railwire_online_amount_model.dart';

/// RailWire's `onlineamount`, shared by the RailWire Home and Change plan
/// repositories. One instance lives in the service locator (RailWire only), so
/// the Recharge screen's gateways and order summary make one request.
class RailwireOnlineAmountSource {
  RailwireOnlineAmountSource({
    this.sharedFor = const Duration(seconds: 30),
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  /// How long [shared] reuses the last result.
  final Duration sharedFor;

  /// The clock, replaceable in tests.
  final DateTime Function() _now;

  _Call? _last;

  /// A fresh call, e.g. for Home and its refresh. The result is kept for
  /// [shared]. [RailwireOnlineAmountModel.empty] when the call fails.
  Future<RailwireOnlineAmountModel> fetch() async => _start(await _key());

  /// The last result for this subscriber while it's under [sharedFor] old,
  /// else a fresh call. Calls made while one is running share it.
  Future<RailwireOnlineAmountModel> shared() async {
    final key = await _key();
    final last = _last;
    if (last != null &&
        last.key == key &&
        _now().difference(last.startedAt) < sharedFor) {
      return last.value;
    }
    return _start(key);
  }

  /// Drops the kept result, so the next [shared] call is fresh. Called when a
  /// payment or plan change starts, as either changes the amount.
  void clear() => _last = null;

  Future<RailwireOnlineAmountModel> _start(String key) async {
    final call = _Call(key, _now(), _request());
    _last = call;
    final model = await call.value;
    // A failure isn't kept: the next call tries again.
    if (identical(model, RailwireOnlineAmountModel.empty) &&
        identical(_last, call)) {
      _last = null;
    }
    return model;
  }

  Future<RailwireOnlineAmountModel> _request() async {
    final result = await RailwireApi.post(
      ApiUrls.railwireOnlineAmountURL,
      (session) => session.byUsername,
    );
    return result.fold(
      (_) => RailwireOnlineAmountModel.empty,
      RailwireOnlineAmountModel.fromJson,
    );
  }

  /// Per subscriber, so another login never reuses this one's amount.
  Future<String> _key() async {
    final session = await RailwireSession.current();
    return session == null ? '' : '${session.stateCode}|${session.username}';
  }
}

class _Call {
  _Call(this.key, this.startedAt, this.value);

  final String key;
  final DateTime startedAt;
  final Future<RailwireOnlineAmountModel> value;
}
