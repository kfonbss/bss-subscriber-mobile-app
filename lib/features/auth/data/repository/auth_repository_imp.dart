import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/core/network/api_response.dart';
import 'package:kfon_subscriber/features/auth/domain/entity/otp_response_entity.dart';
import 'package:kfon_subscriber/features/auth/domain/entity/auth_entity.dart';
import 'package:kfon_subscriber/features/auth/domain/params/login_params.dart';
import 'package:kfon_subscriber/features/auth/domain/params/reset_password_params.dart';
import 'package:kfon_subscriber/features/auth/domain/params/verify_otp_params.dart';
import 'package:kfon_subscriber/core/util/preference_util.dart';
import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:kfon_subscriber/core/network/dio_client.dart';
import 'package:kfon_subscriber/features/auth/domain/repository/auth_repository.dart';
import 'package:kfon_subscriber/service_locator.dart';

import '../model/auth_model.dart';

class AuthRepositoryImp extends AuthRepository {
  @override
  Future<Either<Failure, AuthEntity>> login(LoginParams loginReq) async {
    APIResponse response = await sl<DioClient>().post(
      ApiUrls.loginURL,
      data: loginReq.toMap(),
    );
    if (response.isSuccess) {
      final authModel = AuthModel.fromJson(response.data);
      return Right(authModel.toEntity());
    } else {
      return Left(response.failure);
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    // final token = await PreferenceUtils.getAccessToken();
    // if (token == null || token.isEmpty) {
    //   APIResponse response = await sl<DioClient>().get(ApiUrls.lnpHomeURL);
    //   if (response.isSuccess) {
    //     return true;
    //   } else {
    //     await PreferenceUtils.clearAll();
    //     return false;
    //   }
    // } else {
    //   return true;
    // }
    var token = await PreferenceUtils.getAccessToken();
    if (token!.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  @override
  Future<Either<Failure, OtpResponseEntity>> sendOtp(
    String mobileNumber,
  ) async {
    APIResponse response = await sl<DioClient>().post(
      ApiUrls.sendOTPURL,
      data: {'mobile': mobileNumber},
    );
    if (response.isSuccess) {
      final data = response.data as Map<String, dynamic>;
      return Right(
        OtpResponseEntity(
          otpRefId: data['otpRefId'] as String,
          mobileNumber: mobileNumber,
        ),
      );
    } else {
      return Left(response.failure);
    }
  }

  @override
  Future<Either<Failure, OtpResponseEntity>> sendForgotPasswordOtp(
    String username,
  ) async {
    APIResponse response = await sl<DioClient>().post(
      ApiUrls.sendForgotPasswordOTPURL,
      data: {'username': username},
    );
    if (response.isSuccess) {
      final data = response.data as Map<String, dynamic>;
      return Right(
        OtpResponseEntity(
          otpRefId: data['otpRefId'] as String,
          mobileNumber: data['mobile'] as String?,
        ),
      );
    } else {
      return Left(response.failure);
    }
  }

  @override
  Future<Either<Failure, void>> verifyOtp(VerifyOtpParams params) async {
    APIResponse response = await sl<DioClient>().post(
      ApiUrls.verifyOTPURL,
      data: params.toMap(),
    );
    if (response.isSuccess) {
      return const Right(null);
    } else {
      return Left(response.failure);
    }
  }

  @override
  Future<Either<Failure, dynamic>> verifyForgotPasswordOtp(
    VerifyOtpParams params,
  ) async {
    APIResponse response = await sl<DioClient>().post(
      ApiUrls.verifyForgotPasswordOTPURL,
      data: params.toMap(),
    );
    if (response.isSuccess) {
      return Right(response.data);
    } else {
      return Left(response.failure);
    }
  }

  @override
  Future<Either<Failure, void>> resetForgotPassword(
    ResetPasswordParams params,
  ) async {
    APIResponse response = await sl<DioClient>().post(
      ApiUrls.resetForgotPasswordURL,
      data: params.toMap(),
    );
    if (response.isSuccess) {
      return const Right(null);
    } else {
      return Left(response.failure);
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> refreshToken(String refreshToken) async {
    print('authTest refreshApiTestTimies');
    APIResponse response = await sl<DioClient>().post(
      ApiUrls.refreshTokenURL,
      data: {'refreshToken': refreshToken},
    );
    if (response.isSuccess) {
      final authModel = AuthModel.fromJson(response.data);
      return Right(authModel.toEntity());
    } else {
      return Left(response.failure);
    }
  }

  @override
  Future<Either<Failure, void>> logout(String refreshToken) async {
    APIResponse response = await sl<DioClient>().post(
      ApiUrls.logoutURL,
      data: {'refreshToken': refreshToken},
    );
    if (response.isSuccess) {
      return const Right(null);
    } else {
      return Left(response.failure);
    }
  }

  @override
  Future<Either<Failure, dynamic>> getUserProfile() async {
    APIResponse response = await sl<DioClient>().get(ApiUrls.profileURL);
    if (response.isSuccess) {
      return Right(response.data);
    } else {
      return Left(response.failure);
    }
  }
}
