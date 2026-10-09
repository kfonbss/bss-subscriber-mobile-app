import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';

Future<T?> showAppModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
  bool useSafeAreaScroll = true,
  bool isDismissible = true,
  bool enableDrag = true,
  bool useRootNavigator = false,
  // Per-sheet overrides; every sheet that leaves them out keeps the defaults.
  Color? backgroundColor,
  Color? dragHandleColor,
  Size? dragHandleSize,
  EdgeInsetsGeometry? dragHandlePadding,
  double? topRadius,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    isScrollControlled: isScrollControlled,
    useRootNavigator: useRootNavigator,
    useSafeArea: true,
    backgroundColor: backgroundColor ?? AppColor.kMainBackgroundColor,
    shape: topRadius == null
        ? null
        : RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(topRadius),
      ),
    ),
    builder: (ctx) {
      final content = ClipRRect(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(topRadius ?? 24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding:
              dragHandlePadding ??
                  EdgeInsets.only(top: 16.h, bottom: 16.h),
              child: Container(
                width: dragHandleSize?.width ?? 50.w,
                height: dragHandleSize?.height ?? 4.h,
                decoration: BoxDecoration(
                  color: dragHandleColor ?? AppColor.kDragHandleGrey,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            // actual content
            Flexible(child: builder(ctx)),
          ],
        ),
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
