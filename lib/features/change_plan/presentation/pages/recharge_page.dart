import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/package_entity.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/pages/components/plan_tile.dart';
import 'package:kfon_subscriber/painter/dashed_line_painter.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_app_bar.dart';
import 'package:kfon_subscriber/presentation/ui_component/primary_button.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/core/util/preference_util.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/bloc/change_plan_bloc.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/bloc/change_plan_event.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/bloc/change_plan_state.dart';
import 'package:kfon_subscriber/features/change_plan/domain/params/recharge_change_plan_params.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/pages/payment_webview_page.dart';

class RechargePage extends StatelessWidget {
  final PackageEntity package;

  RechargePage({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    return CommonAppBar(
      title: 'Recharge',
      onBackPressed: () => Navigator.pop(context),
      appbarColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      circleColor: Colors.white,
      titleColor: Colors.white,
      body: BlocConsumer<ChangePlanBloc, ChangePlanState>(
        listenWhen:
            (previous, current) =>
                previous.actionStatus != current.actionStatus,
        listener: (context, state) {
          if (state.actionStatus == ActionStatus.success &&
              state.redirectEntity != null) {
            Navigator.pop(context); // Close PaymentMethodSheet if open
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => PaymentWebViewPage(
                      redirectEntity: state.redirectEntity!,
                    ),
              ),
            ).then((result) {
              if (result == PaymentResult.success) {
                _showTopUpSuccessDialog(package.price, context);
              } else if (result == PaymentResult.failed) {
                _showTopUpFailDialog(package.price, context);
              }
            });
          } else if (state.actionStatus == ActionStatus.error) {
            Navigator.pop(context); // Close PaymentMethodSheet if open
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Recharge failed: ${state.errorMessage}')),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              SizedBox(
                width: double.infinity,
                height: 200.h,
                child: SvgPicture.asset(
                  'assets/images/speed_test_background.svg',
                  fit: BoxFit.fill,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 140,
                  bottom: 20,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PlanTile(package: package, isSelected: false, onTap: () {}),
                    PrimaryButton(
                      label: 'Pay Now',
                      isLoading: state.actionStatus == ActionStatus.loading,
                      onClicked:
                          () => showPaymentMethodSheet(
                            context,
                            onNext: (gateway) async {
                              if (context.mounted) {
                                context.read<ChangePlanBloc>().add(
                                  RechargeChangePlan(
                                    params: RechargeChangePlanParams(
                                      packageId: package.packageId,
                                      gateway: gateway,
                                      amount: package.price,
                                      durationDays: package.validity,
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void showPaymentMethodSheet(
    BuildContext context, {
    required Function(String gateway) onNext,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (_) => BlocProvider.value(
            value: context.read<ChangePlanBloc>(),
            child: PaymentMethodSheet(
              onNext: (gateway) {
                onNext(gateway);
              },
            ),
          ),
    );
  }

  void _showTopUpSuccessDialog(double amount, BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 30),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success Icon
                SvgPicture.asset(
                  'assets/images/top-up_successfull.svg',
                  width: 80,
                  height: 80,
                ),
                const SizedBox(height: 26),
                // Title
                Text(
                  'Recharge Successful!',
                  style: TextStyle(
                    color: const Color(0xFF0F1121),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                    fontFamily: 'GeneralSans',
                  ),
                ),
                const SizedBox(height: 12),
                // Message
                Text(
                  'Your recharge of ₹500 has been completed successfully.',
                  style: TextStyle(
                    color: const Color(0xFF354259),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.54,
                    fontFamily: 'GeneralSans',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 13),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'New balance : ',
                        style: TextStyle(
                          color: const Color(0xFF354259),
                          fontSize: 13.sp,
                          fontFamily: 'General Sans',
                          fontWeight: FontWeight.w500,
                          height: 1.54,
                        ),
                      ),
                      TextSpan(
                        text: '₹1,250',
                        style: TextStyle(
                          color: AppColor.kPrimaryColor,
                          fontSize: 13.sp,
                          fontFamily: 'General Sans',
                          fontWeight: FontWeight.w600,
                          height: 1.54,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  height: 1,
                  child: CustomPaint(
                    painter: DashedLinePainter(
                      color: Colors.black.withValues(alpha: 0.1),
                      strokeWidth: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Transaction ID: TXN23456789',
                  style: TextStyle(
                    color: const Color(0xFF354259),
                    fontSize: 14,
                    fontFamily: 'General Sans',
                    fontWeight: FontWeight.w500,
                    height: 1.43,
                  ),
                ),
                const SizedBox(height: 24),
                // Ok Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context); // Go back to previous screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.kPrimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Ok',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
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
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 30),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success Icon
                SvgPicture.asset(
                  'assets/images/top-up_fail.svg',
                  width: 80,
                  height: 80,
                ),
                const SizedBox(height: 26),
                // Title
                Text(
                  'Recharge Failed',
                  style: TextStyle(
                    color: const Color(0xFF0F1121),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                    fontFamily: 'GeneralSans',
                  ),
                ),
                const SizedBox(height: 12),
                // Message
                Text(
                  'Your recharge of ₹500 could not be completed.',
                  style: TextStyle(
                    color: const Color(0xFF354259),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.54,
                    fontFamily: 'GeneralSans',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 13),
                Text(
                  'Please check your payment method or network connection and try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF354259),
                    fontSize: 13,
                    fontFamily: 'General Sans',
                    fontWeight: FontWeight.w500,
                    height: 1.54,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  height: 1,
                  child: CustomPaint(
                    painter: DashedLinePainter(
                      color: Colors.black.withValues(alpha: 0.1),
                      strokeWidth: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Ok Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context); // Go back to previous screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.kPrimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Ok',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
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
}

class PaymentMethodSheet extends StatefulWidget {
  final Function(String gateway) onNext;

  const PaymentMethodSheet({super.key, required this.onNext});

  @override
  State<PaymentMethodSheet> createState() => _PaymentMethodSheetState();
}

class _PaymentMethodSheetState extends State<PaymentMethodSheet> {
  String _selected = 'HDFC';

  final _methods = [
    PaymentMethod(name: 'HDFC', logo: 'assets/images/hdfc_logo.png'),
    PaymentMethod(name: 'IKM', logo: 'assets/images/ikm_logo.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEFEBE5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 28.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFCCCCCC),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 20.h),

          // Title
          Text(
            'Payment Method',
            style: TextStyle(
              fontSize: 16.sp,
              fontFamily: 'General Sans',
              fontWeight: FontWeight.w600,
              height: 1.30,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16.h),

          // Payment options
          ..._methods.map((m) => _buildOption(m)),

          SizedBox(height: 80.h),

          // Next button
          BlocBuilder<ChangePlanBloc, ChangePlanState>(
            builder: (context, state) {
              return PrimaryButton(
                label: 'Next',
                isLoading: state.actionStatus == ActionStatus.loading,
                onClicked: () {
                  widget.onNext(_selected);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOption(PaymentMethod method) {
    final isSelected = _selected == method.name;
    return GestureDetector(
      onTap: () => setState(() => _selected = method.name),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Logo
            Container(
              width: 46.w,
              height: 46.h,
              padding: EdgeInsets.all(5),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 1, color: const Color(0xFFD9D9D9)),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Image.asset(method.logo),
            ),
            SizedBox(width: 16.w),

            // Name
            Expanded(
              child: Text(
                method.name,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ),

            // Radio
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      isSelected
                          ? AppColor.kPrimaryColor
                          : const Color(0xFFCCCCCC),
                  width: isSelected ? 0 : 1.5,
                ),
                color: isSelected ? AppColor.kPrimaryColor : Colors.transparent,
              ),
              child:
                  isSelected
                      ? Center(
                        child: Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                      : null,
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentMethod {
  final String name;
  final String logo;

  const PaymentMethod({required this.name, required this.logo});
}
