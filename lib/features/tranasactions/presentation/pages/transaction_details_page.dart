import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/presentation/page_component/status_badge.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_app_bar.dart';
import 'package:kfon_subscriber/presentation/ui_component/secondary_button.dart';

class TransactionDetailsPage extends StatelessWidget {
  const TransactionDetailsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return CommonAppBar(
      onBackPressed: () => Navigator.pop(context),
      title: 'Transaction Details',
      body: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [_buildDetailsCard(), _buildCloseButton(context)],
        ),
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _DetailRow(label: 'Order Time', value: '2025-10-03 19:35:03'),
          _DetailRow(label: 'Order Amount', value: '352.82'),
          _DetailRow(
            label: 'BSS Reference',
            value: 'UW9089EZ45520251015',
            valueBold: true,
          ),
          _DetailRow(
            label: 'BSS Status',
            value: '',
            isStatus: true,
            status: TransactionStatus.pending,
          ),
          _DetailRow(
            label: 'Txn. Reference',
            value: 'UW9089EZ45520251015',
            valueBold: true,
          ),
          _DetailRow(
            label: 'Response Message',
            value: 'Successfully completed\nand Receipt generated',
            valueBold: true,
          ),
          _DetailRow(label: 'Payment Gateway', value: 'IKM', isLast: true),
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
        child: SecondaryButton(label: 'Close', onClicked: () => Navigator.pop(context)),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          SizedBox(
            width: 140.w,
            child: Text(
              label,
              style: TextStyle(fontSize: 14.sp,
                  fontFamily: 'General Sans',
                  fontWeight: FontWeight.w400,
                  height: 1.30,
                  color: Colors.black54),
            ),
          ),

          // Value / Badge
          Expanded(
            child:
            isStatus
                ? Align(
              alignment: Alignment.centerRight,
              child: StatusBadge(status: status!),
            )
                : Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14.sp,
                fontFamily: 'General Sans',
                height: 1.30,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}