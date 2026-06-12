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
          paymentMode: '',
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
        (data) => emit(
          state.copyWith(
            status: RechargeStatus.paymentRedirectSuccess,
            redirectEntity: data.redirect,
            orderId: data.orderId,
          ),
        ),
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
