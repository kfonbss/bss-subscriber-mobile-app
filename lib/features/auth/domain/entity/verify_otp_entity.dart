import 'package:kfon_subscriber/features/auth/data/model/verify_otp_model.dart';
import 'package:equatable/equatable.dart';

class VerifyOtpEntity extends Equatable {
  final String userId;
  final String username;
  final String token;
  final bool isActive;
  final bool isFirstLogin;
  final String? lastUpdate;
  final String tokenType;
  final String mobileNumber;
  final String refreshToken;
  final int expiresIn;

  /// Allowed app roles (LNP / AGNP). `null` means the authenticated user does
  /// not have any role permitted to use this app and login should be blocked.
  final UserRole? userRole;

  /// Sub-user type from login (e.g. `CO_USER`). `null` for primary LNP account.
  final String? lnpSubUserType;

  const VerifyOtpEntity({
    required this.userId,
    required this.username,
    required this.token,
    required this.isActive,
    required this.isFirstLogin,
    this.lastUpdate,
    required this.tokenType,
    required this.mobileNumber,
    required this.refreshToken,
    required this.expiresIn,
    required this.userRole,
    this.lnpSubUserType,
  });

  bool get hasAllowedRole => userRole != null;

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
    lnpSubUserType,
  ];
}
