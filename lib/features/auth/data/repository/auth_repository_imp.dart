import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/core/network/api_response.dart';
import 'package:kfon_subscriber/features/auth/data/model/verify_otp_model.dart';
import 'package:kfon_subscriber/features/auth/domain/entity/otp_response_entity.dart';
import 'package:kfon_subscriber/features/auth/domain/entity/auth_entity.dart';
import 'package:kfon_subscriber/features/auth/domain/entity/verify_otp_entity.dart';
import 'package:kfon_subscriber/features/auth/domain/params/login_params.dart';
import 'package:kfon_subscriber/features/auth/domain/params/reset_password_params.dart';
import 'package:kfon_subscriber/features/auth/domain/params/verify_otp_params.dart';
import 'package:kfon_subscriber/features/profile/data/model/profile_model.dart';
import 'package:kfon_subscriber/features/profile/domain/entity/profile_entity.dart';
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
  Future<Either<Failure, AuthEntity>> resendOTP(String token) async {
    APIResponse response = await sl<DioClient>().post(
      ApiUrls.resendOTPURL,
      data: {'loginSessionToken': token},
    );
    if (response.isSuccess) {
      final authModel = AuthModel.fromJson(response.data);
      return Right(authModel.toEntity());
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
  Future<Either<Failure, VerifyOtpEntity>> verifyOtp(
    VerifyOtpParams params,
  ) async {
    APIResponse response = await sl<DioClient>().post(
      ApiUrls.verifyOTPURL,
      data: params.toMap(),
    );
    if (response.isSuccess) {
      final otpVerifiedData = VerifyOtpModel.fromJson(response.data);
      return Right(otpVerifiedData.toEntity());
    } else {
      return Left(response.failure);
    }
  }

  @override
  Future<Either<Failure, OtpResponseEntity>> verifyForgotPasswordOtp(
    VerifyOtpParams params,
  ) async {
    APIResponse response = await sl<DioClient>().post(
      ApiUrls.verifyForgotPasswordOTPURL,
      data: params.toMap(),
    );
    if (response.isSuccess) {
      final data = response.data as Map<String, dynamic>;
      return Right(
        OtpResponseEntity(
          otpRefId: data['token'] as String,
          userRole: _resolveAllowedRole(
            (data['roleNames'] as List<dynamic>?)
                    ?.map((e) => e.toString())
                    .toList() ??
                [],
          ),
        ),
      );
    } else {
      return Left(response.failure);
    }
  }
  static UserRole? _resolveAllowedRole(List<dynamic> roleNames) {
    for (final raw in roleNames) {
      final normalized = raw.toString().trim().toLowerCase().replaceAll(
        '-',
        '_',
      );
      for (final role in UserRole.values) {
        if (role.name.toLowerCase() == normalized) {
          return role;
        }
      }
    }
    return null;
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
  Future<Either<Failure, VerifyOtpEntity>> refreshToken(
    String refreshToken,
  ) async {
    print('authTest refreshApiTestTimies');
    APIResponse response = await sl<DioClient>().post(
      ApiUrls.refreshTokenURL,
      data: {'refreshToken': refreshToken},
    );
    if (response.isSuccess) {
      final authModel = VerifyOtpModel.fromJson(response.data);
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
  Future<Either<Failure, ProfileEntity>> getUserProfile() async {
    APIResponse response = await sl<DioClient>().get(ApiUrls.profileURL);
    if (response.isSuccess) {
      final profileModel = ProfileModel.fromJson(response.data);
      return Right(profileModel.toEntity());
    } else {
      return Left(response.failure);
    }
  }
}
