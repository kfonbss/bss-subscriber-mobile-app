import 'package:kfon_subscriber/core/constant/app_brand.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PreferenceUtils {
  static const _storage = FlutterSecureStorage();

  static const _keyAccessToken = 'accessToken';
  static const _keyRefreshToken = 'refreshToken';
  static const _keyTokenExpiryAt = 'tokenExpiryAt';
  static const _keyUserId = 'userId';
  static const _keyMobileNumber = 'mobileNumber';
  static const _keyTenantId = 'tenantId';
  static const _keyTenantName = 'tenantName';
  static const _introScreenStatus = 'introScreenStatus';
  static const _keyLanguageCode = 'languageCode';
  static const _keyUsername = 'userName';
  static const _keyPassword = 'password';
  static const _keyRatingTracking = 'ratingTracking';
  static const _keyRailwireToken = 'railwireToken';
  static const _keyRailwireTokenExpiryAt = 'railwireTokenExpiryAt';
  static const _keyRailwireUser = 'railwireUser';
  static const _keyTenantAppUrl = 'tenantAppUrl';

  static Future<void> saveLoginCredentials(
    String userName,
    String password,
  ) async {
    await Future.wait([
      _storage.write(key: _keyUsername, value: userName),
      _storage.write(key: _keyPassword, value: password),
    ]);
  }

  static Future<void> clearLoginCredentials() async {
    await Future.wait([
      _storage.delete(key: _keyUsername),
      _storage.delete(key: _keyPassword),
    ]);
  }

  static Future<String?> getUsername() async =>
      await _storage.read(key: _keyUsername);

  static Future<String?> getPassword() async =>
      await _storage.read(key: _keyPassword);

  /// App language chosen on the language page ('en' / 'hi'); null = device language.
  static Future<String?> getLanguageCode() async =>
      await _storage.read(key: _keyLanguageCode);

  static Future<void> setLanguageCode(String code) async =>
      await _storage.write(key: _keyLanguageCode, value: code);

  static Future<String?> getAccessToken() async =>
      await _storage.read(key: _keyAccessToken);

  static Future<String?> getRefreshToken() async =>
      await _storage.read(key: _keyRefreshToken);

  static Future<bool> showIntroScreen() async {
    final value = await _storage.read(key: _introScreenStatus);
    if (value == null) return true;
    return false;
  }

  static Future<void> setTenant(
    String tenantId,
    String tenantName, {
    String? appUrl,
  }) async {
    await Future.wait([
      _storage.write(key: _keyTenantId, value: tenantId),
      _storage.write(key: _keyTenantName, value: tenantName),
      if (appUrl != null) _storage.write(key: _keyTenantAppUrl, value: appUrl),
    ]);
  }

  /// KFON builds (`BRAND=kfon`) have a single fixed tenant, so the circle
  /// picker is skipped and every caller (login, X-Tenant-ID header, PDF
  /// downloads, startup routing) gets [AppBrand.kfonTenantId]. RailWire
  /// builds read the circle the user picked, as before.
  static Future<String?> getTenantId() async =>
      AppBrand.isKfon
          ? AppBrand.kfonTenantId
          : await _storage.read(key: _keyTenantId);

  static Future<String?> getTenantName() async =>
      AppBrand.isKfon
          ? AppBrand.kfonTenantId
          : await _storage.read(key: _keyTenantName);

  static Future<String?> getTenantAppUrl() async =>
      await _storage.read(key: _keyTenantAppUrl);

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

  /// RailWire service token. Kept apart from the user's tokens, so [clearAll]
  /// leaves it in place. [expiryAt] is in milliseconds since epoch.
  static Future<void> saveRailwireToken({
    required String token,
    required int expiryAt,
  }) async {
    await Future.wait([
      _storage.write(key: _keyRailwireToken, value: token),
      _storage.write(
        key: _keyRailwireTokenExpiryAt,
        value: expiryAt.toString(),
      ),
    ]);
  }

  static Future<String?> getRailwireToken() async =>
      await _storage.read(key: _keyRailwireToken);

  /// Logged-in RailWire subscriber (JSON). RailWire has no user token, so this
  /// is what marks the user as logged in. Removed by [clearAll].
  static Future<void> setRailwireUser(String json) async =>
      await _storage.write(key: _keyRailwireUser, value: json);

  static Future<String?> getRailwireUser() async =>
      await _storage.read(key: _keyRailwireUser);

  /// Check if the RailWire token is expired or within buffer seconds of it
  static Future<bool> isRailwireTokenExpired({int bufferSeconds = 300}) async {
    final expiryStr = await _storage.read(key: _keyRailwireTokenExpiryAt);
    final expiryAt = expiryStr != null ? int.tryParse(expiryStr) : null;
    if (expiryAt == null) return true;

    final now = DateTime.now().millisecondsSinceEpoch;
    return now + bufferSeconds * 1000 >= expiryAt;
  }

  static Future<void> setUserDetails({
    required String userId,
    required String userName,
  }) async {
    await Future.wait([
      _storage.write(key: _keyUserId, value: userId),
      _storage.write(key: _keyUsername, value: userName),
    ]);
  }

  static Future<String?> getUserId() async =>
      await _storage.read(key: _keyUserId);

  static Future<String?> getUserName() async =>
      await _storage.read(key: _keyUsername);

  /// Logged-in subscriber's mobile number (saved at OTP verification).
  static Future<void> setMobileNumber(String mobileNumber) async =>
      await _storage.write(key: _keyMobileNumber, value: mobileNumber);
  static Future<String?> getMobileNumber() async =>
      await _storage.read(key: _keyMobileNumber);

  /// Usage tracking for the automatic feedback prompt (JSON). Deliberately not
  /// removed by [clearAll], so logging out does not reset eligibility.
  static Future<String?> getRatingTracking() async =>
      await _storage.read(key: _keyRatingTracking);

  static Future<void> setRatingTracking(String json) async =>
      await _storage.write(key: _keyRatingTracking, value: json);

  static Future<void> clearAll(bool clearLogin) async {
    await Future.wait([
      _storage.delete(key: _keyAccessToken),
      _storage.delete(key: _keyRefreshToken),
      _storage.delete(key: _keyTokenExpiryAt),
      _storage.delete(key: _keyUserId),
      _storage.delete(key: _keyMobileNumber),
      _storage.delete(key: _keyRailwireUser),
      if (clearLogin) ...[
        _storage.delete(key: _keyUsername),
        _storage.delete(key: _keyPassword),
      ],
    ]);
  }
}
