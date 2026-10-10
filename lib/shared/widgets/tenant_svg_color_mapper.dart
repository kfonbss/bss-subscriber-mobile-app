import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';

/// Recolours the brand colour inside SVG assets to [AppColor.kPrimaryColor],
/// so the artwork follows the current tenant (LD / others).
///
/// Usage:
/// ```dart
/// SvgPicture(SvgAssetLoader(AppAssets.accountVerified,
///     colorMapper: TenantSvgColorMapper()))
///
/// // Also recolour image-specific colours (e.g. an orange accent):
/// TenantSvgColorMapper(extraColors: {0xFFF97316})
/// ```
class TenantSvgColorMapper extends ColorMapper {
  TenantSvgColorMapper({this.extraColors = const {}})
    : _primary = AppColor.kPrimaryColor;

  /// Additional ARGB colours to turn into kPrimaryColor for this image only.
  final Set<int> extraColors;

  /// Brand colours used in the SVG artwork that should become kPrimaryColor.
  static const Set<int> _brandColors = {
    0xFF009DE2, // blue (account_verified.svg, speed_test_background.svg)
    0xFF8D0247, // magenta (account_verified.svg)
    0xFF1095C5, // main blue (home_background.svg)
  };

  /// Tints of the brand colour: source colour -> amount of white mixed in.
  static const Map<int, double> _brandTints = {
    0xFF28A0CB: 0.1, // ring in home_background.svg = #1095C5 + 10% white
  };

  final Color _primary;

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) {
    // Compare RGB only, so colours with alpha still match; keep their alpha.
    final rgb = color.toARGB32() | 0xFF000000;
    final alpha = (color.a * 255).round();
    if (_brandColors.contains(rgb) || extraColors.contains(rgb)) {
      return _primary.withAlpha(alpha);
    }
    final tint = _brandTints[rgb];
    if (tint != null) {
      return Color.lerp(
        _primary,
        const Color(0xFFFFFFFF),
        tint,
      )!.withAlpha(alpha);
    }
    return color;
  }

  // flutter_svg caches pictures per loader; tying equality to the primary
  // colour makes a tenant switch produce a freshly coloured picture.
  @override
  bool operator ==(Object other) =>
      other is TenantSvgColorMapper &&
      other._primary == _primary &&
      setEquals(other.extraColors, extraColors);

  @override
  int get hashCode =>
      Object.hash(_primary, Object.hashAllUnordered(extraColors));
}
