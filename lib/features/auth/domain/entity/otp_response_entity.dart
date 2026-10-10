import 'package:kfon_subscriber/features/auth/data/model/verify_otp_model.dart';
import 'package:equatable/equatable.dart';

class OtpResponseEntity extends Equatable {
  final String otpRefId;
  final String? mobileNumber;
  final UserRole? userRole;

  const OtpResponseEntity({required this.otpRefId, this.mobileNumber,this.userRole});

  @override
  List<Object?> get props => [otpRefId, mobileNumber,userRole];
}
