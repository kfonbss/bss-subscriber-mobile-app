import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:kfon_subscriber/core/network/dio_client.dart';
import 'package:kfon_subscriber/data/auth/model/forgot_password_get_OTP_params.dart';
import 'package:kfon_subscriber/data/auth/model/forgot_password_verify_OTP_params.dart';
import 'package:kfon_subscriber/data/auth/model/login_req_params.dart';
import 'package:kfon_subscriber/data/auth/model/set_new_password_params.dart';
import 'package:kfon_subscriber/service_locator.dart';

abstract class AuthApiService {
  Future<Either> login(LoginRequestParams loginReq);

  Future<Either> forgotPasswordGetOTP(ForgotPasswordGetOtpParams forgotPasswordSendOTPParams);

  Future<Either> verifyOTP(
    ForgotPasswordVerifyOtpParams forgotPasswordVerityParams,
  );

  Future<Either> setNewPassword(SetNewPasswordParams setNewPasswordParams);
}

class AuthApiServiceImp extends AuthApiService {
  @override
  Future<Either> login(LoginRequestParams loginReq) async {
    var response = await sl<DioClient>().post(
      ApiUrls.loginURL,
      data: loginReq.toMap(),
    );
    if (response.error.isEmpty) {
      return Right(response.data);
    } else {
      return Left(response.message);
    }
  }

  @override
  Future<Either> forgotPasswordGetOTP(
    ForgotPasswordGetOtpParams forgotPasswordSendOTPParams,
  ) async {
    var response = await sl<DioClient>().post(
      ApiUrls.forgotPasswordSendOTPURL,
      data: forgotPasswordSendOTPParams.toMap(),
    );
    if (response.error.isEmpty) {
      return Right(response.data);
    } else {
      return Left(response.message);
    }
  }

  @override
  Future<Either> setNewPassword(
    SetNewPasswordParams setNewPasswordParams,
  ) async {
    var response = await sl<DioClient>().post(
      ApiUrls.setNewPasswordURL,
      data: setNewPasswordParams.toMap(),
    );
    if (response.error.isEmpty) {
      return Right(response.data);
    } else {
      return Left(response.message);
    }
  }

  @override
  Future<Either> verifyOTP(
    ForgotPasswordVerifyOtpParams forgotPasswordVerityParams,
  ) async {
    var response = await sl<DioClient>().post(
      ApiUrls.forgotPasswordVerifyOTPURL,
      data: forgotPasswordVerityParams.toMap(),
    );
    if (response.error.isEmpty) {
      return Right(response.data);
    } else {
      return Left(response.message);
    }
  }
}
