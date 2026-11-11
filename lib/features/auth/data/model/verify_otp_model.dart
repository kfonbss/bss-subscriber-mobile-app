import 'package:kfon_subscriber/features/auth/domain/entity/verify_otp_entity.dart';

enum UserRole { sub, other }

/// Role names the backend may send for a subscriber. RailWire/BSS sends
/// `SUB`; the KFON tenant sends `subscriber`.
const _subscriberRoleAliases = {'sub', 'subscriber'};

/// Resolves the first role in [roleNames] this app allows, case-insensitive
/// (`-` treated as `_`). Returns `null` when none is allowed.
UserRole? resolveAllowedUserRole(List<dynamic> roleNames) {
  for (final raw in roleNames) {
    final normalized = raw.toString().trim().toLowerCase().replaceAll('-', '_');
    if (_subscriberRoleAliases.contains(normalized)) return UserRole.sub;
    for (final role in UserRole.values) {
      if (role.name == normalized) return role;
    }
  }
  return null;
}

class VerifyOtpModel {
  final String userId;
  final String username;
  final String token;
  final bool isActive;
  final bool isFirstLogin;
  final String? lastUpdate;
  final String tokenType;
  final String mobileNumber;
  final String refreshToken;
  final List<dynamic> roleNames;
  final int expiresIn;
  final String? lnpSubUserType;

  const VerifyOtpModel({
    required this.userId,
    required this.username,
    required this.token,
    required this.isActive,
    required this.isFirstLogin,
    this.lastUpdate,
    required this.tokenType,
    required this.mobileNumber,
    required this.refreshToken,
    required this.roleNames,
    required this.expiresIn,
    this.lnpSubUserType,
  });

  factory VerifyOtpModel.fromJson(Map<String, dynamic> json) => VerifyOtpModel(
    userId: json['userId'] as String? ?? '',
    username: json['username'] as String? ?? '',
    token: json['token'] as String? ?? '',
    refreshToken: json['refreshToken'] as String? ?? '',
    isActive: json['isActive'] as bool? ?? false,
    isFirstLogin: json['isFirstLogin'] as bool? ?? true,
    lastUpdate: json['lastUpdate'] as String?,
    expiresIn: json['expiresIn'] as int? ?? 0,
    tokenType: json['tokenType'] as String? ?? '',
    mobileNumber: json['mobileNumber'] as String? ?? '',
    roleNames:
        (json['roleNames'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [],
    lnpSubUserType: json['lnpSubUserType'] as String? ?? '',
  );

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'token': token,
      'isActive': isActive,
      'lastUpdate': lastUpdate,
      'tokenType': tokenType,
      'mobileNumber': mobileNumber,
      'refreshToken': refreshToken,
      'expiresIn': expiresIn,
      'roleNames': roleNames,
      'lnpSubUserType': lnpSubUserType,
    };
  }

  VerifyOtpEntity toEntity() {
    return VerifyOtpEntity(
      userId: userId,
      username: username,
      token: token,
      isActive: isActive,
      isFirstLogin: isFirstLogin,
      lastUpdate: lastUpdate,
      tokenType: tokenType,
      mobileNumber: mobileNumber,
      refreshToken: refreshToken,
      expiresIn: expiresIn,
      userRole: resolveAllowedUserRole(roleNames),
      lnpSubUserType: lnpSubUserType,
    );
  }
}
