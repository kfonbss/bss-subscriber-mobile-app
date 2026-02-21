import 'package:shared_preferences/shared_preferences.dart';

class PreferenceUtils {

  static void setLoginToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', token);
  }

  static Future<String> getLoginToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken') ?? '';
  }

  static Future<dynamic> getAccessToken() async {}

  static Future<dynamic> getRefreshToken() async {}

  static Future<void> clearAll() async {}
}
