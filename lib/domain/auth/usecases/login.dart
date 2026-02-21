import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/usecase/usecase.dart';
import 'package:kfon_subscriber/data/auth/model/login_req_params.dart';
import 'package:kfon_subscriber/domain/auth/repository/auth.dart';
import 'package:kfon_subscriber/service_locator.dart';

class LoginUseCase implements UseCase<Either,LoginRequestParams>{

  @override
  Future<Either> call({LoginRequestParams? param})async {
   return await sl<AuthRepository>().login(param!);
  }

}