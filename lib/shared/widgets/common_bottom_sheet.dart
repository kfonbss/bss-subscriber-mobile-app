import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';

Future<T?> showAppModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
  bool useSafeAreaScroll = true,
  bool isDismissible= true, // 👈 prevents closing on outside tap
  bool enableDrag= true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    isScrollControlled: isScrollControlled,
    backgroundColor: AppColor.kMainBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      final content = Column(
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
          Flexible(child: builder(ctx)),
        ],
      );

      return SafeArea(
        top: false,
        child: useSafeAreaScroll
            ? SingleChildScrollView(child: content)
            : content,
      );
    },
  );
}
