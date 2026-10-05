import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/core/util/preference_util.dart';
import 'package:kfon_subscriber/features/change_plan/domain/params/subscriber_discount_request_params.dart';
import 'package:kfon_subscriber/features/change_plan/domain/repository/change_plan_repository.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/bloc/discount_event.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/bloc/discount_state.dart';

class DiscountBloc extends Bloc<DiscountEvent, DiscountState> {
  final ChangePlanRepository repository;

  DiscountBloc({required this.repository}) : super(const DiscountState()) {
    on<GetSeasonalId>(_onGetSeasonalDiscount);
    on<FetchTopUpDiscount>(_onFetchOrderSummery);
    on<ResetTopUpState>(_onReset);
    on<RechargeChangePlan>(_onRechargeChangePlan);
    on<FetchRechargePaymentStatus>(_onFetchRechargePaymentStatus);
    on<LoadPaymentGateways>(_onLoadPaymentGateways);

  }
  Future<void> _onLoadPaymentGateways(
      LoadPaymentGateways event,
      Emitter<DiscountState> emit,
      ) async {
    // Skip if already loading or loaded (guards against duplicate triggers)
    if (state.gatewayStatus == GatewayStatus.loading ||
        state.gatewayStatus == GatewayStatus.loaded) {
      return;
    }

    emit(state.copyWith(gatewayStatus: GatewayStatus.loading));
    try {
      final result = await repository.getPaymentGateways();
      result.fold(
            (failure) => emit(state.copyWith(gatewayStatus: GatewayStatus.error)),
            (gateways) => emit(
          state.copyWith(
            gatewayStatus: GatewayStatus.loaded,
            gateways: gateways,
          ),
        ),
      );
    } catch (_) {
      emit(state.copyWith(gatewayStatus: GatewayStatus.error));
    }
  }
  Future<void> _onGetSeasonalDiscount(
    GetSeasonalId event,
    Emitter<DiscountState> emit,
  ) async {
    try {
      emit(state.copyWith(clearDiscountDetail: true));
      final result = await repository.getSeasonalDiscount(event.packageId);

      result.fold(
        (failure) => emit(
          state.copyWith(
            status: RechargeStatus.error,
            errorMessage: failure.message,
            clearDiscountDetail: true,
          ),
        ),
        (entity) {
          emit(
            state.copyWith(
              status: RechargeStatus.seasonalIDSuccess,
              seasonalDiscountEntity: entity,
            ),
          );
        },
      );
    } catch (e) {
      state.copyWith(
        status: RechargeStatus.error,
        errorMessage: e.toString(),
        clearDiscountDetail: true,
      );
    }
  }

  Future<void> _onFetchOrderSummery(
    FetchTopUpDiscount event,
    Emitter<DiscountState> emit,
  ) async {
    try {
      final userId = await PreferenceUtils.getUserId() ?? '';
      if (event.referral) {
        emit(state.copyWith(status: RechargeStatus.referralCodeLoading));
      }
      final request = [
        SubscriberDiscountRequestParams(
          subscriberId: userId,
          packageId: event.packageId,
          seasonId: event.seasonId ?? '',
          paymentMode:null,
          referral: event.referral,
          referralCode: event.referralCode,
        ),
      ];
      final result = await repository.getSubscriberDiscounts(request);

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              status: RechargeStatus.error,
              errorMessage: failure.message,
              clearDiscountDetail: true,
            ),
          );
        },
        (discounts) {
          emit(
            state.copyWith(
              status: RechargeStatus.orderSummerySuccess,
              discountDetail: discounts.isNotEmpty ? discounts.first : null,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: RechargeStatus.error,
          errorMessage: e.toString(),
          clearDiscountDetail: true,
        ),
      );
    }
  }

  void _onReset(ResetTopUpState event, Emitter<DiscountState> emit) {
    emit(const DiscountState());
  }

  Future<void> _onRechargeChangePlan(
    RechargeChangePlan event,
    Emitter<DiscountState> emit,
  ) async {
    try {
      emit(state.copyWith(status: RechargeStatus.paymentRedirectLoading));
      final result = await repository.rechargeChangePlan(event.params);

      result.fold(
        (failure) => emit(
          state.copyWith(
            status: RechargeStatus.paymentFailed,
            errorMessage: failure.toString(),
          ),
        ),
        (data) {
          if (data.redirect != null) {
            // Online gateway: continue in the payment webview.
            emit(
              state.copyWith(
                status: RechargeStatus.paymentRedirectSuccess,
                redirectEntity: data.redirect,
                orderId: data.orderId,
              ),
            );
          } else if (data.activated) {
            // Wallet: the recharge is already complete, no redirect.
            emit(
              state.copyWith(
                status: RechargeStatus.walletRechargeSuccess,
                orderId: data.orderId,
              ),
            );
          } else {
            emit(
              state.copyWith(
                status: RechargeStatus.paymentFailed,
                errorMessage: data.message,
              ),
            );
          }
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: RechargeStatus.paymentFailed,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onFetchRechargePaymentStatus(
    FetchRechargePaymentStatus event,
    Emitter<DiscountState> emit,
  ) async {
    try {
      final result = await repository.getRechargePaymentStatus(event.orderId);

      result.fold(
        (failure) => emit(
          state.copyWith(
            status: RechargeStatus.error,
            errorMessage: failure.toString(),
          ),
        ),
        (entity) => emit(
          state.copyWith(
            status: RechargeStatus.paymentSuccess,
            paymentStatusEntity: entity,
          ),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: RechargeStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
