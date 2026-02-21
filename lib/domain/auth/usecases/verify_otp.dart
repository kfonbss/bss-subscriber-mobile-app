import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/usecase/usecase.dart';
import 'package:kfon_subscriber/data/auth/model/forgot_password_verify_OTP_params.dart';
import 'package:kfon_subscriber/domain/auth/repository/auth.dart';
import 'package:kfon_subscriber/service_locator.dart';

class VerifyOtpUseCase
    implements UseCase<Either, ForgotPasswordVerifyOtpParams> {
  @override
  Future<Either> call({ForgotPasswordVerifyOtpParams? param}) async {
    return await sl<AuthRepository>().forgotPasswordVerifyOTP(param!);
  }
}
