import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/core/util/preference_util.dart';
import 'package:kfon_subscriber/features/change_plan/domain/params/subscriber_discount_request_params.dart';
import 'package:kfon_subscriber/features/change_plan/domain/repository/change_plan_repository.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/payment_gateway_entity.dart';
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
    on<UpdateRechargeUi>(_onUpdateRechargeUi);
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
          paymentMode: null,
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

  // Razorpay's native checkout reports success before the backend has
  // confirmed the payment (webhook), and the plan is only changed after
  // that. Poll while the order is still pending so the home page isn't
  // refreshed with the old plan.
  static const _pendingStatuses = {'PENDING', 'INITIATED', 'CREATED'};
  static const _statusPollAttempts = 6;
  static const _statusPollInterval = Duration(seconds: 2);

  Future<void> _onFetchRechargePaymentStatus(
    FetchRechargePaymentStatus event,
    Emitter<DiscountState> emit,
  ) async {
    emit(state.copyWith(status: RechargeStatus.paymentVerifying));
    try {
      // Razorpay's SDK has no server redirect: report the payment so the
      // backend can verify it and complete the order. A failure here is only
      // logged — the status check below still decides the result.
      if (event.razorpayResponse.isNotEmpty) {
        final callback = await repository.notifyRazorpayPayment(
          orderId: event.orderId,
          razorpayResponse: event.razorpayResponse,
        );
        callback.fold(
          (failure) => debugPrint('❌ Razorpay callback failed: $failure'),
          (_) => debugPrint('✅ Razorpay callback accepted'),
        );
      }

      for (var attempt = 1; ; attempt++) {
        final result = await repository.getRechargePaymentStatus(event.orderId);
        final entity = result.fold((failure) {
          emit(
            state.copyWith(
              status: RechargeStatus.error,
              errorMessage: failure.toString(),
            ),
          );
          return null;
        }, (entity) => entity);
        if (entity == null) return;
        final paymentStatus = entity.paymentStatus.toUpperCase();
        debugPrint(
          '💳 Recharge status ${event.orderId} (attempt $attempt): '
          '$paymentStatus',
        );

        if (paymentStatus == 'FAILED') {
          emit(
            state.copyWith(
              status: RechargeStatus.paymentDeclined,
              paymentStatusEntity: entity,
            ),
          );
          return;
        }
        if (!_pendingStatuses.contains(paymentStatus) ||
            attempt >= _statusPollAttempts) {
          // SUCCESS (or still pending after the last attempt — the payment
          // itself went through, so show success; the plan updates once the
          // backend confirms it).
          emit(
            state.copyWith(
              status: RechargeStatus.paymentSuccess,
              paymentStatusEntity: entity,
            ),
          );
          return;
        }
        await Future<void>.delayed(_statusPollInterval);
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: RechargeStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onUpdateRechargeUi(
    UpdateRechargeUi event,
    Emitter<DiscountState> emit,
  ) {
    // A one-shot result (gateway redirect, failure, …) must not stay as the
    // current status: this emit would otherwise re-trigger the page listener
    // with the same status and e.g. reopen the previous gateway's checkout
    // when the user picks another one after a cancelled payment.
    const oneShotStatuses = {
      RechargeStatus.paymentRedirectSuccess,
      RechargeStatus.paymentSuccess,
      RechargeStatus.walletRechargeSuccess,
      RechargeStatus.paymentFailed,
      RechargeStatus.paymentDeclined,
      RechargeStatus.paymentCancelled,
      RechargeStatus.error,
    };
    emit(
      state.copyWith(
        status:
            oneShotStatuses.contains(state.status)
                ? RechargeStatus.orderSummerySuccess
                : null,
        appliedReferralCode: event.appliedReferralCode,
        clearReferralCode:
            event.updateReferralCode && event.appliedReferralCode == null,
        useWallet: event.useWallet,
        selectedGateway: event.selectedGateway,
        agreedToTerms: event.agreedToTerms,
      ),
    );
  }
}
