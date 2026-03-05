import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/features/auth/domain/entity/otp_response_entity.dart';
import 'package:kfon_subscriber/features/auth/domain/entity/auth_entity.dart';
import 'package:kfon_subscriber/features/auth/domain/params/login_params.dart';
import 'package:kfon_subscriber/features/auth/domain/params/reset_password_params.dart';
import 'package:kfon_subscriber/features/auth/domain/params/verify_otp_params.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthEntity>> login(LoginParams loginReq);

  Future<bool> isLoggedIn();

  Future<Either<Failure, OtpResponseEntity>> sendOtp(String mobileNumber);

  Future<Either<Failure, OtpResponseEntity>> sendForgotPasswordOtp(
    String username,
  );

  Future<Either<Failure, void>> verifyOtp(VerifyOtpParams params);
  Future<Either<Failure, dynamic>> verifyForgotPasswordOtp(
    VerifyOtpParams params,
  );

  Future<Either<Failure, void>> resetForgotPassword(ResetPasswordParams params);

  Future<Either<Failure, AuthEntity>> refreshToken(String refreshToken);

  Future<Either<Failure, void>> logout(String refreshToken);

  Future<Either<Failure, dynamic>> getUserProfile();
}
