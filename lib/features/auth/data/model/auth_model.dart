import 'package:kfon_subscriber/features/auth/domain/entity/auth_entity.dart';

class AuthModel {
  final String userId;
  final String username;
  final String token;
  final bool isActive;
  final String? lastUpdate;
  final String tokenType;
  final String mobileNumber;
  final String refreshToken;
  final String? roleName;
  final int expiresIn;

  AuthModel({
    required this.userId,
    required this.username,
    required this.token,
    required this.isActive,
    this.lastUpdate,
    required this.tokenType,
    required this.mobileNumber,
    required this.refreshToken,
    this.roleName,
    required this.expiresIn,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      userId: json['userId'] as String,
      username: json['username'] as String,
      token: json['token'] as String,
      isActive: json['isActive'] as bool,
      lastUpdate: json['lastUpdate'] as String?,
      tokenType: json['tokenType'] as String,
      mobileNumber: json['mobileNumber'] as String,
      refreshToken: json['refreshToken'] as String? ?? '',
      expiresIn: json['expiresIn'] as int? ?? 3600,
      roleName: json['roleName'] as String?,
    );
  }

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
      'roleName': roleName,
    };
  }

  AuthEntity toEntity() {
    return AuthEntity(
      userId: userId,
      username: username,
      token: token,
      isActive: isActive,
      lastUpdate: lastUpdate,
      tokenType: tokenType,
      mobileNumber: mobileNumber,
      refreshToken: refreshToken,
      expiresIn: expiresIn,
      userRole: roleName != null
          ? UserRole.values.firstWhere(
              (role) => role.name.toLowerCase() == roleName!.toLowerCase(),
              orElse: () => UserRole.lnp,
            )
          : UserRole.lnp,
    );
  }
}
