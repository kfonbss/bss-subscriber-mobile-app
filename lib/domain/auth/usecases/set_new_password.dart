
import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/usercase/usecase.dart';
import 'package:kfon_subscriber/data/auth/model/set_new_password_params.dart';
import 'package:kfon_subscriber/data/auth/sources/auth_api_service.dart';
import 'package:kfon_subscriber/service_locator.dart';

class SetNewPasswordUseCase implements UseCase<Either,SetNewPasswordParams>{

  @override
  Future<Either> call({SetNewPasswordParams? param})async {
    return await sl<AuthApiService>().setNewPassword(param!);
  }

}