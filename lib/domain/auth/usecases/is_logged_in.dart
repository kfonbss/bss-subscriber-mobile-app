
import 'package:kfon_subscriber/core/usercase/usecase.dart';
import 'package:kfon_subscriber/data/auth/sources/auth_local_service.dart';
import 'package:kfon_subscriber/service_locator.dart';

class IsLoggedInUseCase implements UseCase<bool,dynamic>{

  @override
  Future<bool> call({dynamic param})async {
    return await sl<AuthLocalService>().isLoggedIn();
  }

}