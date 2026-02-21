import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/data/sign_up/models/sign_up_get_OTP_params.dart';
import 'package:kfon_subscriber/data/sign_up/models/sign_up_verify_OTP_params.dart';
import 'package:kfon_subscriber/data/sign_up/source/sign_up_api_service.dart';
import 'package:kfon_subscriber/domain/sign_up/repository/sign_up.dart';
import 'package:kfon_subscriber/service_locator.dart';

class SignUpRepositoryImp extends SignUpRepository {

  @override
  Future<Either> signUpGetOTP(SignUpGetOtpParams params)async {
    return await sl<SignUpApiService>().signUpGetOTP(params);
  }

  @override
  Future<Either> signUpVerifyOTP(SignUpVerifyOtpParams params)async {
    return await sl<SignUpApiService>().signUpVerifyOTP(params);
  }
}
