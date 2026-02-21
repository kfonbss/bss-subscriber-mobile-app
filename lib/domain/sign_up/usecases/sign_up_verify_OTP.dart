
import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/usecase/usecase.dart';
import 'package:kfon_subscriber/data/sign_up/models/sign_up_verify_OTP_params.dart';
import 'package:kfon_subscriber/domain/sign_up/repository/sign_up.dart';
import 'package:kfon_subscriber/service_locator.dart';

class SignUpVerifyOtpUseCase implements UseCase<Either,SignUpVerifyOtpParams>{

  @override
  Future<Either> call({SignUpVerifyOtpParams? param})async {
    return await sl<SignUpRepository>().signUpVerifyOTP(param!);
  }

}