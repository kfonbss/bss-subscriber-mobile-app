import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/data/auth/model/forgot_password_get_OTP_params.dart';
import 'package:kfon_subscriber/data/auth/model/forgot_password_verify_OTP_params.dart';
import 'package:kfon_subscriber/data/auth/model/login_req_params.dart';
import 'package:kfon_subscriber/data/auth/model/set_new_password_params.dart';

abstract class AuthRepository {
  Future<Either> login(LoginRequestParams loginReq);

  Future<bool> isLoggedIn();

  Future<Either> forgotPasswordGetOTP(ForgotPasswordGetOtpParams sendOTPReq);

  Future<Either> forgotPasswordVerifyOTP(
    ForgotPasswordVerifyOtpParams verifyOTPReq,
  );

  Future<Either> setNewPassword(SetNewPasswordParams setNewPasswordReq);
}
