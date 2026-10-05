import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/shared/widgets/shimmer/shimmer_base.dart';
import 'package:kfon_subscriber/shared/widgets/shimmer/shimmer_box.dart';

class ListShimmer extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final double separatorHeight;
  final EdgeInsetsGeometry padding;
  final double? itemWidth;
  final BorderRadius? itemBorderRadius;

  const ListShimmer({
    super.key,
    this.itemCount = 8,
    this.itemHeight = 80.0,
    this.separatorHeight = 16.0,
    this.padding = const EdgeInsets.all(16.0),
    this.itemWidth,
    this.itemBorderRadius,
  });

  @override
  Widget build(BuildContext context) {
    // A plain Column (not a ListView) so the shimmer works in any parent:
    // inside scroll views, slivers, list items and bottom sheets the height
    // is unbounded, and a ListView there throws "unbounded height".
    // The non-scrolling SingleChildScrollView clips extra rows when the
    // parent height is bounded instead of overflowing.
    return AppShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < itemCount; i++) ...[
              ShimmerBox(
                height: itemHeight.h,
                width: itemWidth?.w ?? double.infinity,
                borderRadius: itemBorderRadius,
              ),
              if (i < itemCount - 1) SizedBox(height: separatorHeight),
            ],
          ],
        ),
      ),
    );
  }
}
