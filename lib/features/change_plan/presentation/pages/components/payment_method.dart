import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/bloc/discount_bloc.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/bloc/discount_state.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/shared/widgets/primary_button.dart';

class PaymentMethodSheet extends StatefulWidget {
  final Function(String gateway,bool useWallet) onNext;
  final bool offlinePaymentAvailable;
  final double walletBalance;
  final double finalAmount;

  const PaymentMethodSheet({
    super.key,
    required this.onNext,
    required this.offlinePaymentAvailable,
    required this.walletBalance,
    required this.finalAmount,
  });

  @override
  State<PaymentMethodSheet> createState() => _PaymentMethodSheetState();
}

class _PaymentMethodSheetState extends State<PaymentMethodSheet> {
  String _selected = '';
  bool _useWallet = false;
  late List<PaymentMethod> _methods;

  // ── Static decorations ───────────────────────────────────────────────────────
  static const _sheetDecoration = BoxDecoration(
    color: AppColor.kWarmBackground,
    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
  );
  static const _handleDecoration = BoxDecoration(
    color: AppColor.kDisabledGrey,
    borderRadius: BorderRadius.all(Radius.circular(2)),
  );

  // Sizer.sp is fixed after MaterialApp.builder — computed once as static final.
  static final _titleStyle = TextStyle(
    fontSize: 16.sp,
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w600,
    height: 1.30,
    color: Colors.black,
  );

  @override
  void initState() {
    super.initState();
    // if (_useWallet && !isWalletSufficient) {
    //   _selected = 'HDFC';
    // }
    _methods = [
      const PaymentMethod(name: 'HDFC', logo: 'assets/images/hdfc_logo.png'),
      const PaymentMethod(name: 'IKM', logo: 'assets/images/ikm_logo.png'),
    ];

    if (widget.offlinePaymentAvailable) {
      _methods.add(
        const PaymentMethod(
          name: 'Wallet',
          logo: 'assets/images/hdfc_logo.png',
        ),
      );
    }
  }

  bool get isWalletSufficient => widget.walletBalance >= widget.finalAmount;

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;

    return Container(
      decoration: _sheetDecoration,
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 28.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: _handleDecoration,
            ),
          ),
          SizedBox(height: 20.h),

          Text(l10n.paymentMethod, style: _titleStyle),
          SizedBox(height: 16.h),

          // Payment options — extracted to StatelessWidget for identity tracking.
          ..._methods.map(
            (m) => _PaymentOption(
              method: m,
              isSelected: m.name == 'Wallet' ? _useWallet : _selected == m.name,
              onTap: () {
                if (m.name == 'Wallet') {
                  setState(() => _useWallet = !_useWallet);
                } else {
                  setState(() => _selected = m.name);
                }
              },
            ),
          ),

          SizedBox(height: 40),

          BlocBuilder<DiscountBloc, DiscountState>(
            buildWhen:
                (previous, current) =>
                    current.status == RechargeStatus.orderSummerySuccess ||
                    current.status == RechargeStatus.paymentRedirectLoading ||
                    (current.status == RechargeStatus.error &&
                        previous.status == RechargeStatus.orderSummerySuccess),
            builder: (context, state) {
              return PrimaryButton(
                label: l10n.next,
                isLoading:
                    state.status == RechargeStatus.paymentRedirectLoading,
                onClicked: () {
                  if (_selected.isEmpty && !_useWallet) {
                    return;
                  } else if (_useWallet &&
                      !isWalletSufficient &&
                      _selected.isEmpty) {
                    DialogUtil().showOKWithAction(
                      onConfirmation: () => Navigator.of(context).pop(),
                      content:
                          'Insufficient wallet balance. ₹${(widget.finalAmount - widget.walletBalance).toStringAsFixed(2)} will be charged online. Please select an online payment method also.',
                      context: context,
                    );
                  } else{
                    widget.onNext(_selected,_useWallet);
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Payment option card ───────────────────────────────────────────────────────
// Extracted from _buildOption helper method so Flutter can track identity
// and skip rebuilds when isSelected has not changed.
class _PaymentOption extends StatelessWidget {
  final PaymentMethod method;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  // 0x0A = 10 ≈ 0.04 × 255 → Colors.black @ 4% opacity
  static const _cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(14)),
    boxShadow: [
      BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
    ],
  );
  static const _logoDecoration = ShapeDecoration(
    color: Colors.white,
    shape: RoundedRectangleBorder(
      side: BorderSide(width: 1, color: AppColor.kBorderLightGrey),
      borderRadius: BorderRadius.all(Radius.circular(6)),
    ),
  );
  static const _selectedRadioDecoration = BoxDecoration(
    shape: BoxShape.circle,
    color: AppColor.kPrimaryColor,
  );

  // Border.fromBorderSide has a const constructor; Border.all does not.
  static const _unselectedRadioDecoration = BoxDecoration(
    shape: BoxShape.circle,
    color: Colors.transparent,
    border: Border.fromBorderSide(
      BorderSide(color: AppColor.kDisabledGrey, width: 1.5),
    ),
  );
  static const _centerDotDecoration = BoxDecoration(
    color: Colors.white,
    shape: BoxShape.circle,
  );
  static final _methodNameStyle = TextStyle(
    fontSize: 15.sp,
    fontWeight: FontWeight.w600,
    color: AppColor.kRichBlack,
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: _cardDecoration,
        child: Row(
          children: [
            Container(
              width: 46.w,
              height: 46.h,
              padding: const EdgeInsets.all(5),
              decoration: _logoDecoration,
              child: Image.asset(method.logo),
            ),
            SizedBox(width: 16.w),
            Expanded(child: Text(method.name, style: _methodNameStyle)),
            Container(
              width: 20.w,
              height: 20.w,
              decoration:
                  isSelected
                      ? _selectedRadioDecoration
                      : _unselectedRadioDecoration,
              child:
                  isSelected
                      ? Center(
                        child: Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: _centerDotDecoration,
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
