import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';

enum TransactionStatus { pending, success, fail }

class StatusBadge extends StatelessWidget {
  final TransactionStatus status;

  const StatusBadge({super.key, required this.status});

  // Padding uses Sizer — fixed after MaterialApp.builder, computed once.
  static final _padding = EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h);

  // Decorations: all colors are const AppColor values → static const.
  // BorderRadius.all(Radius.circular(N)) is const; .circular(N) is not.
  static const _pendingDecoration = BoxDecoration(
    color: AppColor.kStatusPendingBg,
    borderRadius: BorderRadius.all(Radius.circular(20)),
  );
  static const _successDecoration = BoxDecoration(
    color: AppColor.kStatusSuccessBg,
    borderRadius: BorderRadius.all(Radius.circular(20)),
  );
  static const _failDecoration = BoxDecoration(
    color: AppColor.kStatusFailBg,
    borderRadius: BorderRadius.all(Radius.circular(20)),
  );

  // TextStyles: fontSize uses 10.sp (Sizer) → static final.
  static final _pendingStyle = TextStyle(
    fontSize: 10.sp,
    fontWeight: FontWeight.w500,
    fontFamily: 'GeneralSans',
    height: 1.30,
    color: AppColor.kStatusPendingOrange,
  );
  static final _successStyle = TextStyle(
    fontSize: 10.sp,
    fontWeight: FontWeight.w500,
    fontFamily: 'GeneralSans',
    height: 1.30,
    color: AppColor.kStatusSuccessText,
  );
  static final _failStyle = TextStyle(
    fontSize: 10.sp,
    fontWeight: FontWeight.w500,
    fontFamily: 'GeneralSans',
    height: 1.30,
    color: AppColor.kStatusFailRed,
  );

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      TransactionStatus.pending => 'Pending',
      TransactionStatus.success => 'Success',
      TransactionStatus.fail => 'Fail',
    };

    final decoration = switch (status) {
      TransactionStatus.pending => _pendingDecoration,
      TransactionStatus.success => _successDecoration,
      TransactionStatus.fail => _failDecoration,
    };

    final style = switch (status) {
      TransactionStatus.pending => _pendingStyle,
      TransactionStatus.success => _successStyle,
      TransactionStatus.fail => _failStyle,
    };

    return Container(
      padding: _padding,
      decoration: decoration,
      child: Text(label, style: style),
    );
  }
}
