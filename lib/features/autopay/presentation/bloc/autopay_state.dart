import 'package:equatable/equatable.dart';
import 'package:kfon_subscriber/features/autopay/domain/entity/autopay_entity.dart';

/// Loading state of the screen content.
enum AutopayViewStatus { initial, loading, loaded, error }

/// One-off results of user actions, shown as a message by the page.
enum AutopayAction {
  none,
  initiating,
  initiateSuccess,
  initiateFailure,
  revoking,
  revokeSuccess,
  revokeFailure,
}

class AutopayState extends Equatable {
  final AutopayViewStatus viewStatus;
  final AutopayStatus autopayStatus;

  /// Set when Autopay is not enabled (enable screen).
  final AutopayQuoteEntity? quote;

  /// Set when Autopay is enabled (details screen).
  final AutopayMandateDetailsEntity? details;

  final AutopayAction action;

  /// Error for [AutopayViewStatus.error] or a failed action; success message
  /// for a successful action.
  final String? message;

  const AutopayState({
    this.viewStatus = AutopayViewStatus.initial,
    this.autopayStatus = AutopayStatus.notEnabled,
    this.quote,
    this.details,
    this.action = AutopayAction.none,
    this.message,
  });

  bool get isInitiating => action == AutopayAction.initiating;
  bool get isRevoking => action == AutopayAction.revoking;

  AutopayState copyWith({
    AutopayViewStatus? viewStatus,
    AutopayStatus? autopayStatus,
    AutopayQuoteEntity? quote,
    AutopayMandateDetailsEntity? details,
    bool clearQuote = false,
    bool clearDetails = false,
    AutopayAction? action,
    String? message,
  }) {
    return AutopayState(
      viewStatus: viewStatus ?? this.viewStatus,
      autopayStatus: autopayStatus ?? this.autopayStatus,
      quote: clearQuote ? null : (quote ?? this.quote),
      details: clearDetails ? null : (details ?? this.details),
      // Actions and messages are one-off: reset unless explicitly set.
      action: action ?? AutopayAction.none,
      message: message,
    );
  }

  @override
  List<Object?> get props => [
    viewStatus,
    autopayStatus,
    quote,
    details,
    action,
    message,
  ];
}
