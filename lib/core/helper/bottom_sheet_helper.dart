import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';

class BottomSheetHelper {
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget child,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: AppColor.kMainBackgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) => _BottomSheetLayout(title: title, child: child),
    );
  }
}

class _BottomSheetLayout extends StatelessWidget {
  final String title;
  final Widget child;

  const _BottomSheetLayout({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 5,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColor.kDragHandleGrey,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: AppColor.kNearBlack,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 30),
          child,
        ],
      ),
    );
  }
}
