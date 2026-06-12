import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/painter/dashed_border_painter.dart';
import 'package:kfon_subscriber/core/painter/dashed_line_painter.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/discount_details_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/package_new_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/recharge_payment_status_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/params/recharge_change_plan_params.dart';
import 'package:kfon_subscriber/features/change_plan/domain/repository/change_plan_repository.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/bloc/discount_bloc.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/bloc/discount_event.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/bloc/discount_state.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/pages/components/payment_method.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/pages/payment_webview_page.dart';
import 'package:kfon_subscriber/features/home/presentation/bloc/home_bloc.dart';
import 'package:kfon_subscriber/features/home/presentation/bloc/home_event.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/service_locator.dart';
import 'package:kfon_subscriber/shared/widgets/common_app_bar.dart';
import 'package:kfon_subscriber/shared/widgets/primary_button.dart';
import 'package:kfon_subscriber/shared/widgets/shimmer/list_shimmers.dart';

class RechargePage extends StatefulWidget {
  final PackageInfoEntity package;
  final String? referralCode;

  const RechargePage({super.key, required this.package, this.referralCode});

  @override
  State<RechargePage> createState() => _RechargePageState();
}

class _RechargePageState extends State<RechargePage> {
  String? _appliedReferralCode;
  late TextEditingController _referralController;
  static const _backdropColor = Color(0x80000000);
  static const _dialogContainerDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(20)),
  );
  late DiscountBloc _discountBloc;

  // ElevatedButton.styleFrom() is not const — computed once as static final.
  static final _dialogButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColor.kPrimaryColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
  );
  static final _dashedPainter = DashedLinePainter(
    color: const Color(0x1A000000),
    strokeWidth: 1,
  );

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
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      PaymentWebViewPage(redirectEntity: state.redirectEntity!),
            ),
          ).then((result) {
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
              DialogUtil().showCustomSnackbar(
                context: context,
                content: l10n.rechargePaymentCancelled,
                backgroundColor: AppColor.kPendingOrange,
              );
            }
          });
        } else if (state.status == RechargeStatus.paymentSuccess &&
            state.paymentStatusEntity != null) {
          context.read<HomeBloc>().add(const GetHomeData(loadPackage: false));
          _showTopUpSuccessDialog(state.paymentStatusEntity!, context);
        } else if (state.status == RechargeStatus.error ||
            state.status == RechargeStatus.paymentFailed) {
          if (state.status == RechargeStatus.paymentFailed) {
            Navigator.of(context).pop();
          }
          DialogUtil().showCustomSnackbar(
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
          title: context.bssSubL10n.orderSummary,
          scaffoldColor: const Color(0xFFF2EFE7),
          onBackPressed: () {
            Navigator.of(context).pop();
          },
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 20.0,
                          ),
                          children: [
                            if (discount != null &&
                                discount.appliedRules.isNotEmpty)
                              _buildDiscountBanner(discount),

                            _buildPackageDetails(discount),
                            _buildReferralCode(
                              discount,
                              state.status ==
                                  RechargeStatus.referralCodeLoading,
                              seasonalId,
                            ),
                            _buildPriceBreakdown(
                              discount,
                              calculatedFinalAmount,
                            ),
                            _buildBillingDetails(discount),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: PrimaryButton(
                          label: context.bssSubL10n.confirmAndPay(
                            "₹${calculatedFinalAmount.toStringAsFixed(2)}",
                          ),
                          isLoading: false,
                          onClicked:
                              () => _showPaymentMethodSheet(
                                context,
                                offlinePaymentAvailable:
                                    state.discountDetail!.walletEligible!,
                                finalAmount: state.discountDetail!.finalAmount,
                                walletBalance:
                                    state.discountDetail!.walletBalance!,
                                onNext: (gateway, useWallet) async {
                                  if (context.mounted) {
                                    _discountBloc.add(
                                      RechargeChangePlan(
                                        params: RechargeChangePlanParams(
                                          packageId: widget.package.id,
                                          gateway: gateway,
                                          amount: widget.package.renewalFee,
                                          durationDays:
                                              widget.package.renewPeriod,
                                          expectedFinalAmount:
                                              calculatedFinalAmount,
                                          seasonId: seasonalId,
                                          referral:
                                              _appliedReferralCode != null,
                                          useWallet: useWallet,
                                          advanceRecharge: '',
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                        ),
                      ),
                    ],
                  ),
        );
      },
    );
  }

  void _showPaymentMethodSheet(
    BuildContext context, {
    required Function(String gateway, bool useWallet) onNext,
    required bool offlinePaymentAvailable,
    required double walletBalance,
    required double finalAmount,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (_) => BlocProvider.value(
            value: _discountBloc,
            child: PaymentMethodSheet(
              onNext: (gateway, useWallet) => onNext(gateway, useWallet),
              offlinePaymentAvailable: offlinePaymentAvailable,
              finalAmount: finalAmount,
              walletBalance: walletBalance,
            ),
          ),
    );
  }

  void _showTopUpSuccessDialog(
    RechargePaymentStatusEntity paymentStatus,
    BuildContext context,
  ) {
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
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/images/top-up_successfull.svg',
                  width: 80.w,
                  height: 80.h,
                ),
                const SizedBox(height: 26),
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
                const SizedBox(height: 12),
                Text(
                  l10n.rechargeSuccessMessage(
                    paymentStatus.amount.toStringAsFixed(2),
                  ),
                  style: TextStyle(
                    color: AppColor.kDarkBlue,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.54,
                    fontFamily: 'GeneralSans',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  height: 1,
                  child: CustomPaint(painter: _dashedPainter),
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.transactionId(paymentStatus.txnId),
                  style: TextStyle(
                    color: AppColor.kDarkBlue,
                    fontSize: 14.sp,
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w500,
                    height: 1.43,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    style: _dialogButtonStyle,
                    child: Text(
                      l10n.ok,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                        fontFamily: 'GeneralSans',
                      ),
                    ),
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
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/images/top-up_fail.svg',
                  width: 80.w,
                  height: 80.h,
                ),
                const SizedBox(height: 26),
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
                const SizedBox(height: 12),
                Text(
                  l10n.rechargeFailedMessage,
                  style: TextStyle(
                    color: AppColor.kDarkBlue,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.54,
                    fontFamily: 'GeneralSans',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 13),
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
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  height: 1,
                  child: CustomPaint(painter: _dashedPainter),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    style: _dialogButtonStyle,
                    child: Text(
                      l10n.ok,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                        fontFamily: 'GeneralSans',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReferralCode(
    DiscountDetailsEntity? discount,
    bool isProcessing,
    String? seasonalId,
  ) {
    // Check if any rule in the discount is a referral rule.
    // For now, we'll assume if _appliedReferralCode is set and discount is not null, it's applied.
    final bool isApplied =
        _appliedReferralCode != null &&
        discount != null &&
        discount.appliedRules.any(
          (r) =>
              r.ruleId.contains('REF') ||
              r.ruleName.toLowerCase().contains('referral'),
        );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.bssSubL10n.referralCodeLabel,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
              height: 1.3,
              letterSpacing: 0,
              fontFamily: 'GeneralSans',
              color: AppColor.kTextSecondaryDark,
            ),
          ),
          const SizedBox(height: 12),
          CustomPaint(
            painter: DashedBorderPainter(
              color: Colors.grey.shade400,
              radius: 12,
              strokeWidth: 1,
            ),
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2EFE7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          height: 40.h,
                          alignment: Alignment.centerLeft,
                          child: TextField(
                            controller: _referralController,
                            enabled: !isProcessing,
                            decoration: InputDecoration(
                              hintText: context.bssSubL10n.referralCodeHint,
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w400,
                                height: 1.0,
                                letterSpacing: 0.5,
                                fontFamily: 'GeneralSans',
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                              fontFamily: 'GeneralSans',
                              color: AppColor.kTextSecondaryDark,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        height: 40.h,
                        child: ElevatedButton(
                          onPressed:
                              isProcessing
                                  ? null
                                  : () {
                                    FocusScope.of(context).unfocus();
                                    final code =
                                        _referralController.text.trim();
                                    setState(() {
                                      _appliedReferralCode = code;
                                    });
                                    _discountBloc.add(
                                      FetchTopUpDiscount(
                                        packageId: widget.package.id,
                                        seasonId: seasonalId,
                                        referral: code.isNotEmpty,
                                        referralCode: code,
                                      ),
                                    );
                                  },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8D0247),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 0,
                            ),
                            elevation: 0,
                          ),
                          child:
                              isProcessing
                                  ? SizedBox(
                                    width: 14.w,
                                    height: 14.h,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : Text(
                                    context.bssSubL10n.apply,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12.sp,
                                      height: 1.0,
                                      letterSpacing: 0,
                                      fontFamily: 'GeneralSans',
                                    ),
                                  ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, top: 12, bottom: 4),
                    child: Text(
                      context.bssSubL10n.referralHelperText,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w400,
                        height: 1.0,
                        letterSpacing: 0,
                        fontFamily: 'GeneralSans',
                      ),
                    ),
                  ),
                  if (isApplied) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F4EA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF1E8E3E),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              context.bssSubL10n.referralCodeApplied,
                              style: TextStyle(
                                color: Color(0xFF1E8E3E),
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'GeneralSans',
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
                              context.bssSubL10n.remove,
                              style: TextStyle(
                                color: Color(0xFFD93025),
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'GeneralSans',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown(
    DiscountDetailsEntity? discount,
    num calculatedFinalAmount,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.bssSubL10n.priceBreakdown,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
              height: 1.3,
              letterSpacing: 0,
              fontFamily: 'GeneralSans',
              color: AppColor.kTextSecondaryDark,
            ),
          ),
          const SizedBox(height: 16),
          _buildRow(
            context.bssSubL10n.packageBreakdownLabel(
              widget.package.packageName,
            ),
            "₹${discount?.packageFee ?? widget.package.renewalFee}",
            isBold: false,
          ),
          if (discount != null && discount.appliedRules.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: Color(0xFFF2EFE7), height: 1, thickness: 1),
            ),
            ...discount.appliedRules.map(
              (rule) => Padding(
                padding: const EdgeInsets.only(bottom: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.bssSubL10n.seasonDiscount,
                          style: TextStyle(
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.w500,
                            fontSize: 12.sp,
                            height: 1.0,
                            letterSpacing: 0,
                            fontFamily: 'GeneralSans',
                          ),
                        ),
                        Text(
                          "-₹${rule.discountAmount.toStringAsFixed(2)}",
                          style: TextStyle(
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.w600,
                            fontSize: 12.5.sp,
                            height: 1.0,
                            letterSpacing: 0,
                            fontFamily: 'GeneralSans',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.bssSubL10n.seasonDiscountRule(
                        rule.ruleName,
                        rule.discountValue.toString(),
                      ),
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w400,
                        height: 1.0,
                        letterSpacing: 0,
                        fontFamily: 'GeneralSans',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Color(0xFFF2EFE7), height: 1, thickness: 1),
          ),
          _buildRow(
            context.bssSubL10n.gstLabel,
            "₹${discount?.gstAmount ?? 0}",
            isBold: false,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Color(0xFFF2EFE7), height: 1, thickness: 1),
          ),
          _buildRow(
            context.bssSubL10n.totalPayable,
            "₹${calculatedFinalAmount.toStringAsFixed(2)}",
            isBold: true,
            valueColor: const Color(0xFF8D0247),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: isBold ? AppColor.kTextSecondaryDark : Colors.grey[700],
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              fontSize: isBold ? 14.sp : 12.sp,
              height: 1.0,
              letterSpacing: 0,
              fontFamily: isBold ? 'Sora' : 'GeneralSans',
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppColor.kTextSecondaryDark,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w600,
            fontSize: isBold ? 16.sp : 12.5.sp,
            height: 1.0,
            letterSpacing: 0,
            fontFamily: 'GeneralSans',
          ),
        ),
      ],
    );
  }

  Widget _buildBillingDetails(DiscountDetailsEntity? discount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.bssSubL10n.billingDetails,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
              height: 1.3,
              letterSpacing: 0,
              fontFamily: 'GeneralSans',
              color: AppColor.kTextSecondaryDark,
            ),
          ),
          const SizedBox(height: 16),
          _buildBillingRow(
            context.bssSubL10n.paymentMode,
            discount?.paymentMode ?? "-",
          ),
          _buildBillingRow(
            context.bssSubL10n.location,
            discount?.location ?? "-",
          ),
          _buildBillingRow(
            context.bssSubL10n.subscriberCategory,
            discount?.subscriberCategory ?? "-",
          ),
          _buildBillingRow(
            context.bssSubL10n.subPackage,
            discount?.subPackage ?? "-",
          ),
          _buildBillingRow(
            context.bssSubL10n.rechargeDays,
            '${discount?.validity ?? "-"}',
          ),
        ],
      ),
    );
  }

  Widget _buildBillingRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              height: 1.0,
              letterSpacing: 0,
              fontFamily: 'GeneralSans',
            ),
          ),
          Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: AppColor.kTextSecondaryDark,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              height: 1.0,
              letterSpacing: 0,
              fontFamily: 'GeneralSans',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountBanner(DiscountDetailsEntity discount) {
    final rule = discount.appliedRules.first;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6),
        border: Border.all(color: const Color(0xFFFFD54F), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.wb_sunny_rounded, color: Colors.orange, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.bssSubL10n.discountAppliedHeader(
                    rule.ruleName,
                    rule.discountValue.toString(),
                  ),
                  style: TextStyle(
                    color: Color(0xFF92400E),
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                    height: 1.0,
                    letterSpacing: 0,
                    fontFamily: 'GeneralSans',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.bssSubL10n.discountAppliedSubtitle,
                  style: TextStyle(
                    color: Color(0xFFB45309),
                    fontWeight: FontWeight.w400,
                    fontSize: 10.sp,
                    height: 1.0,
                    letterSpacing: 0,
                    fontFamily: 'GeneralSans',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageDetails(DiscountDetailsEntity? discount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.bssSubL10n.packageDetails,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
              height: 1.3,
              letterSpacing: 0,
              fontFamily: 'GeneralSans',
              color: AppColor.kTextSecondaryDark,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F7FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.language, color: Colors.blueAccent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.package.packageName,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14.sp,
                        height: 1.3,
                        letterSpacing: 0,
                        fontFamily: 'GeneralSans',
                        color: AppColor.kTextSecondaryDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${discount?.category ?? '-'} · ${discount?.connectionType ?? '-'}",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.0,
                        letterSpacing: 0.2,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (discount != null && (discount.totalDiscount) > 0) ...[
                    Text(
                      "₹${discount.packageFee}",
                      style: TextStyle(
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: Colors.grey,
                        fontSize: 10.5.sp,
                        height: 1.0,
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF97316),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "₹${discount.discountedFee}",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                          height: 1.3,
                          letterSpacing: 0,
                          fontFamily: 'GeneralSans',
                        ),
                      ),
                    ),
                  ] else
                    Text(
                      "₹${discount?.packageFee ?? widget.package.renewalFee}",
                      style: TextStyle(
                        color: AppColor.kTextSecondaryDark,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                        height: 1.3,
                        letterSpacing: 0,
                        fontFamily: 'GeneralSans',
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatColumn(
                  context.bssSubL10n.speed,
                  '${discount?.speed ?? "-"}',
                ),
                _buildStatColumn(
                  context.bssSubL10n.validity,
                  '${discount?.validity ?? "-"}',
                ),
                _buildStatColumn(
                  context.bssSubL10n.volume,
                  discount?.volume ?? "-",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 10.sp,
            fontWeight: FontWeight.w400,
            height: 1.3,
            letterSpacing: 0,
            fontFamily: 'GeneralSans',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: AppColor.kTextSecondaryDark,
            fontWeight: FontWeight.w500,
            fontSize: 14.sp,
            height: 1.3,
            letterSpacing: 0,
            fontFamily: 'GeneralSans',
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _referralController = TextEditingController(
      text: widget.referralCode ?? '',
    );
    _discountBloc = DiscountBloc(repository: sl<ChangePlanRepository>());
    _discountBloc.add(GetSeasonalId(packageId: widget.package.id));
  }

  @override
  void dispose() {
    _referralController.dispose();
    _discountBloc.close();
    super.dispose();
  }
}
