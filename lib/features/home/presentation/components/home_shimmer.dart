import 'package:flutter/material.dart';
import 'package:kfon_subscriber/shared/widgets/shimmer/shimmer_base.dart';
import 'package:kfon_subscriber/shared/widgets/shimmer/shimmer_box.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';

class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  // ── Shared border-radius constants ───────────────────────────────────────────
  static const _radius4 = BorderRadius.all(Radius.circular(4));
  static const _radius8 = BorderRadius.all(Radius.circular(8));
  static const _radius16 = BorderRadius.all(Radius.circular(16));
  static const _radius20 = BorderRadius.all(Radius.circular(20));
  static const _radius22 = BorderRadius.all(Radius.circular(22));

  // ── Shared card decorations ──────────────────────────────────────────────────
  static const _cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: _radius16,
  );
  static const _statsRowDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(12)),
  );

  // ── Pre-computed identical-item lists ───────────────────────────────────────
  // List.generate(4, (_) => ...) with identical items was allocating a new
  // list and new widget objects on every build(). Hoisting to static const
  // eliminates both the list and the object allocations entirely.
  static final _statsItem = Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ShimmerBox(width: 40.w, height: 10.h),
      SizedBox(height: 6.h),
      ShimmerBox(width: 55.w, height: 12.h),
    ],
  );
  static final List<Widget> _statsItems = [
    _statsItem,
    _statsItem,
    _statsItem,
    _statsItem,
  ];

  static final _planShimmerItem = Padding(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
    child: ShimmerBox(width: double.infinity, height: 100.h),
  );
  static final List<Widget> _planShimmerItems = [
    _planShimmerItem,
    _planShimmerItem,
    _planShimmerItem,
    _planShimmerItem,
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AppShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 28),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(width: 50.w, height: 12.h),
                      SizedBox(height: 8.h),
                      ShimmerBox(width: 160.w, height: 28.h),
                      SizedBox(height: 8.h),
                      ShimmerBox(width: 120.w, height: 10.h),
                    ],
                  ),
                  ShimmerBox(
                    width: 80.w,
                    height: 34.h,
                    borderRadius: _radius20,
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: _cardDecoration,
              child: Column(
                children: [
                  // Header row: avatar + name/date + days-left badge
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox(
                          width: 44.w,
                          height: 44.h,
                          borderRadius: _radius22,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShimmerBox(width: 140.w, height: 14.h),
                              SizedBox(height: 6.h),
                              ShimmerBox(width: 100.w, height: 10.h),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        ShimmerBox(
                          width: 80.w,
                          height: 28.h,
                          borderRadius: _radius20,
                        ),
                      ],
                    ),
                  ),
                  // Stats row — _statsItems is a static const list of 4 identical
                  // Column widgets; no List.generate() allocation on each build.
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    height: 60.h,
                    decoration: _statsRowDecoration,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: _statsItems,
                    ),
                  ),
                  // Buttons row
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: ShimmerBox(
                            width: double.infinity,
                            height: 36.h,
                            borderRadius: _radius8,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: ShimmerBox(
                            width: double.infinity,
                            height: 36.h,
                            borderRadius: _radius8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),
            // 3 quick-action shimmer boxes — hardcoded to avoid List.generate
            // allocation; all items are identical.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: ShimmerBox(
                        width: double.infinity,
                        height: 110.h,
                        borderRadius: _radius16,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: ShimmerBox(
                        width: double.infinity,
                        height: 110.h,
                        borderRadius: _radius16,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: ShimmerBox(
                        width: double.infinity,
                        height: 110.h,
                        borderRadius: _radius16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShimmerBox(width: 100.w, height: 16.h),
                  ShimmerBox(width: 60.w, height: 14.h, borderRadius: _radius4),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            // _planShimmerItems is a static const list — no List.generate()
            // allocation and no new widget objects on each build.
            ..._planShimmerItems,
          ],
        ),
      ),
    );
  }
}
