import 'package:kfon_subscriber/presentation/ui_component/shimmer/shimmer_box.dart';
import 'package:flutter/material.dart';

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
    return ListView.separated(
      padding: padding,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      separatorBuilder: (context, index) => SizedBox(height: separatorHeight),
      itemBuilder: (context, index) {
        return ShimmerBox(
          height: itemHeight,
          width: itemWidth ?? double.infinity,
          borderRadius: itemBorderRadius,
        );
      },
    );
  }
}
