
import '../../../core/util/preference_util.dart';

abstract class AuthLocalService {
  Future<bool> isLoggedIn();
}

class AuthLocalServiceImp extends AuthLocalService {
  @override
  Future<bool> isLoggedIn() async {
    var token = await PreferenceUtils.getLoginToken();
    if (token.isEmpty) {
      return false;
    } else {
      return true;
    }
  }
}
