import 'package:flutter/material.dart';
import 'package:kfon_subscriber/presentation/ui_component/shimmer/shimmer_base.dart';

/// A simple box placeholder for shimmer. Use inside [AppShimmer] or wrap with it.
/// Use for list items, cards, search bars, grids, etc.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  final double width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: ShimmerColors.baseColor,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
    );
  }
}
