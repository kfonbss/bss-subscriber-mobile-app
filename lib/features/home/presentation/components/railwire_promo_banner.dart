import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/home/data/repository/railwire_banner_repository.dart';
import 'package:url_launcher/url_launcher.dart';

/// RailWire's Home banners from `imagelogo`. Shows [fallback] while loading and
/// when there are no banners.
class RailwirePromoBanner extends StatefulWidget {
  final Widget fallback;

  const RailwirePromoBanner({super.key, required this.fallback});

  @override
  State<RailwirePromoBanner> createState() => _RailwirePromoBannerState();
}

class _RailwirePromoBannerState extends State<RailwirePromoBanner> {
  static const _radius = BorderRadius.all(Radius.circular(16));

  late final Future<List<RailwireBanner>> _banners =
      RailwireBannerRepository.homeBanners();
  int _current = 0;

  Future<void> _open(RailwireBanner banner) async {
    final uri = Uri.tryParse(banner.redirectLink);
    if (uri == null || !uri.isScheme('http') && !uri.isScheme('https')) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RailwireBanner>>(
      future: _banners,
      builder: (context, snapshot) {
        final banners = snapshot.data ?? const [];
        if (banners.isEmpty) return widget.fallback;

        // Same 335×182 box as the fallback, 20 from the edges.
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: AspectRatio(
            aspectRatio: 335 / 182,
            child: ClipRRect(
              borderRadius: _radius,
              child: Stack(
                children: [
                  CarouselSlider.builder(
                    itemCount: banners.length,
                    options: CarouselOptions(
                      viewportFraction: 1,
                      height: double.infinity,
                      autoPlay: banners.length > 1,
                      enableInfiniteScroll: banners.length > 1,
                      onPageChanged:
                          (index, _) => setState(() => _current = index),
                    ),
                    itemBuilder:
                        (context, index, _) => _BannerImage(
                          banner: banners[index],
                          onTap: () => _open(banners[index]),
                        ),
                  ),
                  if (banners.length > 1)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 8.h,
                      child: _Dots(count: banners.length, current: _current),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BannerImage extends StatelessWidget {
  final RailwireBanner banner;
  final VoidCallback onTap;

  const _BannerImage({required this.banner, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: banner.redirectLink.isEmpty ? null : onTap,
      child: Image.network(
        banner.imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder:
            (context, child, progress) =>
                progress == null ? child : const _Placeholder(),
        errorBuilder: (context, _, __) => const _Placeholder(),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) =>
      ColoredBox(color: Colors.black.withValues(alpha: 0.05));
}

class _Dots extends StatelessWidget {
  final int count;
  final int current;

  const _Dots({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.symmetric(horizontal: 3.w),
          width: index == current ? 16.w : 6.w,
          height: 6.w,
          decoration: BoxDecoration(
            color:
                index == current
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(3.w),
          ),
        ),
      ),
    );
  }
}
