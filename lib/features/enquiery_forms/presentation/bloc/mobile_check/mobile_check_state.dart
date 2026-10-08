abstract class MobileCheckState {}

class MobileCheckInitial extends MobileCheckState {}

class MobileCheckLoading extends MobileCheckState {}

/// An enquiry already exists for [mobileNumber].
class MobileAlreadyRegistered extends MobileCheckState {
  final String mobileNumber;
  final String? trackingId;
  MobileAlreadyRegistered({required this.mobileNumber, this.trackingId});
}

class MobileNotRegistered extends MobileCheckState {}

class MobileCheckError extends MobileCheckState {
  final String errorMessage;
  MobileCheckError({required this.errorMessage});
}
