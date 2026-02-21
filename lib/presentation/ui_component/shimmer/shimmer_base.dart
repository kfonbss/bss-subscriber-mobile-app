import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Base shimmer colors used across the app for consistent loading placeholders.
class ShimmerColors {
  ShimmerColors._();

  static const Color baseColor = Color(0xFFE0E0E0);
  static const Color highlightColor = Color(0xFFF5F5F5);
}

/// Wraps [child] with the app's standard shimmer effect.
/// Use with placeholder widgets (e.g. [ShimmerBox]) that have a solid color.
class AppShimmer extends StatelessWidget {
  const AppShimmer({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: ShimmerColors.baseColor,
      highlightColor: ShimmerColors.highlightColor,
      child: child,
    );
  }
}
