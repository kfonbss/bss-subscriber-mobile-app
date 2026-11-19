import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:kfon_subscriber/core/network/railwire_api.dart';

/// One Home banner from the `images_list_top` of RailWire's `imagelogo`.
class RailwireBanner {
  final String imageUrl;

  /// Empty when the banner isn't clickable.
  final String redirectLink;

  const RailwireBanner({required this.imageUrl, required this.redirectLink});
}

class RailwireBannerRepository {
  /// Per `stcode`, so a login in another state loads that state's banners.
  static final Map<String, List<RailwireBanner>> _cache = {};

  /// The Home banners, or an empty list when there are none or the call fails.
  static Future<List<RailwireBanner>> homeBanners() async {
    final session = await RailwireSession.current();
    if (session == null) return const [];
    final cached = _cache[session.stateCode];
    if (cached != null) return cached;

    final result = await RailwireApi.post(
      ApiUrls.railwireImageLogoURL,
      (session) => {'stcode': session.stateCode},
    );
    return result.fold((_) => const [], (data) {
      final banners =
          (data['images_list_top'] as List<dynamic>? ?? [])
              .whereType<Map<String, dynamic>>()
              .map(
                (json) => RailwireBanner(
                  imageUrl: json['image_name']?.toString().trim() ?? '',
                  redirectLink: json['redirect_link']?.toString().trim() ?? '',
                ),
              )
              .where((banner) => banner.imageUrl.isNotEmpty)
              .toList();
      _cache[session.stateCode] = banners;
      return banners;
    });
  }
}
