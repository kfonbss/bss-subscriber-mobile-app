import 'package:kfon_subscriber/features/auth/domain/entity/verify_otp_entity.dart';

enum UserRole { sub, other }

class VerifyOtpModel {
  final String userId;
  final String username;
  final String token;
  final bool isActive;
  final String? lastUpdate;
  final String tokenType;
  final String mobileNumber;
  final String refreshToken;
  final List<dynamic> roleNames;
  final int expiresIn;


  const VerifyOtpModel({
    required this.userId,
    required this.username,
    required this.token,
    required this.isActive,
    this.lastUpdate,
    required this.tokenType,
    required this.mobileNumber,
    required this.refreshToken,
    required this.roleNames,
    required this.expiresIn,

  });

  factory VerifyOtpModel.fromJson(Map<String, dynamic> json) => VerifyOtpModel(
    userId: json['userId'] as String,
    username: json['username'] as String,
    token: json['token'] as String,
    refreshToken: json['refreshToken'] as String,
    isActive: json['isActive'] as bool,
    lastUpdate: json['lastUpdate'] as String?,
    expiresIn: json['expiresIn'] as int,
    tokenType: json['tokenType'] as String,
    mobileNumber: json['mobileNumber'] as String,
    roleNames: json['roleNames'] as List<dynamic>,
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
    };
  }

  VerifyOtpEntity toEntity() {
    return VerifyOtpEntity(
      userId: userId,
      username: username,
      token: token,
      isActive: isActive,
      lastUpdate: lastUpdate,
      tokenType: tokenType,
      mobileNumber: mobileNumber,
      refreshToken: refreshToken,
      expiresIn: expiresIn,
      userRole: _resolveAllowedRole(roleNames),
    );
  }


  /// Resolves the first role from [roleNames] that maps to an allowed
  /// [UserRole] (LNP / AGNP), comparing case-insensitively. Returns `null`
  /// when the user has no permitted role for this app.
  static UserRole? _resolveAllowedRole(List<dynamic> roleNames) {
    for (final raw in roleNames) {
      final normalized = raw.toString().trim().toLowerCase();
      for (final role in UserRole.values) {
        if (role.name.toLowerCase() == normalized) {
          return role;
        }
      }
    }
    return null;
  }
}
