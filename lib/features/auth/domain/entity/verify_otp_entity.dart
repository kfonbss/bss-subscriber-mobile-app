import 'package:kfon_subscriber/features/auth/data/model/verify_otp_model.dart';
import 'package:equatable/equatable.dart';

class VerifyOtpEntity extends Equatable {
  final String userId;
  final String username;
  final String token;
  final bool isActive;
  final String? lastUpdate;
  final String tokenType;
  final String mobileNumber;
  final String refreshToken;
  final int expiresIn;
  final UserRole? userRole;


  const VerifyOtpEntity({
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
  ];

}