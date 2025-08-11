import 'package:get_it/get_it.dart';
import 'package:kfon_subscriber/core/network/dio_client.dart';
import 'package:kfon_subscriber/data/auth/repository/auth.dart';
import 'package:kfon_subscriber/data/auth/sources/auth_api_service.dart';
import 'package:kfon_subscriber/data/auth/sources/auth_local_service.dart';
import 'package:kfon_subscriber/domain/auth/repository/auth.dart';
import 'package:kfon_subscriber/domain/auth/usecases/get_OTP.dart';
import 'package:kfon_subscriber/domain/auth/usecases/is_logged_in.dart';
import 'package:kfon_subscriber/domain/auth/usecases/login.dart';
import 'package:kfon_subscriber/domain/auth/usecases/set_new_password.dart';
import 'package:kfon_subscriber/domain/auth/usecases/verify_otp.dart';

final sl=GetIt.instance;

void setUpServiceLocator(){
  sl.registerSingleton<DioClient>(DioClient());

  sl.registerSingleton<AuthApiService>(AuthApiServiceImp());

  sl.registerSingleton<AuthLocalService>(AuthLocalServiceImp());

  sl.registerSingleton<AuthRepository>(AuthRepositoryImp());

  sl.registerSingleton<LoginUseCase>(LoginUseCase());

  sl.registerSingleton<IsLoggedInUseCase>(IsLoggedInUseCase());

  sl.registerSingleton<GetOtpUseCase>(GetOtpUseCase());

  sl.registerSingleton<VerifyOtpUseCase>(VerifyOtpUseCase());

  sl.registerSingleton<SetNewPasswordUseCase>(SetNewPasswordUseCase());
}