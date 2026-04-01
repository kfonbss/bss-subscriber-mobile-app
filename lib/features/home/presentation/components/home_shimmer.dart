import 'package:flutter/material.dart';
import 'package:kfon_subscriber/presentation/ui_component/shimmer/shimmer_base.dart';
import 'package:kfon_subscriber/presentation/ui_component/shimmer/shimmer_box.dart';

class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return  SingleChildScrollView(
      child: AppShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 28),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
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
                    borderRadius: BorderRadius.circular(20),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
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
                          borderRadius: BorderRadius.circular(22),
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
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ],
                    ),
                  ),
                  // Stats row
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        4,
                            (_) => Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShimmerBox(width: 40, height: 10),
                            const SizedBox(height: 6),
                            ShimmerBox(width: 55, height: 12),
                          ],
                        ),
                      ),
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
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ShimmerBox(
                            width: double.infinity,
                            height: 36,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(
                  3,
                      (_) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: ShimmerBox(
                        width: double.infinity,
                        height: 110,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
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
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(4, (_) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 5),
              child: ShimmerBox(width: double.infinity, height: 100),
            )),
          ],
        ),
      ),
    );
  }
}
