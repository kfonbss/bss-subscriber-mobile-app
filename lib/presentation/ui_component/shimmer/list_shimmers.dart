import 'package:flutter/material.dart';
import 'package:kfon_subscriber/presentation/ui_component/shimmer/shimmer_base.dart';
import 'package:kfon_subscriber/presentation/ui_component/shimmer/shimmer_box.dart';

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
    return AppShimmer(
      child: Padding(
        padding: padding,
        child: ListView(
          children: [
            for (int i = 0; i < itemCount; i++) ...[
              ShimmerBox(
                height: itemHeight,
                width: itemWidth ?? double.infinity,
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
