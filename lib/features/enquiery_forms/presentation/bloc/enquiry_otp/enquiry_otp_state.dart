abstract class EnquiryOtpState {}

class EnquiryOtpInitial extends EnquiryOtpState {}

class EnquiryOtpSending extends EnquiryOtpState {}

class EnquiryOtpSent extends EnquiryOtpState {}

class EnquiryOtpSendError extends EnquiryOtpState {
  final String errorMessage;
  EnquiryOtpSendError({required this.errorMessage});
}

class EnquiryOtpVerifying extends EnquiryOtpState {}

class EnquiryOtpVerified extends EnquiryOtpState {}

class EnquiryOtpVerifyError extends EnquiryOtpState {
  final String errorMessage;
  EnquiryOtpVerifyError({required this.errorMessage});
}
