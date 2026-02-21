/// Events for WalletTopupBloc
sealed class TopupEvent {
  const TopupEvent();
}

/// Event to initiate a wallet topup with specified amount and payment type.
class InitiateTopup extends TopupEvent {
  final double amount;
  final String paymentType;

  const InitiateTopup({required this.amount, required this.paymentType});
}

/// Event triggered when payment is completed successfully.
class OnPaymentCompleted extends TopupEvent {
  final String? transactionId;
  final double? amount;

  const OnPaymentCompleted({this.transactionId, this.amount});
}

/// Event triggered when payment fails.
class OnPaymentFailed extends TopupEvent {
  final String? errorMessage;

  const OnPaymentFailed({this.errorMessage});
}

/// Event triggered when user cancels the payment.
class OnPaymentCancelled extends TopupEvent {
  const OnPaymentCancelled();
}
