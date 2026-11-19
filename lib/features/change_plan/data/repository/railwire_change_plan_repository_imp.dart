import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/core/network/api_response.dart';
import 'package:kfon_subscriber/core/network/dio_client.dart';
import 'package:kfon_subscriber/core/network/railwire_api.dart';
import 'package:kfon_subscriber/features/change_plan/data/models/railwire_package_change_model.dart';
import 'package:kfon_subscriber/features/change_plan/data/source/railwire_online_amount_source.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/discount_details_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/package_new_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/package_tab_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/paginated_packages_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/payment_gateway_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/recharge_change_plan_redirect_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/recharge_payment_status_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/seasonal_discount_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/params/get_all_packages_parms.dart';
import 'package:kfon_subscriber/features/change_plan/domain/params/recharge_change_plan_params.dart';
import 'package:kfon_subscriber/features/change_plan/domain/params/subscriber_discount_request_params.dart';
import 'package:kfon_subscriber/features/change_plan/domain/repository/change_plan_repository.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/pages/components/url_redirect_checkout.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/service_locator.dart';

/// RailWire recharge renews the current plan: `onlineamount` gives the amount
/// (which Home passes in as the package's renewal fee) and the gateways. Atom
/// and Razorpay each open a payment page from their `prepare_*_gate_way` API
/// and are confirmed with their `*_trans_check` API. There are no plan or
/// discount APIs yet.
class RailwireChangePlanRepositoryImp extends ChangePlanRepository {
  RailwireChangePlanRepositoryImp({
    required RailwireOnlineAmountSource onlineAmount,
  }) : _onlineAmount = onlineAmount;

  final RailwireOnlineAmountSource _onlineAmount;

  /// The recharge page shows `assets/images/<name lowercased>.png`.
  static const _razorpay = PaymentGatewayEntity(
    id: 'RAZORPAY',
    masterId: 0,
    code: 'RAZORPAY',
    name: 'Razorpay',
    icon: '',
    isActive: true,
  );
  static const _atom = PaymentGatewayEntity(
    id: 'ATOM',
    masterId: 0,
    code: 'ATOM',
    name: 'Atom',
    icon: '',
    isActive: true,
  );

  /// Both gateways send the browser back to RailWire's site once the payment
  /// is over.
  static const _returnHost = 'railwire.co.in';

  /// `recharge_history` is asked for orders placed since the payment started,
  /// allowing for a slightly different server clock.
  static const _orderClockSlack = Duration(minutes: 5);
  static const _orderLookupAttempts = 3;
  static const _orderLookupInterval = Duration(seconds: 2);

  /// The current payment, for its status check.
  String _paymentGateway = '';
  DateTime? _paymentStartedAt;
  double _paymentAmount = 0;

  @override
  Future<Either<Failure, List<PaymentGatewayEntity>>>
  getPaymentGateways() async {
    final online = await _onlineAmount.shared();
    return Right([
      if (online.razorpayEnabled) _razorpay,
      if (online.atomEnabled) _atom,
    ]);
  }

  /// No seasonal discount, so the recharge page asks for the order summary
  /// next and gets no discount either.
  @override
  Future<Either<Failure, SeasonalDiscountEntity>> getSeasonalDiscount(
    String packageId,
  ) async => const Right(SeasonalDiscountEntity());

  /// The order summary, with no discount and no wallet. Changing to a plan
  /// from `Subpackagechange` is previewed with `verifyplanchange`, which gives
  /// its fee and validity days, and a refused change is shown as an error.
  /// Renewing the current plan costs the `onlineamount` amount. The recharge
  /// page only enables Proceed to pay once it has a summary, so an empty list
  /// (nothing to pay) keeps it disabled.
  @override
  Future<Either<Failure, List<DiscountDetailsEntity>>> getSubscriberDiscounts(
    List<SubscriberDiscountRequestParams> params,
  ) async {
    final packageId = params.isEmpty ? '' : params.first.packageId;
    final (online, change) =
        await (_onlineAmount.shared(), RailwirePackageChangeModel.fetch()).wait;
    final model = change.fold<RailwirePackageChangeModel?>(
      (_) => null,
      (model) => model,
    );
    final newPlan =
        model?.plans.where((plan) => plan.packageId == packageId).firstOrNull;

    if (model != null && newPlan != null) {
      final preview = await model.preview(newPlan);
      return preview.map(
        (preview) =>
            preview.newPlanFee <= 0
                ? const <DiscountDetailsEntity>[]
                : [
                  // The current balance is offered as the wallet, which is
                  // what applyplan_subscirber pays the change from.
                  _summary(
                    preview.newPlanFee,
                    preview.newPlanFee,
                    0,
                    validity: preview.totalDays > 0 ? preview.totalDays : null,
                    walletBalance: preview.currentBalance,
                  ),
                ],
      );
    }
    if (online.amount <= 0) return const Right([]);
    return Right([
      _summary(online.packageFee, online.amount, online.gstAmount),
    ]);
  }

  DiscountDetailsEntity _summary(
    double fee,
    double total,
    double gst, {
    int? validity,
    double? walletBalance,
  }) => DiscountDetailsEntity(
    validity: validity,
    packageFee: fee,
    totalDiscount: 0,
    discountedFee: fee,
    discountRate: 0,
    gstAmount: gst,
    baseAmount: fee,
    finalAmount: total,
    appliedRules: const [],
    walletEligible: walletBalance != null,
    walletBalance: walletBalance,
  );

  /// Opens the gateway's payment page from `prepare_atom_gate_way` or
  /// `prepare_razorpay_gate_way`. A plan change goes to [_applyPlanChange]
  /// instead.
  @override
  Future<Either<Failure, RechargeChangePlanResponseEntity>> rechargeChangePlan(
    RechargeChangePlanParams params,
  ) async {
    // The payment or plan change changes what onlineamount returns.
    _onlineAmount.clear();
    if (params.changePlan) return _applyPlanChange(params);
    final gateway = params.gateway ?? '';
    final String url;
    final Map<String, dynamic> Function(RailwireSession session) body;
    if (gateway == _atom.code) {
      url = ApiUrls.railwirePrepareAtomURL;
      body = (session) => session.byUsername;
    } else if (gateway == _razorpay.code) {
      url = ApiUrls.railwirePrepareRazorpayURL;
      // TODO(BE): what `slno` is is an open question with the PHP team; the
      // current plan's package id is sent until it's confirmed.
      body = (session) => {...session.byUsername, 'slno': params.packageId};
    } else {
      return Left(RailwireApi.unavailable);
    }

    final result = await RailwireApi.post(url, body);
    return result.flatMap((data) {
      final pageUrl = data['PAYGATEWAY']?.toString().trim() ?? '';
      if (!(Uri.tryParse(pageUrl)?.hasScheme ?? false)) {
        return Left(ServerFailure(appL10n.unableToStartPayment));
      }
      _paymentGateway = gateway;
      _paymentStartedAt = DateTime.now();
      _paymentAmount = params.amount;
      // Empty until the API returns it; the status check then looks it up.
      final orderId = data['ordernumber']?.toString().trim() ?? '';
      return Right(
        RechargeChangePlanResponseEntity(
          gatewayType: gateway,
          orderId: orderId,
          redirect: RechargeChangePlanRedirectEntity(
            type: UrlRedirectCheckout.redirectType,
            actionUrl: pageUrl,
            method: 'GET',
            params: const {UrlRedirectCheckout.returnHostKey: _returnHost},
            orderId: orderId,
          ),
        ),
      );
    });
  }

  /// Changes the plan with `applyplan_subscirber`, paid from the current
  /// balance (offered as the wallet). A gateway can't pay for it: neither
  /// prepare API takes the new plan, so the payment would renew the current
  /// one. On success the recharge page shows its wallet success sheet.
  Future<Either<Failure, RechargeChangePlanResponseEntity>> _applyPlanChange(
    RechargeChangePlanParams params,
  ) async {
    final paysFromBalance =
        params.useWallet && (params.gateway?.isEmpty ?? true);
    if (!paysFromBalance) {
      return Left(ServerFailure(appL10n.changePlanPaymentUnavailable));
    }

    final change = await RailwirePackageChangeModel.fetch();
    final applied = await change.fold<Future<Either<Failure, String>>>(
      (failure) async => Left(failure),
      (model) => model.apply(params.packageId),
    );
    return applied.map(
      (message) => RechargeChangePlanResponseEntity(
        gatewayType: 'WALLET',
        orderId: '',
        activated: true,
        message: message,
      ),
    );
  }

  /// Confirms the payment with `atom_trans_check` or `razorpay_trans_check`;
  /// Razorpay is first reported with `razorpayresponse`. Never reports
  /// PENDING: the recharge page would show a pending payment as successful, so
  /// an unclear result is a failure with the API's message.
  @override
  Future<Either<Failure, RechargePaymentStatusEntity>> getRechargePaymentStatus(
    String orderId,
  ) async {
    _onlineAmount.clear();
    final isRazorpay = _paymentGateway == _razorpay.code;
    final orderNumber =
        orderId.isNotEmpty ? orderId : await _latestOrderNumber();
    if (orderNumber == null) {
      return Left(ServerFailure(appL10n.paymentNotConfirmed));
    }

    final session = await RailwireSession.current();
    if (session == null) {
      return Left(AuthFailure(appL10n.yourSessionHasExpiredPleaseLogIn));
    }

    try {
      if (isRazorpay) await _reportRazorpayPayment(session, orderNumber);

      // Read directly: Atom's successful check currently comes back with
      // STATUS false, which RailwireApi.post would treat as an error.
      final json = await sl<DioClient>().postRailwire(
        isRazorpay
            ? ApiUrls.railwireRazorpayTransCheckURL
            : ApiUrls.railwireAtomTransCheckURL,
        data: {...session.byUsername, 'ordernumber': orderNumber},
      );
      final data =
          json['data'] is Map<String, dynamic>
              ? json['data'] as Map<String, dynamic>
              : const <String, dynamic>{};
      final message = (data['Message'] ?? json['msg'])?.toString() ?? '';
      final status = paymentStatusOf(
        paymentStatus: data['payment_status']?.toString(),
        message: message,
      );
      if (status == null) {
        return Left(
          ServerFailure(
            message.isNotEmpty ? message : appL10n.paymentNotConfirmed,
          ),
        );
      }

      final amount = RailwireApi.toDouble(data['amount']);
      return Right(
        RechargePaymentStatusEntity(
          orderId: orderNumber,
          gatewayType: isRazorpay ? _razorpay.code : _atom.code,
          txnId: data['txnid']?.toString() ?? orderNumber,
          referenceNo: orderNumber,
          transactionDate: DateTime.now().toIso8601String(),
          amount: amount > 0 ? amount : _paymentAmount,
          paymentStatus: status,
        ),
      );
    } catch (e) {
      return Left(APIResponse.fromError(e).failure);
    }
  }

  /// `razorpayresponse` completes the recharge on RailWire's side. When it has
  /// to be called is an open question with the PHP team, so a failure is only
  /// logged and the transaction check decides the result.
  Future<void> _reportRazorpayPayment(
    RailwireSession session,
    String orderNumber,
  ) async {
    try {
      final json = await sl<DioClient>().postRailwire(
        ApiUrls.railwireRazorpayResponseURL,
        data: {...session.byUsername, 'ordernumber': orderNumber},
      );
      debugPrint('💳 razorpayresponse: $json');
    } catch (e) {
      debugPrint('❌ razorpayresponse failed: $e');
    }
  }

  /// SUCCESS, FAILED, or null when unclear. Uses `payment_status` when the API
  /// sends it, otherwise the message (e.g. "Transaction Successful").
  static String? paymentStatusOf({String? paymentStatus, String message = ''}) {
    final explicit = paymentStatus?.trim().toUpperCase() ?? '';
    if (explicit == 'SUCCESS' || explicit == 'FAILED') return explicit;

    final text = message.toLowerCase();
    // "Unsuccessful" contains "success", so failures are checked first.
    const failures = [
      'unsuccess',
      'fail',
      'declin',
      'cancel',
      'abort',
      'reject',
    ];
    if (failures.any(text.contains)) return 'FAILED';
    if (text.contains('success')) return 'SUCCESS';
    return null;
  }

  /// The newest order in `recharge_history` placed since the payment
  /// started, retried briefly because the order can appear late. Its `txnid`
  /// is what the `*_trans_check` APIs take as `ordernumber`; the history's own
  /// `ordernumber` is the gateway's id.
  Future<String?> _latestOrderNumber() async {
    final startedAt = _paymentStartedAt;
    if (startedAt == null) return null;
    final since = startedAt.subtract(_orderClockSlack);

    for (var attempt = 1; attempt <= _orderLookupAttempts; attempt++) {
      final result = await RailwireApi.post(
        ApiUrls.railwireRechargeHistoryURL,
        (session) => {...session.byUsername, 'history_type': '2'},
      );
      final orderNumber = result.fold<String?>((_) => null, (data) {
        String? latest;
        DateTime? latestTime;
        for (final order
            in (data['recharge_details'] as List<dynamic>? ?? [])
                .whereType<Map<String, dynamic>>()) {
          final time = DateTime.tryParse('${order['order_time']}');
          final number = order['txnid']?.toString().trim() ?? '';
          if (time == null || number.isEmpty || time.isBefore(since)) continue;
          if (latestTime == null || time.isAfter(latestTime)) {
            latest = number;
            latestTime = time;
          }
        }
        return latest;
      });
      if (orderNumber != null) return orderNumber;
      if (attempt < _orderLookupAttempts) {
        await Future<void>.delayed(_orderLookupInterval);
      }
    }
    return null;
  }

  @override
  Future<Either<Failure, void>> notifyRazorpayPayment({
    required String orderId,
    required Map<String, String> razorpayResponse,
  }) async => Left(RailwireApi.unavailable);

  /// The plans the subscriber can change to, from `Subpackagechange`.
  @override
  Future<Either<Failure, PackageNewEntity>> getPackages(
    GetAllPackagesParams params,
  ) async {
    final result = await RailwirePackageChangeModel.fetch();
    return result.map(
      (model) => RailwirePackageChangeModel.packagePage(
        model.matching(params.search),
        params.page,
        params.size,
      ),
    );
  }

  /// The Change plan screen's list, from `Subpackagechange`. Only the name
  /// search applies: the plans have no type, kind or speed to filter by.
  @override
  Future<Either<Failure, PaginatedPackagesEntity>> getSeasonalPackages({
    required int page,
    required int size,
    required String subscriberId,
    required String packageId,
    String? type,
    String? targetKind,
    String? subscriptionType,
    String? packageType,
    String? search,
    int? speedMbps,
  }) async {
    final result = await RailwirePackageChangeModel.fetch();
    return result.map(
      (model) => RailwirePackageChangeModel.paginatedPage(
        model.matching(search),
        page,
        size,
      ),
    );
  }

  /// RailWire only has a change-plan list, so that's the one tab.
  @override
  Future<Either<Failure, PackageTabEntity>> getPackageTabs({
    required String subscriberId,
    required String packageId,
  }) async => Right(
    PackageTabEntity(
      subscriberId: subscriberId,
      packageId: packageId,
      changePackage: const EligibilityEntity(eligible: true),
    ),
  );
}
