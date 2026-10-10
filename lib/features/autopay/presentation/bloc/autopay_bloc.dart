import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/features/autopay/domain/entity/autopay_entity.dart';
import 'package:kfon_subscriber/features/autopay/domain/repository/autopay_repository.dart';
import 'package:kfon_subscriber/features/autopay/presentation/bloc/autopay_event.dart';
import 'package:kfon_subscriber/features/autopay/presentation/bloc/autopay_state.dart';

class AutopayBloc extends Bloc<AutopayEvent, AutopayState> {
  final AutopayRepository repository;

  AutopayBloc({required this.repository}) : super(const AutopayState()) {
    on<LoadAutopay>(_onLoad);
    on<InitiateAutopay>(_onInitiate);
    on<RevokeAutopay>(_onRevoke);
  }

  Future<void> _onLoad(LoadAutopay event, Emitter<AutopayState> emit) async {
    emit(state.copyWith(viewStatus: AutopayViewStatus.loading));
    await _loadContent(emit);
  }

  /// status → quote. The quote carries both the enable-screen charges and,
  /// once enabled (ACTIVE / PENDING), the mandate details.
  ///
  /// [fallbackUpiId] is passed right after a successful initiate. The status
  /// can take a moment to update, so the page is treated as PENDING and the
  /// entered UPI ID is shown until the quote returns the mandate's own.
  Future<void> _loadContent(
    Emitter<AutopayState> emit, {
    AutopayAction? action,
    String? message,
    String? fallbackUpiId,
  }) async {
    final statusResult = await repository.getStatus();
    var status = statusResult.fold((_) => null, (s) => s);
    if (fallbackUpiId != null && (status == null || !status.isEnabled)) {
      status = AutopayStatus.pending;
    }
    if (status == null) {
      emit(
        state.copyWith(
          viewStatus: AutopayViewStatus.error,
          message: statusResult.fold((f) => f.toString(), (_) => null),
        ),
      );
      return;
    }

    final loadedStatus = status;
    final result = await repository.getQuote();
    result.fold(
      (failure) => emit(
        state.copyWith(
          viewStatus: AutopayViewStatus.error,
          autopayStatus: loadedStatus,
          message: failure.toString(),
        ),
      ),
      (quote) => emit(
        state.copyWith(
          viewStatus: AutopayViewStatus.loaded,
          autopayStatus: loadedStatus,
          quote: quote,
          details:
              loadedStatus.isEnabled
                  ? quote.toMandateDetails(fallbackUpiId: fallbackUpiId)
                  : null,
          clearDetails: !loadedStatus.isEnabled,
          action: action,
          message: message,
        ),
      ),
    );
  }

  Future<void> _onInitiate(
    InitiateAutopay event,
    Emitter<AutopayState> emit,
  ) async {
    if (state.isInitiating) return;
    emit(state.copyWith(action: AutopayAction.initiating));

    final result = await repository.initiate(upiId: event.upiId);
    await result.fold(
      (failure) async => emit(
        state.copyWith(
          action: AutopayAction.initiateFailure,
          message: failure.toString(),
        ),
      ),
      // Mandate created (usually PENDING until approved in the UPI app):
      // reload so the page switches to the details screen.
      (message) => _loadContent(
        emit,
        action: AutopayAction.initiateSuccess,
        message: message,
        fallbackUpiId: event.upiId,
      ),
    );
  }

  Future<void> _onRevoke(
    RevokeAutopay event,
    Emitter<AutopayState> emit,
  ) async {
    if (state.isRevoking) return;
    emit(state.copyWith(action: AutopayAction.revoking));

    final result = await repository.revoke();
    await result.fold(
      (failure) async => emit(
        state.copyWith(
          action: AutopayAction.revokeFailure,
          message: failure.toString(),
        ),
      ),
      // Reload so the page switches back to the enable screen.
      (message) => _loadContent(
        emit,
        action: AutopayAction.revokeSuccess,
        message: message,
      ),
    );
  }
}
