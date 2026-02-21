
import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/usecase/usecase.dart';
import 'package:kfon_subscriber/data/sign_up/models/sign_up_get_OTP_params.dart';
import 'package:kfon_subscriber/domain/sign_up/repository/sign_up.dart';
import 'package:kfon_subscriber/service_locator.dart';

class SignUpGetOtpUseCase implements UseCase<Either,SignUpGetOtpParams>{

  @override
  Future<Either> call({SignUpGetOtpParams? param})async {
    return await sl<SignUpRepository>().signUpGetOTP(param!);
  }

}