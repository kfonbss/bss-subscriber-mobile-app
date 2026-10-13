import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/shared/widgets/common_app_bar.dart';
import 'package:kfon_subscriber/shared/widgets/tenant_svg_color_mapper.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../../../../shared/widgets/primary_button.dart' show PrimaryButton;
import 'package:kfon_subscriber/core/constant/app_assets.dart';

class SpeedTestPage extends StatefulWidget {
  const SpeedTestPage({super.key});

  @override
  State<SpeedTestPage> createState() => _SpeedTestPageState();
}

class _SpeedTestPageState extends State<SpeedTestPage> {
  // Dummy speed-test state (no live test service is wired yet).
  static const _tickInterval = Duration(milliseconds: 100);
  static const _totalTicks = 50;
  final _random = Random();
  Timer? _timer;
  bool _isRunning = false;
  double _gaugeSpeed = 80;
  int _upload = 30;
  int _download = 30;
  int _ping = 30;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startSpeedTest() {
    if (_isRunning) return;
    final target = 40 + _random.nextInt(81).toDouble();
    var tick = 0;
    setState(() {
      _isRunning = true;
      _gaugeSpeed = 0;
    });
    _timer = Timer.periodic(_tickInterval, (timer) {
      tick++;
      if (tick >= _totalTicks) {
        timer.cancel();
        if (!mounted) return;
        setState(() {
          _isRunning = false;
          _gaugeSpeed = target;
          _download = target.round();
          _upload = (target * (0.5 + _random.nextDouble() * 0.4)).round();
          _ping = 5 + _random.nextInt(40);
        });
        return;
      }
      final progress = tick / _totalTicks;
      final jitter = (_random.nextDouble() - 0.5) * 20;
      setState(() {
        _gaugeSpeed = (target * sin(progress * pi / 2) + jitter).clamp(0, 140);
      });
    });
  }

  // ── Static decorations ───────────────────────────────────────────────────────
  static const _resultsCardDecoration = BoxDecoration(
    color: Colors.white,
    border: Border.fromBorderSide(
      BorderSide(color: AppColor.kinputFiledLightBorder),
    ),
    borderRadius: BorderRadius.all(Radius.circular(12)),
  );
  // Header and server card heights; the card is centred on the header's
  // bottom edge (half inside the header, half below it).
  static final _headerHeight = 191.h;
  static final _serverCardHeight = 70.h;
  // The artwork is 191 tall but its blue fill ends at 180 (see the SVG).
  static final _headerEdge = _headerHeight * 180 / 191;

  // Gauge scale labels, evenly spaced along the arc (axis runs 0..8).
  static const _scaleLabels = [0, 10, 20, 40, 60, 80, 100, 120, 140];

  // Gauge geometry: arc spans 150°..390° (clockwise from 3 o'clock) and is
  // 0.2 of the radius thick. Labels keep a fixed gap inside the arc.
  static const _gaugeStartAngle = 150.0;
  static const _gaugeEndAngle = 390.0;
  static const _gaugeArcThickness = 0.2;
  static const _labelGap = 0.06;

  static const _gaugeLabelStyle = TextStyle(
    color: Colors.black,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontFamily: 'GeneralSans',
  );

  /// Scale labels drawn as annotations. Syncfusion centres its own labels on
  /// a fixed radius, so wide labels (100–140) end up closer to the arc than
  /// narrow ones (0–20). Here each label is anchored by the edge facing the
  /// arc instead, giving the same visual gap all the way round.
  static final List<GaugeAnnotation> _scaleAnnotations = [
    for (var i = 0; i < _scaleLabels.length; i++)
      () {
        final angle =
            _gaugeStartAngle +
            i * (_gaugeEndAngle - _gaugeStartAngle) / (_scaleLabels.length - 1);
        final radians = angle * pi / 180;
        return GaugeAnnotation(
          angle: angle,
          positionFactor: 1 - _gaugeArcThickness - _labelGap,
          // Shift the label inward by half its own size along the radius,
          // so its outer edge (not its centre) sits on the label circle.
          widget: FractionalTranslation(
            translation: Offset(-cos(radians) / 2, -sin(radians) / 2),
            child: Text('${_scaleLabels[i]}', style: _gaugeLabelStyle),
          ),
        );
      }(),
  ];

  /// Maps a real speed to its position on the evenly spaced label scale.
  static double _speedToScale(double speed) {
    if (speed <= _scaleLabels.first) return 0;
    for (var i = 1; i < _scaleLabels.length; i++) {
      if (speed <= _scaleLabels[i]) {
        final lo = _scaleLabels[i - 1];
        return (i - 1) + (speed - lo) / (_scaleLabels[i] - lo);
      }
    }
    return (_scaleLabels.length - 1).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;
    final gaugeValue = _speedToScale(_gaugeSpeed);
    // Design: button ends 32 above the home indicator.
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return CommonAppBar(
      onBackPressed: () => Navigator.pop(context),
      title: l10n.speedTest,
      appbarColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      circleColor: Colors.white,
      titleColor: Colors.white,
      body: Column(
        children: [
          Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: <Widget>[
              SizedBox(
                width: double.infinity,
                height: _headerHeight,
                child: SvgPicture(
                  SvgAssetLoader(
                    AppAssets.speedTestBackground,
                    colorMapper: TenantSvgColorMapper(),
                  ),
                  fit: BoxFit.fill,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: _headerEdge - _serverCardHeight / 2,
                ),
                child: Card(
                  // No default 4 margin, so the card is the full 335 wide.
                  margin: EdgeInsets.zero,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16.0)),
                  ),
                  color: Colors.white,
                  elevation: 4.0,
                  child: Container(
                    height: _serverCardHeight,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _ServerLocItem(
                          heading: l10n.server,
                          data: 'railwire.in',
                          icon: AppAssets.glob,
                        ),
                        _ServerLocItem(
                          heading: l10n.location,
                          data: 'Ernakulam',
                          icon: AppAssets.location,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                _serverCardHeight / 2 - (_headerHeight - _headerEdge),
                20,
                0,
              ),
              child: SfRadialGauge(
                axes: <RadialAxis>[
                  RadialAxis(
                    minimum: 0,
                    maximum: 8,
                    interval: 1,
                    // Labels are drawn by _scaleAnnotations (edge-anchored
                    // for an even gap to the arc, 140 included).
                    showLabels: false,
                    showTicks: false,
                    startAngle: _gaugeStartAngle,
                    endAngle: _gaugeEndAngle,
                    canScaleToFit: true,
                    annotations: _scaleAnnotations,
                    pointers: <GaugePointer>[
                      NeedlePointer(
                        tailStyle: TailStyle(
                          color: AppColor.kFailedRed,
                          borderWidth: 10,
                        ),
                        value: gaugeValue,
                        needleColor: AppColor.kPrimaryColor,
                        knobStyle: KnobStyle(
                          color: AppColor.kPrimaryColor,
                          borderWidth: 0,
                        ),
                        gradient: LinearGradient(
                          colors: [
                            AppColor.kPrimaryColor,
                            AppColor.kSecondaryBackgroundColor,
                          ],
                        ),
                      ),
                      RangePointer(
                        value: gaugeValue,
                        cornerStyle: CornerStyle.bothCurve,
                        // Same factor as the axis line so the progress
                        // arc and track are equally thick.
                        width: _gaugeArcThickness,
                        color: AppColor.kPrimaryColor,
                        sizeUnit: GaugeSizeUnit.factor,
                      ),
                    ],
                    axisLineStyle: AxisLineStyle(
                      thickness: _gaugeArcThickness,
                      cornerStyle: CornerStyle.bothCurve,
                      color: Colors.white,
                      thicknessUnit: GaugeSizeUnit.factor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Column(
            children: [
              // Design: 68 tall, content 16 inside, #EAEAEA border.
              // minHeight (not a fixed height) so large text scales grow
              // the card instead of clipping it.
              Container(
                constraints: BoxConstraints(minHeight: 68.h),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: _resultsCardDecoration,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: _SpeedResultItem(
                        heading: l10n.uploadSpeed,
                        data: '$_upload MB/s',
                        icon: AppAssets.upload,
                      ),
                    ),
                    Flexible(
                      child: _SpeedResultItem(
                        heading: l10n.downloadSpeed,
                        data: '$_download MB/s',
                        icon: AppAssets.download,
                      ),
                    ),
                    Flexible(
                      child: _SpeedResultItem(
                        heading: l10n.ping,
                        data: '$_ping ms',
                        icon: AppAssets.ping,
                      ),
                    ),
                  ],
                ),
              ),
              // Design: results card ends at 596, button at 694–746.
              Padding(
                padding: EdgeInsets.fromLTRB(20, 98.h, 20, 32.h + bottomInset),
                child: SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    label: l10n.startSpeedTest,
                    isLoading: _isRunning,
                    onClicked: _startSpeedTest,
                    borderRadius: 10,
                    height: 52.h,
                    textStyle: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Server / location info card ───────────────────────────────────────────────
// Extracted from _createServerLocLayout so Flutter can track identity.
class _ServerLocItem extends StatelessWidget {
  final String heading;
  final String data;
  final String icon;

  const _ServerLocItem({
    required this.heading,
    required this.data,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 10,
      children: [
        Container(
          width: 38.w,
          height: 38.h,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColor.kIconBackground,
          ),
          child: SvgPicture.asset(
            icon,
            colorFilter: ColorFilter.mode(
              AppColor.kPrimaryColor,
              BlendMode.srcIn,
            ),
          ),
        ),
        // Design: Poppins Regular 12 label directly above the value.
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              heading,
              style: GoogleFonts.poppins(
                color: AppColor.kBodyTextGrey,
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              data,
              style: TextStyle(
                color: AppColor.kTextSecondaryDark,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                height: 1.30,
                fontFamily: 'GeneralSans',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Speed result item ─────────────────────────────────────────────────────────
// Extracted from _createSpeedResultLayout so Flutter can track identity.
class _SpeedResultItem extends StatelessWidget {
  final String heading;
  final String data;
  final String icon;

  const _SpeedResultItem({
    required this.heading,
    required this.data,
    required this.icon,
  });

  // Design: Poppins Regular 10.
  static final _headingStyle = GoogleFonts.poppins(
    color: AppColor.kBodyTextGrey,
    fontSize: 10.sp,
    fontWeight: FontWeight.w400,
  );

  // Scaled like the heading so both lines keep the same proportion.
  static final _dataStyle = TextStyle(
    color: AppColor.kTextSecondaryDark,
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    height: 1.30,
    fontFamily: 'GeneralSans',
  );

  @override
  Widget build(BuildContext context) {
    // Design: 24 icon, text 8 after it, small gap between label and value.
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 8,
        children: [
          SvgPicture.asset(
            icon,
            // Square box so the icon is the same size on every screen.
            height: 24.w,
            width: 24.w,
            colorFilter: ColorFilter.mode(
              AppColor.kPrimaryColor,
              BlendMode.srcIn,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 2,
            children: [
              Text(heading, style: _headingStyle, maxLines: 1),
              Text(data, style: _dataStyle, maxLines: 1),
            ],
          ),
        ],
      ),
    );
  }
}
