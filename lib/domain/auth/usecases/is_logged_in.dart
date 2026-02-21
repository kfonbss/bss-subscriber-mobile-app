
import 'package:kfon_subscriber/core/usecase/usecase.dart';
import 'package:kfon_subscriber/domain/auth/repository/auth.dart';
import 'package:kfon_subscriber/service_locator.dart';

class IsLoggedInUseCase implements UseCase<bool,dynamic>{

  @override
  Future<bool> call({dynamic param})async {
    return await sl<AuthRepository>().isLoggedIn();
  }

}