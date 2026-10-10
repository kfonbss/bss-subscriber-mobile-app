import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/painter/dashed_line_painter.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/discount_details_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/package_new_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/payment_gateway_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/params/recharge_change_plan_params.dart';
import 'package:kfon_subscriber/features/change_plan/domain/repository/change_plan_repository.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/bloc/discount_bloc.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/bloc/discount_event.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/bloc/discount_state.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/pages/components/razorpay_checkout.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/pages/payment_webview_page.dart';
import 'package:kfon_subscriber/features/home/presentation/bloc/home_bloc.dart';
import 'package:kfon_subscriber/features/home/presentation/bloc/home_event.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/service_locator.dart';
import 'package:kfon_subscriber/shared/widgets/common_app_bar.dart';
import 'package:kfon_subscriber/shared/widgets/primary_button.dart';
import 'package:kfon_subscriber/shared/widgets/secondary_button.dart';
import 'package:kfon_subscriber/shared/widgets/retry_widget.dart';
import 'package:kfon_subscriber/shared/widgets/shimmer/list_shimmers.dart';
import 'package:kfon_subscriber/core/constant/app_assets.dart';

class RechargePage extends StatefulWidget {
  final PackageInfoEntity package;
  final String? referralCode;
  final bool isChangePlan;

  const RechargePage({
    super.key,
    required this.isChangePlan,
    required this.package,
    this.referralCode,
  });

  @override
  State<RechargePage> createState() => _RechargePageState();
}

class _RechargePageState extends State<RechargePage> {
  String? _appliedReferralCode;
  late TextEditingController _referralController;
  late DiscountBloc _discountBloc;

  /// Selected online gateway name ('' = none).
  String _selectedGateway = '';
  bool _useWallet = false;
  bool _agreedToTerms = false;
  final DialogUtil _dialogUtil = DialogUtil();

  static const _backdropColor = AppColor.kBlack50;
  static const _dialogContainerDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(20)),
  );

  // ElevatedButton.styleFrom() is not const — computed once as static final.
  static get _dialogButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: AppColor.kPrimaryColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
  );
  static final _dashedPainter = DashedLinePainter(
    color: AppColor.kBlack10,
    strokeWidth: 1,
  );
  static final _totalDividerPainter = DashedLinePainter(
    color: AppColor.kTotalDivider,
    strokeWidth: 1,
  );

  static final _currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹ ',
    decimalDigits: 2,
  );

  static const _cardShadows = [
    BoxShadow(color: AppColor.kBlack2, blurRadius: 3, offset: Offset(0, 1)),
    BoxShadow(color: AppColor.kBlack3, blurRadius: 10, offset: Offset(0, 2)),
  ];

  static TextStyle _textStyle(
    double size,
    FontWeight weight,
    Color color, {
    double? height,
    double? letterSpacing,
  }) => TextStyle(
    fontFamily: 'GeneralSans',
    fontSize: size.sp,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
  );

  @override
  void initState() {
    super.initState();
    _referralController = TextEditingController(
      text: widget.referralCode ?? '',
    );
    _discountBloc = DiscountBloc(repository: sl<ChangePlanRepository>());
    _discountBloc
      ..add(GetSeasonalId(packageId: widget.package.id))
      ..add(const LoadPaymentGateways());
  }

  @override
  void dispose() {
    _referralController.dispose();
    _discountBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;

    return BlocConsumer<DiscountBloc, DiscountState>(
      bloc: _discountBloc,
      listener: (context, state) {
        if (state.status == RechargeStatus.seasonalIDSuccess) {
          _discountBloc.add(
            FetchTopUpDiscount(
              packageId: widget.package.id,
              seasonId: state.seasonalDiscountEntity!.seasonId,
              referral: false,
              referralCode: '',
            ),
          );
        } else if (state.status == RechargeStatus.paymentRedirectSuccess &&
            state.redirectEntity != null) {
          final redirect = state.redirectEntity!;
          // Razorpay uses its native SDK (net banking can't open in a
          // WebView); other gateways post a form in PaymentWebViewPage.
          final Future<RechargeStatus?> payment =
              RazorpayCheckout.supports(redirect)
                  ? RazorpayCheckout.open(redirect)
                  : Navigator.push<RechargeStatus>(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              PaymentWebViewPage(redirectEntity: redirect),
                    ),
                  );
          payment.then((result) {
            if (!context.mounted) return;
            if (result == RechargeStatus.paymentSuccess) {
              if (state.orderId != null) {
                _discountBloc.add(
                  FetchRechargePaymentStatus(orderId: state.orderId!),
                );
              }
            } else if (result == RechargeStatus.paymentFailed) {
              _showTopUpFailDialog(state.discountDetail!.finalAmount, context);
            } else if (result == RechargeStatus.paymentCancelled) {
              _dialogUtil.showCustomSnackbar(
                context: context,
                content: l10n.rechargePaymentCancelled,
                backgroundColor: AppColor.kPendingOrange,
              );
            }
          });
        } else if (state.status == RechargeStatus.paymentSuccess &&
            state.paymentStatusEntity != null) {
          context.read<HomeBloc>().add(const GetHomeData(loadPackage: false));
          _showTopUpSuccessDialog(
            context,
            amount: state.paymentStatusEntity!.amount,
            txnId: state.paymentStatusEntity!.txnId,
          );
        } else if (state.status == RechargeStatus.walletRechargeSuccess) {
          // Wallet payments complete immediately — no gateway, no txn id.
          context.read<HomeBloc>().add(const GetHomeData(loadPackage: false));
          _showTopUpSuccessDialog(
            context,
            amount:
                state.discountDetail?.finalAmount ?? widget.package.renewalFee,
          );
        } else if (state.status == RechargeStatus.error ||
            state.status == RechargeStatus.paymentFailed) {
          _dialogUtil.showCustomSnackbar(
            context: context,
            content: l10n.rechargeFailedError(
              state.errorMessage ?? l10n.somethingWentWrong,
            ),
            backgroundColor: AppColor.kSuspendedStatusText,
          );
        }
      },
      builder: (context, state) {
        final discount = state.discountDetail;
        final seasonalId = state.seasonalDiscountEntity?.seasonId;
        final calculatedFinalAmount =
            discount?.finalAmount ?? widget.package.renewalFee;
        return CommonAppBar(
          title: l10n.recharge,
          scaffoldColor: AppColor.kMainBackgroundColor,
          onBackPressed: () => Navigator.of(context).pop(),
          body:
              state.status == RechargeStatus.initial
                  ? ListShimmer(
                    padding: EdgeInsetsGeometry.all(16),
                    itemHeight: 200,
                    itemCount: 4,
                    separatorHeight: 20,
                  )
                  : Column(
                    children: [
                      Expanded(
                        child: ListView(
                          // Design: content starts 24 below the toolbar;
                          // CommonAppBar already leaves that gap.
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
                          children: [
                            if (discount != null &&
                                discount.appliedRules.isNotEmpty) ...[
                              _buildDiscountBanner(discount),
                              SizedBox(height: 16.h),
                            ],
                            _buildCurrentPackageCard(discount),
                            SizedBox(height: 24.h),
                            _buildPackageDetails(
                              discount,
                              calculatedFinalAmount,
                            ),
                            SizedBox(height: 20.h),
                            _buildReferralCode(
                              discount,
                              state.status ==
                                  RechargeStatus.referralCodeLoading,
                              seasonalId,
                            ),
                            SizedBox(height: 20.h),
                            _buildPaymentGateways(
                              state,
                              discount,
                              calculatedFinalAmount,
                            ),
                            SizedBox(height: 20.h),
                            _buildSecureNote(),
                            SizedBox(height: 24.h),
                            _buildTermsAndConditions(),
                            SizedBox(height: 8.h),
                            _buildAgreeCheckbox(),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
                        child: PrimaryButton(
                          label: l10n.proceedToPay,
                          isLoading:
                              state.status ==
                              RechargeStatus.paymentRedirectLoading,
                          // Enabled only after a payment method (wallet or
                          // gateway) is selected and the terms are accepted.
                          onClicked:
                              _canProceed(discount)
                                  ? () => _onProceedToPay(
                                    state,
                                    calculatedFinalAmount,
                                    seasonalId,
                                  )
                                  : null,
                        ),
                      ),
                    ],
                  ),
        );
      },
    );
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  /// The wallet can pay the full amount on its own.
  bool _isWalletSufficient(DiscountDetailsEntity? discount) =>
      discount != null &&
      (discount.walletEligible ?? false) &&
      (discount.walletBalance ?? 0) >= discount.finalAmount;

  /// Wallet counts as selected only while it still covers the amount
  /// (a referral code can change the total after it was picked).
  bool _isWalletSelected(DiscountDetailsEntity? discount) =>
      _useWallet && _isWalletSufficient(discount);

  /// Exactly one payment method (wallet or gateway) is selected and the
  /// terms are accepted.
  bool _canProceed(DiscountDetailsEntity? discount) =>
      discount != null &&
      _agreedToTerms &&
      (_isWalletSelected(discount) || _selectedGateway.isNotEmpty);

  void _onProceedToPay(
    DiscountState state,
    double calculatedFinalAmount,
    String? seasonalId,
  ) {
    final discount = state.discountDetail;
    if (discount == null || !_canProceed(discount)) return;
    final useWallet = _isWalletSelected(discount);

    _discountBloc.add(
      RechargeChangePlan(
        params: RechargeChangePlanParams(
          packageId: widget.package.id,
          gateway: useWallet ? null : _selectedGateway.toUpperCase(),
          amount: calculatedFinalAmount,
          durationDays: widget.package.renewPeriod,
          expectedFinalAmount: calculatedFinalAmount,
          seasonId: seasonalId,
          referral: _appliedReferralCode != null,
          useWallet: useWallet,
          changePlan: widget.isChangePlan,
        ),
      ),
    );
  }

  // ── Current package (gradient) card ────────────────────────────────────────

  Widget _buildCurrentPackageCard(DiscountDetailsEntity? discount) {
    final l10n = context.bssSubL10n;
    final primary = AppColor.kPrimaryColor;
    final category = discount?.category ?? widget.package.category ?? '';
    final validityDays = discount?.validity ?? widget.package.renewPeriod;
    final speed = discount?.speed ?? widget.package.fallbackSpeed;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: const Alignment(0.35, -0.35),
          end: const Alignment(0.65, 1.35),
          colors: [
            primary,
            Color.lerp(primary, Colors.black, 0.12)!,
            Color.lerp(primary, Colors.black, 0.25)!,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 4),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: primary.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 10),
            spreadRadius: -3,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40.w,
            bottom: -39.5.h,
            child: Container(
              width: 176.w,
              height: 176.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
          ),
          Positioned(
            right: 12.w,
            top: 12.h,
            child: Container(
              width: 112.w,
              height: 112.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _pill(
                      color: Colors.white.withValues(alpha: 0.20),
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 2.h,
                      ),
                      child: Text(
                        l10n.currentPackage,
                        style: _textStyle(
                          10,
                          FontWeight.w500,
                          Colors.white.withValues(alpha: 0.95),
                          height: 1.5,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (category.isNotEmpty)
                      _pill(
                        color: Colors.white.withValues(alpha: 0.15),
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.wifi, size: 14.sp, color: Colors.white),
                            SizedBox(width: 4.w),
                            Text(
                              category,
                              style: _textStyle(
                                11,
                                FontWeight.w700,
                                Colors.white,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 8.h),
                FractionallySizedBox(
                  widthFactor: 0.75,
                  child: Text(
                    widget.package.packageName,
                    style: _textStyle(
                      20,
                      FontWeight.w600,
                      Colors.white,
                      height: 1.4,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                // Design: pill and speed column centred vertically.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _pill(
                      color: AppColor.kSlate900Alpha35,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 13.w,
                        vertical: 5.h,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 14.sp,
                            color: Colors.white,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            l10n.daysValidity('$validityDays'),
                            style: _textStyle(
                              12,
                              FontWeight.w500,
                              Colors.white,
                              height: 1.33,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: EdgeInsets.only(bottom: 3.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            l10n.speedCaps,
                            style: _textStyle(
                              10,
                              FontWeight.w500,
                              Colors.white.withValues(alpha: 0.80),
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 5.h),
                          Text(
                            '$speed Mbps',
                            textAlign: TextAlign.right,
                            style: _textStyle(
                              12,
                              FontWeight.w600,
                              Colors.white,
                              height: 1.33,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Applied discount banner ────────────────────────────────────────────────

  Widget _buildDiscountBanner(DiscountDetailsEntity discount) {
    final l10n = context.bssSubL10n;
    final rule = discount.appliedRules.first;
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColor.kCreamYellowBg,
        border: Border.all(color: AppColor.kLightAmber),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.wb_sunny_rounded, color: Colors.orange, size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.discountAppliedHeader(
                    rule.ruleName,
                    rule.discountValue.toString(),
                  ),
                  style: _textStyle(
                    13,
                    FontWeight.w600,
                    AppColor.kAmberBrown,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  l10n.discountAppliedSubtitle,
                  style: _textStyle(
                    10,
                    FontWeight.w400,
                    AppColor.kAmberDark,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill({
    required Widget child,
    required Color color,
    required EdgeInsetsGeometry padding,
    BoxBorder? border,
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        border: border,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: child,
    );
  }

  // ── Package details / price breakdown ──────────────────────────────────────

  Widget _buildPackageDetails(
    DiscountDetailsEntity? discount,
    double calculatedFinalAmount,
  ) {
    final l10n = context.bssSubL10n;
    final labelStyle = _textStyle(
      12,
      FontWeight.w500,
      AppColor.kSlate600,
      height: 1.33,
    );
    final valueStyle = _textStyle(
      14,
      FontWeight.w600,
      AppColor.kSlate800,
      height: 1.43,
    );

    return _whiteCard(
      padding: EdgeInsets.all(17.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(bottom: 5.h),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColor.kDividerLight)),
            ),
            child: Text(
              l10n.packageDetails,
              style: _textStyle(
                16,
                FontWeight.w600,
                AppColor.kTextSecondaryDark,
                height: 1.3,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          _priceRow(
            label: Text(l10n.packageFee, style: labelStyle),
            value: Text(
              _currency.format(
                discount?.packageFee ?? widget.package.renewalFee,
              ),
              style: valueStyle,
            ),
          ),
          SizedBox(height: 8.h),
          _priceRow(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.gstLabel, style: labelStyle),
                SizedBox(width: 4.w),
                _tag(
                  text: l10n.cgstSgst,
                  textColor: AppColor.kTagGreyText,
                  background: AppColor.kSlate100,
                ),
              ],
            ),
            value: Text(
              _currency.format(discount?.gstAmount ?? 0),
              style: valueStyle,
            ),
          ),
          if (discount == null || discount.appliedRules.isEmpty) ...[
            SizedBox(height: 8.h),
            _priceRow(
              label: Text(l10n.specialDiscount, style: labelStyle),
              value: Text(_currency.format(0), style: valueStyle),
            ),
          ] else
            for (final rule in discount.appliedRules) ...[
              SizedBox(height: 8.h),
              _priceRow(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        l10n.specialDiscount,
                        style: labelStyle.copyWith(
                          color: AppColor.kDiscountGreen,
                        ),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    _tag(
                      text: l10n.appliedCaps,
                      textColor: AppColor.kDiscountGreen,
                      background: AppColor.kDiscountGreenBg,
                      borderColor: AppColor.kDiscountGreenBorder,
                    ),
                  ],
                ),
                value: Text(
                  '- ${_currency.format(rule.discountAmount)}',
                  style: valueStyle.copyWith(color: AppColor.kDiscountGreen),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                l10n.seasonDiscountRule(
                  rule.ruleName,
                  rule.discountValue.toString(),
                ),
                style: _textStyle(
                  10,
                  FontWeight.w400,
                  AppColor.kSlate500,
                  height: 1.4,
                ),
              ),
            ],
          SizedBox(height: 8.h),
          // Design: dashed #DADADA divider, total row 16 below it.
          SizedBox(
            width: double.infinity,
            height: 1,
            child: CustomPaint(painter: _totalDividerPainter),
          ),
          Padding(
            padding: EdgeInsets.only(top: 16.h),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.totalPayable,
                        style: _textStyle(
                          14,
                          FontWeight.w600,
                          AppColor.kSlate900,
                          height: 1.14,
                        ),
                      ),
                      Text(
                        l10n.inclusiveOfAllTaxes,
                        style: _textStyle(
                          10,
                          FontWeight.w400,
                          AppColor.kSlate600,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                // Design uses Plus Jakarta Sans ExtraBold for the total.
                Text(
                  _currency.format(calculatedFinalAmount),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColor.kPrimaryColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceRow({required Widget label, required Widget value}) {
    return Row(children: [Expanded(child: label), SizedBox(width: 8.w), value]);
  }

  Widget _tag({
    required String text,
    required Color textColor,
    required Color background,
    Color? borderColor,
  }) {
    return Container(
      // Design: plain tag px 4; bordered tag px 5 / py 1 inside its border.
      padding:
          borderColor != null
              ? EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h)
              : EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: background,
        border: borderColor != null ? Border.all(color: borderColor) : null,
        borderRadius: BorderRadius.circular(4),
      ),
      // Design uses Inter Semi Bold for these tags.
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: textColor,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _whiteCard({
    required Widget child,
    required EdgeInsetsGeometry padding,
    Color borderColor = AppColor.kCardBorderBeige,
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(16),
        boxShadow: _cardShadows,
      ),
      child: child,
    );
  }

  // ── Referral code ──────────────────────────────────────────────────────────

  Widget _buildReferralCode(
    DiscountDetailsEntity? discount,
    bool isProcessing,
    String? seasonalId,
  ) {
    final l10n = context.bssSubL10n;
    final bool isApplied =
        _appliedReferralCode != null &&
        discount != null &&
        discount.appliedRules.any(
          (r) =>
              r.ruleId.contains('REF') ||
              r.ruleName.toLowerCase().contains('referral'),
        );

    return _whiteCard(
      padding: EdgeInsets.all(15.w),
      borderColor: AppColor.kSlate100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.referralCodeLabel,
            style: _textStyle(
              16,
              FontWeight.w600,
              AppColor.kTextSecondaryDark,
              height: 1.3,
            ),
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Expanded(
                // Design: input ~37 tall, px 15, radius 12.
                child: Container(
                  height: 37.h,
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColor.kTotalDivider),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _referralController,
                    enabled: !isProcessing,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: l10n.referralCodeOptionalHint,
                      hintStyle: _textStyle(
                        10,
                        FontWeight.w500,
                        AppColor.kSlate400,
                        letterSpacing: 0.3,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: _textStyle(
                      13,
                      FontWeight.w600,
                      AppColor.kTextSecondaryDark,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              SizedBox(
                height: 36.h,
                child: SecondaryButton(
                  label: l10n.apply,
                  borderRadius: 12,
                  height: 36.h,
                  isLoading: isProcessing,
                  loaderSize: 14,
                  backgroundColor: AppColor.kPrimary5,
                  borderColor: AppColor.kPrimaryColor.withValues(alpha: 0.3),
                  foregroundColor: AppColor.kPrimaryColor,
                  textStyle: _textStyle(
                    12,
                    FontWeight.w700,
                    AppColor.kPrimaryColor,
                    height: 1.33,
                  ),
                  onClicked: () {
                    FocusScope.of(context).unfocus();
                    final code = _referralController.text.trim();
                    setState(() => _appliedReferralCode = code);
                    _discountBloc.add(
                      FetchTopUpDiscount(
                        packageId: widget.package.id,
                        seasonId: seasonalId,
                        referral: code.isNotEmpty,
                        referralCode: code,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          if (isApplied) ...[
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColor.kMintGreenBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppColor.kForestGreen,
                    size: 16,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      l10n.referralCodeApplied,
                      style: _textStyle(
                        11,
                        FontWeight.w500,
                        AppColor.kForestGreen,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _appliedReferralCode = null;
                        _referralController.clear();
                      });
                      _discountBloc.add(
                        FetchTopUpDiscount(
                          packageId: widget.package.id,
                          seasonId: seasonalId,
                          referral: false,
                          referralCode: '',
                        ),
                      );
                    },
                    child: Text(
                      l10n.remove,
                      style: _textStyle(
                        11,
                        FontWeight.w600,
                        AppColor.kCrimsonRed,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Payment gateways ───────────────────────────────────────────────────────

  Widget _buildPaymentGateways(
    DiscountState state,
    DiscountDetailsEntity? discount,
    double finalAmount,
  ) {
    final l10n = context.bssSubL10n;
    final walletAvailable = discount?.walletEligible ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Design: heading inset 4 like the section labels, 12 above content.
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            l10n.selectPaymentGateway,
            style: _textStyle(
              16,
              FontWeight.w600,
              AppColor.kTextSecondaryDark,
              height: 1.3,
            ),
          ),
        ),
        SizedBox(height: 12.h),
        if (walletAvailable) ...[
          _sectionLabel(l10n.walletCaps),
          SizedBox(height: 6.h),
          _buildWalletOption(discount!.walletBalance ?? 0, finalAmount),
          SizedBox(height: 16.h),
          _sectionLabel(l10n.orPayViaGateway),
          SizedBox(height: 6.h),
        ],
        _buildGatewayOptions(state),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Text(
        text,
        style: _textStyle(
          12,
          FontWeight.w600,
          AppColor.kTagGreyText, // #7B7B7B in the design

          height: 1.25,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildWalletOption(double walletBalance, double finalAmount) {
    final l10n = context.bssSubL10n;
    final sufficient = walletBalance >= finalAmount;
    final isSelected = _useWallet && sufficient;

    return _selectableCard(
      isSelected: isSelected,
      // Only one method can be used: picking the wallet clears the gateway.
      // A wallet that can't cover the amount can't be chosen.
      onTap:
          sufficient
              ? () => setState(() {
                _useWallet = true;
                _selectedGateway = '';
              })
              : null,
      child: Row(
        children: [
          _radio(isSelected),
          SizedBox(width: 13.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.myWallet,
                  style: _textStyle(
                    14,
                    FontWeight.w600,
                    AppColor.kTextSecondaryDark,
                    height: 1.3,
                  ),
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${l10n.balanceLabel} ',
                        style: _textStyle(
                          11,
                          FontWeight.w500,
                          AppColor.kSlate500,
                          height: 1.5,
                        ),
                      ),
                      TextSpan(
                        text: _currency.format(walletBalance),
                        style: _textStyle(
                          11,
                          FontWeight.w600,
                          AppColor.kSlate800,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _pill(
            color:
                sufficient ? AppColor.kDiscountGreenBg : AppColor.kStatusFailBg,
            border: Border.all(
              color:
                  sufficient
                      ? AppColor.kSufficientBorder
                      : AppColor.kStatusFailRed.withValues(alpha: 0.2),
            ),
            padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.h),
            child: Text(
              sufficient ? l10n.sufficient : l10n.insufficient,
              style: _textStyle(
                10,
                FontWeight.w500,
                sufficient ? AppColor.kDiscountGreen : AppColor.kStatusFailRed,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGatewayOptions(DiscountState state) {
    switch (state.gatewayStatus) {
      case GatewayStatus.initial:
      case GatewayStatus.loading:
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 24.h),
          child: const Center(child: CircularProgressIndicator()),
        );
      case GatewayStatus.error:
        return SizedBox(
          height: 220.h,
          child: RetryWidget(
            errorMessage: context.bssSubL10n.failedToLoadTapToRetry,
            onRetry: () => _discountBloc.add(const LoadPaymentGateways()),
          ),
        );
      case GatewayStatus.loaded:
        final gateways = state.gateways;
        // Two cards per row, as in the design.
        return Column(
          children: [
            for (var i = 0; i < gateways.length; i += 2) ...[
              if (i > 0) SizedBox(height: 12.h),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: _buildGatewayCard(gateways[i])),
                    SizedBox(width: 12.w),
                    Expanded(
                      child:
                          i + 1 < gateways.length
                              ? _buildGatewayCard(gateways[i + 1])
                              : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
    }
  }

  Widget _buildGatewayCard(PaymentGatewayEntity gateway) {
    final isSelected = _selectedGateway == gateway.name;
    final description = _gatewayDescription(gateway);

    return _selectableCard(
      isSelected: isSelected,
      // Only one method can be used: picking a gateway clears the wallet.
      onTap:
          () => setState(() {
            _selectedGateway = gateway.name;
            _useWallet = false;
          }),
      // Design: radio on top, logo (24, py 4) 8 below it, name 2 below logo.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _radio(isSelected),
          SizedBox(height: 12.h),
          _gatewayLogo(gateway),
          SizedBox(height: 6.h),
          Text(
            gateway.name,
            style: _textStyle(
              14,
              FontWeight.w600,
              AppColor.kTextSecondaryDark,
              height: 1.3,
            ),
          ),
          // Design uses Plus Jakarta Sans Medium 8 / line 16.5.
          if (description != null)
            Text(
              description,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 8.sp,
                fontWeight: FontWeight.w500,
                color: AppColor.kSlate500,
                height: 16.5 / 8,
              ),
            ),
        ],
      ),
    );
  }

  String? _gatewayDescription(PaymentGatewayEntity gateway) {
    final key = '${gateway.code} ${gateway.name}'.toLowerCase();
    if (key.contains('atom')) return context.bssSubL10n.atomPayDescription;
    if (key.contains('razor')) return context.bssSubL10n.razorpayDescription;
    return null;
  }

  // Supports URLs from the API with a bundled-asset fallback by name.
  Widget _gatewayLogo(PaymentGatewayEntity gateway) {
    final fallback = Image.asset(
      'assets/images/${gateway.name.toLowerCase()}.png',
      height: 24.h,
      fit: BoxFit.contain,
      alignment: Alignment.centerLeft,
      errorBuilder:
          (_, __, ___) => Align(
            alignment: Alignment.centerLeft,
            child: Icon(
              Icons.payment,
              size: 24.sp,
              color: AppColor.kDisabledGrey,
            ),
          ),
    );
    if (!gateway.icon.startsWith('http')) return fallback;
    return Image.network(
      gateway.icon,
      height: 24.h,
      fit: BoxFit.contain,
      alignment: Alignment.centerLeft,
      errorBuilder: (_, __, ___) => fallback,
    );
  }

  /// [onTap] null = option unavailable (shown dimmed, not tappable).
  Widget _selectableCard({
    required bool isSelected,
    required VoidCallback? onTap,
    required Widget child,
  }) {
    final primary = AppColor.kPrimaryColor;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: onTap == null ? 0.5 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          // Design: content 16 inside the border either way (selected border
          // is 2, unselected 1).
          padding: EdgeInsets.all(isSelected ? 16.w : 15.w),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? Color.lerp(Colors.white, primary, 0.03)
                    : Colors.white,
            border: Border.all(
              color: isSelected ? primary : AppColor.kCardBorderBeige,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                    : null,
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _radio(bool isSelected) {
    final primary = AppColor.kPrimaryColor;
    return Container(
      width: 16.w,
      height: 16.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? primary : AppColor.kSlate300,
          width: isSelected ? 2 : 1,
        ),
      ),
      alignment: Alignment.center,
      child:
          isSelected
              ? Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary,
                ),
              )
              : null,
    );
  }

  // ── Secure note, terms and agreement ──────────────────────────────────────

  Widget _buildSecureNote() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColor.kSecureNoteBg,
        border: Border.all(color: AppColor.kSecureNoteBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 28.w,
            height: 28.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColor.kSecureIconBg,
            ),
            child: Icon(
              Icons.verified_user_outlined,
              size: 16.sp,
              color: AppColor.kEmeraldGreen,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              context.bssSubL10n.paymentSecureNote,
              style: _textStyle(
                11,
                FontWeight.w500,
                AppColor.kSecureNoteText,
                height: 1.38,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsAndConditions() {
    final l10n = context.bssSubL10n;
    return Container(
      height: 112.h,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.70),
        border: Border.all(color: AppColor.kCardBorderBeige),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Scrollbar(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.termsAndConditionsTitle,
                style: _textStyle(
                  16,
                  FontWeight.w600,
                  AppColor.kTextSecondaryDark,
                  height: 1.3,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                l10n.termsAndConditionsText,
                style: _textStyle(
                  10,
                  FontWeight.w400,
                  AppColor.kSlate600,
                  height: 17.88 / 10,
                ),
              ),
              SizedBox(height: 20.h),
              // Design uses Plus Jakarta Sans for the privacy block.
              Text(
                l10n.privacyPolicyCaps,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColor.kSlate800,
                  height: 1.5,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                l10n.privacyPolicyText,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColor.kSlate600,
                  height: 17.88 / 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAgreeCheckbox() {
    final primary = AppColor.kPrimaryColor;
    return InkWell(
      onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: EdgeInsets.fromLTRB(3.w, 3.h, 0, 3.h),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 18.w,
              height: 18.w,
              decoration: BoxDecoration(
                color: _agreedToTerms ? primary : Colors.white,
                border: Border.all(
                  color: _agreedToTerms ? primary : AppColor.kSlate300,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child:
                  _agreedToTerms
                      ? Icon(Icons.check, size: 16.sp, color: Colors.white)
                      : null,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                context.bssSubL10n.agreeToTerms,
                style: _textStyle(
                  12,
                  FontWeight.w500,
                  AppColor.kSlate700,
                  height: 1.33,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _backToMainPage(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  /// [txnId] is null for wallet payments, which have no gateway transaction.
  void _showTopUpSuccessDialog(
    BuildContext context, {
    required double amount,
    String? txnId,
  }) {
    final l10n = context.bssSubL10n;
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: _backdropColor,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 30),
          child: Container(
            decoration: _dialogContainerDecoration,
            // Design: 316 wide; content 24 from the sides, 27 from the top.
            padding: EdgeInsets.fromLTRB(24.w, 27.h, 24.w, 25.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  AppAssets.topUpSuccessfull,
                  width: 100.w,
                  height: 100.w,
                ),
                SizedBox(height: 26.h),
                Text(
                  l10n.rechargeSuccessful,
                  style: TextStyle(
                    color: AppColor.kTextSecondaryDark,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                    fontFamily: 'GeneralSans',
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  l10n.rechargeSuccessMessage(amount.toStringAsFixed(2)),
                  style: TextStyle(
                    color: AppColor.kDarkBlue,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.54,
                    fontFamily: 'GeneralSans',
                  ),
                  textAlign: TextAlign.center,
                ),
                if (txnId != null && txnId.isNotEmpty) ...[
                  SizedBox(height: 18.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    height: 1.h,
                    child: CustomPaint(painter: _dashedPainter),
                  ),
                  SizedBox(height: 18.h),
                  Text(
                    l10n.transactionId(txnId),
                    style: TextStyle(
                      color: AppColor.kDarkBlue,
                      fontSize: 14.sp,
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w500,
                      height: 1.43,
                    ),
                  ),
                ],
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: PrimaryButton(
                    label: l10n.ok,
                    isLoading: false,
                    borderRadius: 10,
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                      fontFamily: 'GeneralSans',
                    ),
                    onClicked: () => _backToMainPage(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTopUpFailDialog(double amount, BuildContext context) {
    final l10n = context.bssSubL10n;

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: _backdropColor,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 30),
          child: Container(
            decoration: _dialogContainerDecoration,
            // Design: 316 wide; content 24 from the sides, 27 from the top.
            padding: EdgeInsets.fromLTRB(24.w, 27.h, 24.w, 25.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  AppAssets.topUpFail,
                  width: 100.w,
                  height: 100.w,
                ),
                SizedBox(height: 26.h),
                Text(
                  l10n.rechargeFailed,
                  style: TextStyle(
                    color: AppColor.kTextSecondaryDark,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                    fontFamily: 'GeneralSans',
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  l10n.rechargeFailedMessage(amount.toStringAsFixed(2)),
                  style: TextStyle(
                    color: AppColor.kDarkBlue,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.54,
                    fontFamily: 'GeneralSans',
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 13.h),
                Text(
                  l10n.topUpFailedRetryMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColor.kDarkBlue,
                    fontSize: 13.sp,
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w500,
                    height: 1.54,
                  ),
                ),
                SizedBox(height: 18.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  height: 1.h,
                  child: CustomPaint(painter: _dashedPainter),
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: PrimaryButton(
                    label: l10n.ok,
                    isLoading: false,
                    borderRadius: 10,
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                      fontFamily: 'GeneralSans',
                    ),
                    onClicked: () => _backToMainPage(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
