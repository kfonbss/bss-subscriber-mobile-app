import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/core/network/api_response.dart';
import 'package:kfon_subscriber/core/network/dio_client.dart';
import 'package:kfon_subscriber/core/util/preference_util.dart';
import 'package:kfon_subscriber/features/auth/data/model/railwire_user_model.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/service_locator.dart';

/// The logged-in subscriber. RailWire has no user token, so every call sends
/// these in its body.
class RailwireSession {
  final String username;
  final String subscriberId;

  /// The `stcode` sent with every call, e.g. `ka.railwire.co.in` or `KL`.
  final String stateCode;

  const RailwireSession({
    required this.username,
    required this.subscriberId,
    required this.stateCode,
  });

  Map<String, dynamic> get byUsername => {
    'stcode': stateCode,
    'username': username,
  };

  Map<String, dynamic> get bySubscriberId => {
    'stcode': stateCode,
    'subscriberid': subscriberId,
  };

  /// Null when nobody is logged in. `stcode` is the one `userlogin` returned;
  /// older logins without it fall back to `state`, then the selected state.
  static Future<RailwireSession?> current() async {
    final stored = await PreferenceUtils.getRailwireUser();
    if (stored == null) return null;

    final user = RailwireUserModel.fromJson(
      jsonDecode(stored) as Map<String, dynamic>,
    );
    final state = user.state ?? '';
    return RailwireSession(
      username: user.username,
      subscriberId: user.subscriberId,
      stateCode:
          user.stCode.isNotEmpty
              ? user.stCode
              : state.isNotEmpty
              ? state
              : await PreferenceUtils.getTenantId() ?? '',
    );
  }
}

class RailwireApi {
  /// For app features RailWire has no API for.
  static Failure get unavailable => ServerFailure(appL10n.notAvailable);

  /// RailWire amounts and counters can be numbers or text.
  static double toDouble(dynamic value) =>
      double.tryParse(value?.toString() ?? '') ?? 0;

  /// POSTs [body] and returns the `data` object of the
  /// `{STATUS, data: {status, Message}}` response. A failure can be
  /// `{STATUS: false, msg}` or a false `data.status`. Some APIs have no `data`,
  /// so their payload is the response itself. [sensitive] keeps the body (e.g.
  /// a password) out of the request log.
  static Future<Either<Failure, Map<String, dynamic>>> post(
    String url,
    Map<String, dynamic> Function(RailwireSession session) body, {
    bool sensitive = false,
  }) async {
    try {
      final session = await RailwireSession.current();
      if (session == null) {
        return Left(AuthFailure(appL10n.yourSessionHasExpiredPleaseLogIn));
      }

      final json = await sl<DioClient>().postRailwire(
        url,
        data: body(session),
        sensitive: sensitive,
      );
      return _data(json);
    } catch (e) {
      return Left(APIResponse.fromError(e).failure);
    }
  }

  /// [post] for the few GET APIs that take parameters. [params] go both in the
  /// query and as a JSON body, as the API documents a body on a GET.
  static Future<Either<Failure, Map<String, dynamic>>> get(
    String url,
    Map<String, dynamic> Function(RailwireSession session) params,
  ) async {
    try {
      final session = await RailwireSession.current();
      if (session == null) {
        return Left(AuthFailure(appL10n.yourSessionHasExpiredPleaseLogIn));
      }

      final values = params(session);
      final json = await sl<DioClient>().getRailwire(
        url,
        queryParameters: values,
        data: values,
      );
      return _data(json);
    } catch (e) {
      return Left(APIResponse.fromError(e).failure);
    }
  }

  static Either<Failure, Map<String, dynamic>> _data(
    Map<String, dynamic> json,
  ) {
    if (json['STATUS'] != true) return Left(_failure(json['msg']));

    final data = json['data'];
    if (data == null) return Right(json);
    if (data is! Map<String, dynamic>) {
      return Left(ServerFailure(appL10n.invalidResponse));
    }
    if (data['status'] != true) return Left(_failure(data['Message']));
    return Right(data);
  }

  static Failure _failure(dynamic message) {
    final text = message?.toString() ?? '';
    return ServerFailure(text.isNotEmpty ? text : appL10n.somethingWentWrong);
  }
}
