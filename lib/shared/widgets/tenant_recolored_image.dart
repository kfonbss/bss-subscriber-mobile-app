import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/shared/widgets/tenant_svg_color_mapper.dart';

/// Shows an SVG illustration recoloured to [AppColor.kPrimaryColor].
///
/// Some illustrations (e.g. `filler.svg`) are a PNG embedded inside an SVG,
/// so they have no `fill` values for [TenantSvgColorMapper] to swap. For
/// those, the embedded pixels are recoloured instead: every pixel in the
/// artwork's brand-blue hue range is shifted onto the primary colour, keeping
/// its relative lightness, so tints stay tints. Other colours (skin, navy,
/// white) are left untouched.
///
/// Real vector SVGs fall back to [TenantSvgColorMapper].
class TenantRecoloredImage extends StatefulWidget {
  const TenantRecoloredImage(
    this.assetName, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  final String assetName;
  final double? width;
  final double? height;
  final BoxFit fit;

  /// Brand colour the artwork was drawn with.
  static final Color sourceColor = AppColor.kSourceColor;

  @override
  State<TenantRecoloredImage> createState() => _TenantRecoloredImageState();
}

class _TenantRecoloredImageState extends State<TenantRecoloredImage> {
  static final Map<String, Future<ui.Image?>> _cache = {};

  Future<ui.Image?>? _image;
  Color? _target;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolve();
  }

  @override
  void didUpdateWidget(TenantRecoloredImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _resolve();
  }

  void _resolve() {
    final target = AppColor.kPrimaryColor;
    if (target == _target && _image != null) return;
    _target = target;
    _image = target == TenantRecoloredImage.sourceColor
        ? null // artwork already matches, draw it as-is
        : _cache.putIfAbsent(
            '${widget.assetName}|${target.toARGB32()}',
            () => _loadRecolored(widget.assetName, target),
          );
  }

  @override
  Widget build(BuildContext context) {
    final svg = SvgPicture(
      SvgAssetLoader(widget.assetName, colorMapper: TenantSvgColorMapper()),
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
    );
    final image = _image;
    if (image == null) return svg;
    return FutureBuilder<ui.Image?>(
      future: image,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return SizedBox(width: widget.width, height: widget.height);
        }
        final img = snapshot.data;
        if (img == null) return svg; // true vector SVG: colour-mapped instead
        return RawImage(
          image: img,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
        );
      },
    );
  }
}

final RegExp _embeddedPng = RegExp(r'data:image/png;base64,([A-Za-z0-9+/=\s]+)');

Future<ui.Image?> _loadRecolored(String assetName, Color target) async {
  final svg = await rootBundle.loadString(assetName);
  final match = _embeddedPng.firstMatch(svg);
  if (match == null) return null;

  final bytes = base64.decode(match.group(1)!.replaceAll(RegExp(r'\s'), ''));
  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  final source = frame.image;
  final rgba = await source.toByteData(format: ui.ImageByteFormat.rawRgba);
  final width = source.width, height = source.height;
  source.dispose();
  if (rgba == null) return null;

  final pixels = await compute(
    _recolorPixels,
    _RecolorJob(
      rgba.buffer.asUint8List(),
      TenantRecoloredImage.sourceColor.toARGB32(),
      target.toARGB32(),
    ),
  );

  final buffer = await ui.ImmutableBuffer.fromUint8List(pixels);
  final descriptor = ui.ImageDescriptor.raw(
    buffer,
    width: width,
    height: height,
    pixelFormat: ui.PixelFormat.rgba8888,
  );
  final out = await (await descriptor.instantiateCodec()).getNextFrame();
  descriptor.dispose();
  buffer.dispose();
  return out.image;
}

class _RecolorJob {
  const _RecolorJob(this.pixels, this.source, this.target);
  final Uint8List pixels;
  final int source;
  final int target;
}

/// Hue range (degrees) of the brand blue and its light tints in the artwork.
const double _minHue = 180, _maxHue = 220, _minSaturation = 0.15;

Uint8List _recolorPixels(_RecolorJob job) {
  final src = _Hsl.fromArgb(job.source), dst = _Hsl.fromArgb(job.target);
  final px = job.pixels;
  for (var i = 0; i < px.length; i += 4) {
    if (px[i + 3] == 0) continue;
    final c = _Hsl.fromRgb(px[i], px[i + 1], px[i + 2]);
    if (c.s < _minSaturation || c.h < _minHue || c.h > _maxHue) continue;
    // Shift hue by the brand offset; remap S and L so the brand colour lands
    // exactly on the target while 0 and 1 stay fixed (tints stay tints).
    final h = (c.h + dst.h - src.h) % 360;
    final s = _remap(c.s, src.s, dst.s);
    final l = _remap(c.l, src.l, dst.l);
    final rgb = _Hsl(h < 0 ? h + 360 : h, s, l).toRgb();
    px[i] = rgb[0];
    px[i + 1] = rgb[1];
    px[i + 2] = rgb[2];
  }
  return px;
}

/// Piecewise-linear map of [v] with 0→0, [from]→[to], 1→1.
double _remap(double v, double from, double to) {
  if (from <= 0 || from >= 1) return v;
  return v <= from
      ? v / from * to
      : to + (v - from) / (1 - from) * (1 - to);
}

class _Hsl {
  const _Hsl(this.h, this.s, this.l);
  final double h, s, l;

  factory _Hsl.fromArgb(int argb) =>
      _Hsl.fromRgb((argb >> 16) & 0xFF, (argb >> 8) & 0xFF, argb & 0xFF);

  factory _Hsl.fromRgb(int r8, int g8, int b8) {
    final r = r8 / 255, g = g8 / 255, b = b8 / 255;
    final max = [r, g, b].reduce((a, b) => a > b ? a : b);
    final min = [r, g, b].reduce((a, b) => a < b ? a : b);
    final l = (max + min) / 2, d = max - min;
    if (d == 0) return _Hsl(0, 0, l);
    final s = d / (1 - (2 * l - 1).abs());
    double h;
    if (max == r) {
      h = ((g - b) / d) % 6;
    } else if (max == g) {
      h = (b - r) / d + 2;
    } else {
      h = (r - g) / d + 4;
    }
    h *= 60;
    if (h < 0) h += 360;
    return _Hsl(h, s.clamp(0, 1), l);
  }

  List<int> toRgb() {
    final c = (1 - (2 * l - 1).abs()) * s;
    final x = c * (1 - ((h / 60) % 2 - 1).abs());
    final m = l - c / 2;
    double r, g, b;
    if (h < 60) {
      r = c; g = x; b = 0;
    } else if (h < 120) {
      r = x; g = c; b = 0;
    } else if (h < 180) {
      r = 0; g = c; b = x;
    } else if (h < 240) {
      r = 0; g = x; b = c;
    } else if (h < 300) {
      r = x; g = 0; b = c;
    } else {
      r = c; g = 0; b = x;
    }
    int to8(double v) => ((v + m) * 255).round().clamp(0, 255);
    return [to8(r), to8(g), to8(b)];
  }
}
