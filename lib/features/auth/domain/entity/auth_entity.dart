import 'package:equatable/equatable.dart';

enum UserRole { lnp, agnp }

class AuthEntity extends Equatable {
  final String userId;
  final String username;
  final String token;
  final bool isActive;
  final String? lastUpdate;
  final String tokenType;
  final String mobileNumber;
  final String refreshToken;
  final int expiresIn;
  final UserRole userRole;

  const AuthEntity({
    required this.userId,
    required this.username,
    required this.token,
    required this.isActive,
    this.lastUpdate,
    required this.tokenType,
    required this.mobileNumber,
    required this.refreshToken,
    required this.expiresIn,
    required this.userRole,
  });

  @override
  List<Object?> get props => [
    userId,
    username,
    token,
    isActive,
    lastUpdate,
    tokenType,
    mobileNumber,
    refreshToken,
    expiresIn,
    userRole,
  ];
}
