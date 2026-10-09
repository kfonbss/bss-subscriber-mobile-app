import 'package:equatable/equatable.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/discount_details_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/payment_gateway_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/recharge_change_plan_redirect_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/recharge_payment_status_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/seasonal_discount_entity.dart';

enum RechargeStatus {
  initial,
  seasonalIDSuccess,
  referralCodeLoading,
  orderSummerySuccess,
  paymentRedirectLoading,
  paymentRedirectSuccess,

  /// Recharge completed without a gateway (paid from wallet).
  walletRechargeSuccess,
  paymentSuccess,
  paymentFailed,
  paymentCancelled,
  error,
}

enum GatewayStatus { initial, loading, loaded, error }

class DiscountState extends Equatable {
  final RechargeStatus status;
  final String? errorMessage;
  final String? responseStatus;
  final String? orderNumber;
  final String? subscriberId;
  final String? subscriberName;
  final String? packageId;
  final String? packageName;
  final num? amount;
  final String? reason;
  final DiscountDetailsEntity? discountDetail;
  final SeasonalDiscountEntity? seasonalDiscountEntity;
  final RechargeChangePlanRedirectEntity? redirectEntity;
  final String? orderId;
  final RechargePaymentStatusEntity? paymentStatusEntity;
  final GatewayStatus gatewayStatus;
  final List<PaymentGatewayEntity> gateways;

  const DiscountState({
    this.status = RechargeStatus.initial,
    this.errorMessage,
    this.responseStatus,
    this.orderNumber,
    this.subscriberId,
    this.subscriberName,
    this.packageId,
    this.packageName,
    this.amount,
    this.reason,
    this.discountDetail,
    this.seasonalDiscountEntity,
    this.redirectEntity,
    this.orderId,
    this.paymentStatusEntity,
    this.gatewayStatus = GatewayStatus.initial,
    this.gateways = const [],
  });

  DiscountState copyWith({
    RechargeStatus? status,
    String? errorMessage,
    String? responseStatus,
    String? orderNumber,
    String? subscriberId,
    String? subscriberName,
    String? packageId,
    String? packageName,
    num? amount,
    String? reason,
    DiscountDetailsEntity? discountDetail,
    SeasonalDiscountEntity? seasonalDiscountEntity,
    bool clearDiscountDetail = false,
    RechargeChangePlanRedirectEntity? redirectEntity,
    String? orderId,
    RechargePaymentStatusEntity? paymentStatusEntity,
    GatewayStatus? gatewayStatus,
    List<PaymentGatewayEntity>? gateways,
  }) {
    return DiscountState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      responseStatus: responseStatus ?? this.responseStatus,
      orderNumber: orderNumber ?? this.orderNumber,
      subscriberId: subscriberId ?? this.subscriberId,
      subscriberName: subscriberName ?? this.subscriberName,
      packageId: packageId ?? this.packageId,
      packageName: packageName ?? this.packageName,
      amount: amount ?? this.amount,
      reason: reason ?? this.reason,
      seasonalDiscountEntity:
          seasonalDiscountEntity ?? this.seasonalDiscountEntity,
      discountDetail:
          clearDiscountDetail ? null : (discountDetail ?? this.discountDetail),
      redirectEntity: redirectEntity ?? this.redirectEntity,
      orderId: orderId ?? this.orderId,
      paymentStatusEntity: paymentStatusEntity ?? this.paymentStatusEntity,
      gatewayStatus: gatewayStatus ?? this.gatewayStatus,
      gateways: gateways ?? this.gateways,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    responseStatus,
    orderNumber,
    subscriberId,
    subscriberName,
    packageId,
    packageName,
    amount,
    reason,
    discountDetail,
    gatewayStatus,
    gateways,
  ];
}
