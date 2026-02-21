import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/data/sign_up/models/sign_up_get_OTP_params.dart';
import 'package:kfon_subscriber/data/sign_up/models/sign_up_verify_OTP_params.dart';

abstract class SignUpRepository {
  Future<Either> signUpGetOTP(SignUpGetOtpParams params);

  Future<Either> signUpVerifyOTP(SignUpVerifyOtpParams params);
}
