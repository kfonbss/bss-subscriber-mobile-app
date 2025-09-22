import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLayout extends StatelessWidget {
  final Color?  highlightColor;
  final Widget child;

  const ShimmerLayout({
    super.key,
    this.highlightColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: highlightColor ?? AppColor.shimmerHighlightColor,
      enabled: true,
      child: child,
    );
  }
}
