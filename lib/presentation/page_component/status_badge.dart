import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
enum TransactionStatus { pending, success, fail }
class StatusBadge extends StatelessWidget {
  final TransactionStatus status;

  const StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      TransactionStatus.pending => 'Pending',
      TransactionStatus.success => 'Success',
      TransactionStatus.fail => 'Fail',
    };

    final textColor = switch (status) {
      TransactionStatus.pending => const Color(0xFFE8820C),
      TransactionStatus.success => const Color(0xFF4CAF50),
      TransactionStatus.fail => const Color(0xFFD0214A),
    };

    final bgColor = switch (status) {
      TransactionStatus.pending => const Color(0xFFFFF0E0),
      TransactionStatus.success => const Color(0xFFE8F5E9),
      TransactionStatus.fail => const Color(0xFFFCE8EC),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
          fontFamily: 'General Sans',
          height: 1.30,
          color: textColor,
        ),
      ),
    );
  }
}