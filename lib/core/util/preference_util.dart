import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PreferenceUtils {
  static const _storage = FlutterSecureStorage();

  static const _keyAccessToken = 'accessToken';
  static const _keyRefreshToken = 'refreshToken';
  static const _keyTokenExpiryAt = 'tokenExpiryAt';
  static const _keyUserId = 'userId';
  static const _keyUserName = 'userName';
  static const _introScreenStatus = 'introScreenStatus';

  static Future<String?> getAccessToken() async =>
      await _storage.read(key: _keyAccessToken);

  static Future<String?> getRefreshToken() async =>
      await _storage.read(key: _keyRefreshToken);

  static Future<bool> showIntroScreen() async {
    final value = await _storage.read(key: _introScreenStatus);
    if (value == null) return true;
    return false;
  }

  static Future<void> setIntroScreenStatus(bool status) async =>
      await _storage.write(key: _introScreenStatus, value: status.toString());


  /// Returns the expiry timestamp in milliseconds since epoch
  static Future<int?> getTokenExpiryAt() async {
    final expiryStr = await _storage.read(key: _keyTokenExpiryAt);
    return expiryStr != null ? int.tryParse(expiryStr) : null;
  }

  /// Check if token is expired or about to expire (within buffer seconds)
  static Future<bool> isTokenExpired({int bufferSeconds = 300}) async {
    final expiryAt = await getTokenExpiryAt();
    if (expiryAt == null) return true;

    final now = DateTime.now().millisecondsSinceEpoch;
    final bufferMs = bufferSeconds * 1000;

    // Token is expired if current time + buffer is past expiry time
    return now + bufferMs >= expiryAt;
  }

  /// Save all tokens. expiresIn is in seconds from now.
  static Future<void> saveAllTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
  }) async {
    // Calculate the actual expiry timestamp
    final expiryAt = DateTime.now().millisecondsSinceEpoch + (expiresIn * 1000);

    await Future.wait([
      _storage.write(key: _keyAccessToken, value: accessToken),
      _storage.write(key: _keyRefreshToken, value: refreshToken),
      _storage.write(key: _keyTokenExpiryAt, value: expiryAt.toString()),
    ]);
  }

  static Future<void> setUserDetails({required String userId,required String userName}) async {
    await Future.wait([
      _storage.write(key: _keyUserId, value: userId),
      _storage.write(key: _keyUserName, value: userName)
    ]);
  }

  static Future<String?> getUserId() async =>
      await _storage.read(key: _keyUserId);
  static Future<String?> getUserName() async =>
      await _storage.read(key: _keyUserName);

  static Future<void> clearAll() async{
    await Future.wait([
      _storage.delete(key: _keyAccessToken),
      _storage.delete(key: _keyRefreshToken),
      _storage.delete(key: _keyTokenExpiryAt),
      _storage.delete(key: _keyUserId),
      _storage.delete(key: _keyUserName),
    ]);
 // await _storage.deleteAll();

}
}
