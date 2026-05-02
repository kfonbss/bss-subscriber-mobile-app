import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/presentation/page_component/status_badge.dart';
import 'package:kfon_subscriber/shared/widgets/common_app_bar.dart';
import 'package:kfon_subscriber/shared/widgets/secondary_button.dart';

class TransactionDetailsPage extends StatelessWidget {
  const TransactionDetailsPage({super.key});

  // 0x0A = 10 ≈ 0.04 × 255 → Colors.black @ 4% opacity
  static const _cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(16)),
    boxShadow: [
      BoxShadow(
        color: Color(0x0A000000),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return CommonAppBar(
      onBackPressed: () => Navigator.pop(context),
      title: context.bssSubL10n.transactionDetailsTitle,
      body: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [_buildDetailsCard(context), _buildCloseButton(context)],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      decoration: _cardDecoration,
      child: Column(
        children: [
          _DetailRow(label: context.bssSubL10n.orderTime, value: '2025-10-03 19:35:03'),
          _DetailRow(label: context.bssSubL10n.orderAmount, value: '352.82'),
          _DetailRow(
            label: context.bssSubL10n.bssReference,
            value: 'UW9089EZ45520251015',
            valueBold: true,
          ),
          _DetailRow(
            label: context.bssSubL10n.bssStatus,
            value: '',
            isStatus: true,
            status: TransactionStatus.pending,
          ),
          _DetailRow(
            label: context.bssSubL10n.txnReference,
            value: 'UW9089EZ45520251015',
            valueBold: true,
          ),
          _DetailRow(
            label: context.bssSubL10n.responseMessage,
            value: 'Successfully completed\nand Receipt generated',
            valueBold: true,
          ),
          _DetailRow(label: context.bssSubL10n.paymentGateway, value: 'IKM', isLast: true),
        ],
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
      child: SizedBox(
        width: double.infinity,
        height: 54.h,
        child: SecondaryButton(label: context.bssSubL10n.closeButton, onClicked: () => Navigator.pop(context)),
      ),
    );
  }
}

// ── Detail Row ───────────────────────────────────────────────



class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool valueBold;
  final bool isLast;
  final bool isStatus;
  final TransactionStatus? status;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueBold = false,
    this.isLast = false,
    this.isStatus = false,
    this.status,
  });

  // Sizer-based styles — computed once as static final.
  static final _labelStyle = TextStyle(
    fontSize: 14.sp,
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w400,
    height: 1.30,
    color: Colors.black54,
  );
  static final _valueStyle = TextStyle(
    fontSize: 14.sp,
    fontFamily: 'GeneralSans',
    height: 1.30,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140.w,
            child: Text(label, style: _labelStyle),
          ),
          Expanded(
            child: isStatus
                ? Align(
                    alignment: Alignment.centerRight,
                    child: StatusBadge(status: status!),
                  )
                : Text(
                    value,
                    textAlign: TextAlign.right,
                    style: _valueStyle,
                  ),
          ),
        ],
      ),
    );
  }
}