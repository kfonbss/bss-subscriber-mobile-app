import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/features/auth/domain/entity/railwire_user_entity.dart';

abstract class RailwireAuthRepository {
  /// TEMPORARY: the OTP test number is unavailable, so [login] saves the user
  /// itself and the OTP step is skipped. Set to true to restore the OTP step.
  static const loginOtpEnabled = false;

  /// Checks the password. With [loginOtpEnabled], the user is only saved once
  /// [verifyLoginOtp] succeeds; otherwise [login] saves it.
  Future<Either<Failure, RailwireUserEntity>> login({
    required String username,
    required String password,
  });

  /// Sends the login OTP and returns the mobile number it went to.
  Future<Either<Failure, String>> sendLoginOtp();

  /// Verifies [otp] and saves the user from the last successful [login].
  Future<Either<Failure, Unit>> verifyLoginOtp(String otp);
}
