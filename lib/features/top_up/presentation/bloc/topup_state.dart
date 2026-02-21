import 'package:kfon_subscriber/features/top_up/domain/entity/topup_entity.dart';

/// States for WalletTopupBloc
sealed class TopupState {
  const TopupState();
}

/// Initial state before any topup action.
class TopupInitial extends TopupState {
  const TopupInitial();
}

/// State while topup request is being processed.
class TopupLoading extends TopupState {
  const TopupLoading();
}

/// State when topup request is successful with redirect data.
class TopupSuccess extends TopupState {
  final TopupRedirectEntity redirectData;

  const TopupSuccess({required this.redirectData});
}

/// State when topup request fails with error message.
class TopupError extends TopupState {
  final String errorMessage;

  const TopupError({required this.errorMessage});
}

/// State when payment is completed successfully.
class PaymentCompleted extends TopupState {
  final String? transactionId;
  final double? amount;

  const PaymentCompleted({this.transactionId, this.amount});
}

/// State when payment fails.
class PaymentFailed extends TopupState {
  final String? errorMessage;

  const PaymentFailed({this.errorMessage});
}

/// State when user cancels the payment.
class PaymentCancelled extends TopupState {
  const PaymentCancelled();
}
