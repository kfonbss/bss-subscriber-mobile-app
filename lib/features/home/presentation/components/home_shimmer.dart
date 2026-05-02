import 'package:flutter/material.dart';
import 'package:kfon_subscriber/shared/widgets/shimmer/shimmer_base.dart';
import 'package:kfon_subscriber/shared/widgets/shimmer/shimmer_box.dart';

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
  static const _statsItem = Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ShimmerBox(width: 40, height: 10),
      SizedBox(height: 6),
      ShimmerBox(width: 55, height: 12),
    ],
  );
  static const List<Widget> _statsItems = [
    _statsItem, _statsItem, _statsItem, _statsItem,
  ];

  static const _planShimmerItem = Padding(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
    child: ShimmerBox(width: double.infinity, height: 100),
  );
  static const List<Widget> _planShimmerItems = [
    _planShimmerItem, _planShimmerItem, _planShimmerItem, _planShimmerItem,
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
                      ShimmerBox(width: 50, height: 12),
                      const SizedBox(height: 8),
                      ShimmerBox(width: 160, height: 28),
                      const SizedBox(height: 8),
                      ShimmerBox(width: 120, height: 10),
                    ],
                  ),
                  ShimmerBox(
                    width: 80,
                    height: 34,
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
                          width: 44,
                          height: 44,
                          borderRadius: _radius22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShimmerBox(width: 140, height: 14),
                              const SizedBox(height: 6),
                              ShimmerBox(width: 100, height: 10),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        ShimmerBox(
                          width: 80,
                          height: 28,
                          borderRadius: _radius20,
                        ),
                      ],
                    ),
                  ),
                  // Stats row — _statsItems is a static const list of 4 identical
                  // Column widgets; no List.generate() allocation on each build.
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    height: 60,
                    decoration: _statsRowDecoration,
                    child: const Row(
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
                            height: 36,
                            borderRadius: _radius8,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ShimmerBox(
                            width: double.infinity,
                            height: 36,
                            borderRadius: _radius8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
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
                        height: 110,
                        borderRadius: _radius16,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: ShimmerBox(
                        width: double.infinity,
                        height: 110,
                        borderRadius: _radius16,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: ShimmerBox(
                        width: double.infinity,
                        height: 110,
                        borderRadius: _radius16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShimmerBox(width: 100, height: 16),
                  ShimmerBox(
                    width: 60,
                    height: 14,
                    borderRadius: _radius4,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // _planShimmerItems is a static const list — no List.generate()
            // allocation and no new widget objects on each build.
            ..._planShimmerItems,
          ],
        ),
      ),
    );
  }
}
