import 'package:equatable/equatable.dart';

abstract class AutopayEvent extends Equatable {
  const AutopayEvent();

  @override
  List<Object?> get props => [];
}

/// Checks the mandate status, then loads the details (enabled) or the quote
/// (not enabled) for the matching screen.
class LoadAutopay extends AutopayEvent {
  const LoadAutopay();
}

/// Enables Autopay with the given UPI ID.
class InitiateAutopay extends AutopayEvent {
  final String upiId;

  const InitiateAutopay({required this.upiId});

  @override
  List<Object?> get props => [upiId];
}

/// Removes the active mandate.
class RevokeAutopay extends AutopayEvent {
  const RevokeAutopay();
}
