import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:flutter/material.dart';

Future<T?> showAppModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isDismissible: true,
    isScrollControlled: isScrollControlled,
    backgroundColor: AppColor.kMainBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 16, bottom: 16),
                child: Container(
                  width: 50,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: AppColor.kDragHandleGrey,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),

              // actual content
              builder(ctx),
            ],
          ),
        ),
      );
    },
  );
}
