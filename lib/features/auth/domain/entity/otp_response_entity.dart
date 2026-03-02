import 'package:equatable/equatable.dart';

class OtpResponseEntity extends Equatable {
  final String otpRefId;
  final String? mobileNumber;

  const OtpResponseEntity({required this.otpRefId, this.mobileNumber});

  @override
  List<Object?> get props => [otpRefId, mobileNumber];
}
