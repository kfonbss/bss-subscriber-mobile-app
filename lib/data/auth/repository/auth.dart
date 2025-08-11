import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/data/auth/model/forgot_password_get_OTP_params.dart';
import 'package:kfon_subscriber/data/auth/model/forgot_password_verify_OTP_params.dart';
import 'package:kfon_subscriber/data/auth/model/set_new_password_params.dart';
import 'package:kfon_subscriber/data/auth/sources/auth_api_service.dart';
import 'package:kfon_subscriber/data/auth/sources/auth_local_service.dart';
import 'package:kfon_subscriber/domain/auth/repository/auth.dart';
import 'package:kfon_subscriber/service_locator.dart';

import '../model/login_req_params.dart';

class AuthRepositoryImp extends AuthRepository {
  @override
  Future<Either> login(LoginRequestParams loginReq) async {
    return await sl<AuthApiService>().login(loginReq);
  }

  @override
  Future<bool> isLoggedIn() async {
    return await sl<AuthLocalService>().isLoggedIn();
  }

  @override
  Future<Either> forgotPasswordGetOTP(ForgotPasswordGetOtpParams sendOTPReq)async {
    return await sl<AuthApiService>().getOTP(sendOTPReq);
  }

  @override
  Future<Either> forgotPasswordVerifyOTP(ForgotPasswordVerifyOtpParams verifyOTPReq)async {
    return await sl<AuthApiService>().verifyOTP(verifyOTPReq);
  }

  @override
  Future<Either> setNewPassword(SetNewPasswordParams setNewPasswordReq)async {
    return await sl<AuthApiService>().setNewPassword(setNewPasswordReq);
  }
}
