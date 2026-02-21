import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:kfon_subscriber/core/network/dio_client.dart';
import 'package:kfon_subscriber/data/sign_up/models/sign_up_get_OTP_params.dart';
import 'package:kfon_subscriber/data/sign_up/models/sign_up_verify_OTP_params.dart';
import 'package:kfon_subscriber/service_locator.dart';

abstract class SignUpApiService {
  Future<Either> signUpGetOTP(SignUpGetOtpParams params);

  Future<Either> signUpVerifyOTP(SignUpVerifyOtpParams params);
}

class SignUpApiServiceImp extends SignUpApiService {
   @override
  Future<Either> signUpGetOTP(SignUpGetOtpParams params) async{
     var response = await sl<DioClient>().post(
       ApiUrls.signUpGetOTPFormURL,
       data: params.toMap(),
     );
     if (response.error.isEmpty) {
       return Right(response.data);
     } else {
       return Left(response.error);
     }
  }

  @override
  Future<Either> signUpVerifyOTP(SignUpVerifyOtpParams params)async {
    var response = await sl<DioClient>().post(
      ApiUrls.signUpVerifyOTPFormURL,
      data: params.toMap(),
    );
    if (response.error.isEmpty) {
      return Right(response.data);
    } else {
      return Left(response.error);
    }
  }

}
