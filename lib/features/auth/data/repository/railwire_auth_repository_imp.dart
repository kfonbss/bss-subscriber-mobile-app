import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/core/network/api_response.dart';
import 'package:kfon_subscriber/core/network/dio_client.dart';
import 'package:kfon_subscriber/core/util/preference_util.dart';
import 'package:kfon_subscriber/features/auth/data/model/login_req_params.dart';
import 'package:kfon_subscriber/features/auth/data/model/railwire_user_model.dart';
import 'package:kfon_subscriber/features/auth/domain/entity/railwire_user_entity.dart';
import 'package:kfon_subscriber/features/auth/domain/repository/railwire_auth_repository.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/service_locator.dart';

class RailwireAuthRepositoryImp extends RailwireAuthRepository {
  /// TEMPORARY (OTP testing): every login OTP goes to this number instead of
  /// the subscriber's. Replace with the subscriber's mobile number to remove.
  static const otpTestMobileNumber = '8281412765';

  /// The `userlogin` data, saved once the OTP is verified.
  Map<String, dynamic>? _pendingUser;

  /// `verifyotplogin` needs the state `sendotplogin` reported for the number.
  String _otpStateCode = '';

  @override
  Future<Either<Failure, RailwireUserEntity>> login({
    required String username,
    required String password,
  }) async {
    _pendingUser = null;
    try {
      final json = await sl<DioClient>().postRailwire(
        ApiUrls.railwireUserLoginURL,
        data: LoginRequestParams(
          userName: username,
          password: password,
        ).toMap(),
        sensitive: true,
      );

      return _data(json).fold(Left.new, (data) async {
        final user = RailwireUserModel.fromJson(data).toEntity();
        if (!await _isSelectedState(user)) {
          return Left(ValidationFailure(appL10n.accountBelongsToAnotherCircle));
        }

        if (RailwireAuthRepository.loginOtpEnabled) {
          _pendingUser = data;
        } else {
          await PreferenceUtils.setRailwireUser(jsonEncode(data));
        }
        return Right(user);
      });
    } catch (e) {
      return Left(APIResponse.fromError(e).failure);
    }
  }

  @override
  Future<Either<Failure, String>> sendLoginOtp() async {
    if (_pendingUser == null) return Left(_sessionExpired);
    try {
      final json = await sl<DioClient>().postRailwire(
        ApiUrls.railwireSendLoginOtpURL,
        data: {'mblno': otpTestMobileNumber},
      );
      return _data(json).fold(Left.new, (data) async {
        final stateCode = data['state_code']?.toString() ?? '';
        _otpStateCode =
            stateCode.isNotEmpty
                ? stateCode
                : await PreferenceUtils.getTenantId() ?? '';
        return const Right(otpTestMobileNumber);
      });
    } catch (e) {
      return Left(APIResponse.fromError(e).failure);
    }
  }

  @override
  Future<Either<Failure, Unit>> verifyLoginOtp(String otp) async {
    final user = _pendingUser;
    if (user == null) return Left(_sessionExpired);
    try {
      final json = await sl<DioClient>().postRailwire(
        ApiUrls.railwireVerifyLoginOtpURL,
        data: {
          'eamil_or_mblno': otpTestMobileNumber,
          'stcode': _otpStateCode,
          'otp_number': otp,
        },
        sensitive: true,
      );
      return _data(json).fold(Left.new, (_) async {
        // The response describes the test number's account, so the user who
        // entered the password is the one saved.
        await PreferenceUtils.setRailwireUser(jsonEncode(user));
        _pendingUser = null;
        return const Right(unit);
      });
    } catch (e) {
      return Left(APIResponse.fromError(e).failure);
    }
  }

  Failure get _sessionExpired =>
      AuthFailure(appL10n.yourSessionHasExpiredPleaseLogIn);

  /// The `data` of a `{STATUS, data: {status, Message}}` response.
  Either<Failure, Map<String, dynamic>> _data(Map<String, dynamic> json) {
    final data = json['data'];
    if (json['STATUS'] != true) return Left(_failure(json['msg']));
    if (data is! Map<String, dynamic>) {
      return Left(ServerFailure(appL10n.invalidResponse));
    }
    if (data['status'] != true) return Left(_failure(data['Message']));
    return Right(data);
  }

  Failure _failure(dynamic message) {
    final text = message?.toString() ?? '';
    return ServerFailure(text.isNotEmpty ? text : appL10n.somethingWentWrong);
  }

  /// `userlogin` takes no state, so any account logs in from any state. Its
  /// `stcode` is the host of the state's `app_url`.
  Future<bool> _isSelectedState(RailwireUserEntity user) async {
    final appUrl = await PreferenceUtils.getTenantAppUrl() ?? '';
    final selected = Uri.tryParse(appUrl)?.host ?? '';
    if (selected.isEmpty) return true;
    return selected.toLowerCase() == user.stCode.toLowerCase();
  }
}
