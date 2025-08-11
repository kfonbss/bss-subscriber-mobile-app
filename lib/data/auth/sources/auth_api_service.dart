import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:kfon_subscriber/core/network/dio_client.dart';
import 'package:kfon_subscriber/data/auth/model/forgot_password_get_OTP_params.dart';
import 'package:kfon_subscriber/data/auth/model/forgot_password_verify_OTP_params.dart';
import 'package:kfon_subscriber/data/auth/model/login_req_params.dart';
import 'package:kfon_subscriber/data/auth/model/set_new_password_params.dart';
import 'package:kfon_subscriber/service_locator.dart';

abstract class AuthApiService {
  Future<Either> login(LoginRequestParams loginReq);
  Future<Either> getOTP(ForgotPasswordGetOtpParams forgotPasswordSendOTPParams);
  Future<Either> verifyOTP(ForgotPasswordVerifyOtpParams forgotPasswordVerityParams);
  Future<Either> setNewPassword(SetNewPasswordParams setNewPasswordParams);
}

class AuthApiServiceImp extends AuthApiService {
  @override
  Future<Either> login(LoginRequestParams loginReq) async {
    try {
      var response = await sl<DioClient>().post(
          ApiUrls.loginURL, data: loginReq.toMap());
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response);
    }
  }

  @override
  Future<Either> getOTP(ForgotPasswordGetOtpParams forgotPasswordSendOTPParams) async{
    try {
      var response = await sl<DioClient>().post(
          ApiUrls.forgotPasswordSendOTPURL, data: forgotPasswordSendOTPParams.toMap());
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response);
    }
  }

  @override
  Future<Either> setNewPassword(SetNewPasswordParams setNewPasswordParams)async {
    try {
      var response = await sl<DioClient>().post(
          ApiUrls.setNewPasswordURL, data: setNewPasswordParams.toMap());
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response);
    }
  }

  @override
  Future<Either> verifyOTP(ForgotPasswordVerifyOtpParams forgotPasswordVerityParams)async {
    try {
      var response = await sl<DioClient>().post(
          ApiUrls.forgotPasswordVerifyOTPURL, data: forgotPasswordVerityParams.toMap());
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response);
    }
  }

}
