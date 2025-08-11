
import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/usercase/usecase.dart';
import 'package:kfon_subscriber/data/auth/model/forgot_password_get_OTP_params.dart';
import 'package:kfon_subscriber/data/auth/sources/auth_api_service.dart';
import 'package:kfon_subscriber/service_locator.dart';

class GetOtpUseCase implements UseCase<Either,ForgotPasswordGetOtpParams>{

  @override
  Future<Either> call({ForgotPasswordGetOtpParams? param})async {
    return await sl<AuthApiService>().getOTP(param!);
  }

}