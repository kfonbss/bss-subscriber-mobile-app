import 'package:kfon_subscriber/features/top_up/domain/entity/topup_params.dart';
import 'package:kfon_subscriber/features/top_up/domain/repository/topup_repository.dart';
import 'package:kfon_subscriber/features/top_up/presentation/bloc/topup_event.dart';
import 'package:kfon_subscriber/features/top_up/presentation/bloc/topup_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class TopupBloc extends Bloc<TopupEvent, TopupState> {
  final TopupRepository repository;

  TopupBloc({required this.repository})
    : super(const TopupInitial()) {
    on<InitiateTopup>(_onInitiateTopup);
    on<OnPaymentCompleted>(_onPaymentCompleted);
    on<OnPaymentFailed>(_onPaymentFailed);
    on<OnPaymentCancelled>(_onPaymentCancelled);
  }

  Future<void> _onInitiateTopup(
    InitiateTopup event,
    Emitter<TopupState> emit,
  ) async {
    emit(const TopupLoading());

    final params = TopupParams(
      amount: event.amount,
      type: event.paymentType,
    );

    final result = await repository.initiateTopup(params);

    result.fold(
      (failure) => emit(TopupError(errorMessage: failure.message)),
      (redirectData) => emit(TopupSuccess(redirectData: redirectData)),
    );
  }

  void _onPaymentCompleted(
      OnPaymentCompleted event,
    Emitter<TopupState> emit,
  ) {
    emit(
      PaymentCompleted(
        transactionId: event.transactionId,
        amount: event.amount,
      ),
    );
  }

  void _onPaymentFailed(OnPaymentFailed event, Emitter<TopupState> emit) {
    emit(PaymentFailed(errorMessage: event.errorMessage));
  }

  void _onPaymentCancelled(
      OnPaymentCancelled event,
    Emitter<TopupState> emit,
  ) {
    emit(const PaymentCancelled());
  }
}
