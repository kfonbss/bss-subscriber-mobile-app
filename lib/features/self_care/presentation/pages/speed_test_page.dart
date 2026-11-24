import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/self_care/domain/entity/speed_test_entity.dart';
import 'package:kfon_subscriber/features/self_care/domain/repository/speed_test_repository.dart';
import 'package:kfon_subscriber/features/self_care/presentation/bloc/speed_test_bloc.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/service_locator.dart';
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
  static const _tickInterval = Duration(milliseconds: 100);
  static const _settleTicks = 8;
  static const _placeholder = '--';
  final _random = Random();
  late final SpeedTestBloc _bloc;
  Timer? _timer;
  bool _isRunning = false;
  double _gaugeSpeed = 0;
  SpeedTestEntity? _result;

  @override
  void initState() {
    super.initState();
    _bloc = SpeedTestBloc(repository: sl<SpeedTestRepository>());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bloc.close();
    super.dispose();
  }

  void _startSpeedTest() {
    if (_isRunning) return;
    setState(() {
      _isRunning = true;
      _gaugeSpeed = 0;
    });
    _startMeasuringAnimation();
    _bloc.add(const RunSpeedTest());
  }

  /// Keeps the needle moving while the API measures the connection, since
  /// the server only returns the final numbers.
  void _startMeasuringAnimation() {
    _timer?.cancel();
    var tick = 0;
    _timer = Timer.periodic(_tickInterval, (_) {
      tick++;
      final rise = (tick / 20).clamp(0.0, 1.0);
      final jitter = (_random.nextDouble() - 0.5) * 20;
      setState(() {
        _gaugeSpeed = (60 * sin(rise * pi / 2) + jitter).clamp(0, 140);
      });
    });
  }

  /// Eases the needle from where it is to [target].
  void _settleGauge(double target) {
    _timer?.cancel();
    final from = _gaugeSpeed;
    var tick = 0;
    _timer = Timer.periodic(_tickInterval, (timer) {
      tick++;
      final t = Curves.easeOut.transform(tick / _settleTicks);
      setState(() => _gaugeSpeed = from + (target - from) * t);
      if (tick >= _settleTicks) timer.cancel();
    });
  }

  void _onSpeedTestState(BuildContext context, SpeedTestState state) {
    switch (state.status) {
      case SpeedTestStatus.loaded:
        final result = state.result!;
        setState(() {
          _isRunning = false;
          _result = result;
        });
        _settleGauge(result.downloadMbps.clamp(0, 140).toDouble());
      case SpeedTestStatus.error:
        setState(() => _isRunning = false);
        _settleGauge(_result?.downloadMbps.clamp(0, 140).toDouble() ?? 0);
        DialogUtil().showCustomSnackbar(
          context: context,
          content: state.error ?? 'Speed test failed',
          isError: true,
        );
      case SpeedTestStatus.initial:
      case SpeedTestStatus.loading:
        break;
    }
  }

  /// 1 decimal below 100 (e.g. 45.3), whole numbers above; no trailing ".0".
  static String _formatSpeed(double? value) {
    if (value == null) return _placeholder;
    if (value >= 100) return value.round().toString();
    final fixed = value.toStringAsFixed(1);
    return fixed.endsWith('.0') ? fixed.substring(0, fixed.length - 2) : fixed;
  }

  static String _orPlaceholder(String? value) =>
      (value == null || value.isEmpty) ? _placeholder : value;

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

  // Gauge geometry: arc spans 150°..390° (clockwise from 3 o'clock).
  // Everything is a fraction of the radius, so the arc, needle and labels
  // keep the same proportions on every screen. Reference: 375-wide screen,
  // gauge 335 wide (radius 167.5), 24 stroke. From the design: labels sit
  // well inside the arc and the needle stops short of them.
  static const _gaugeStartAngle = 150.0;
  static const _gaugeEndAngle = 390.0;
  static const _refRadius = 167.5;
  static const _gaugeArcThickness = 24 / _refRadius;
  static const _labelGap = 0.12;
  static const _gaugeBottomGap = 24.0; // arc caps → results card
  static const _resultsCardMinHeight = 68.0;
  static const _buttonHeight = 52.0;
  static const _buttonBottomGap = 32.0; // above the home indicator
  static const _minButtonGap = 24.0; // results card → button, at least

  /// Needle tip at 0.55 of the radius, a clear gap inside the labels'
  /// inner edges (~0.65–0.70).
  static const _needleLengthFactor = 0.55;

  /// Head width keeps the Figma 26 × 138 proportion to the needle length.
  static const _needleWidthFactor = _needleLengthFactor * 26 / 138;

  /// Arc height for this sweep: r + r·sin30° = 0.75 × width.
  static const _gaugeHeightToWidth = 0.75;

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
      body: BlocListener<SpeedTestBloc, SpeedTestState>(
        bloc: _bloc,
        listener: _onSpeedTestState,
        child: Column(
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
                            data: _orPlaceholder(_result?.server),
                            icon: AppAssets.glob,
                          ),
                          _ServerLocItem(
                            heading: l10n.location,
                            data: _orPlaceholder(_result?.location),
                            icon: AppAssets.location,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Gauge, results card and button share one height budget: the
            // gauge gets full width (20 side margins) unless the screen is too
            // short; the gap above the button absorbs any spare height and
            // gives way first (down to _minButtonGap), so the gauge keeps its
            // size and its gap to the results card.
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final topGap =
                      _serverCardHeight / 2 - (_headerHeight - _headerEdge);
                  final fixedBelow =
                      _gaugeBottomGap.h +
                      _resultsCardMinHeight.h +
                      _minButtonGap.h +
                      _buttonHeight.h +
                      _buttonBottomGap.h +
                      bottomInset;
                  final gaugeWidth = max(
                    0.0,
                    min(
                      constraints.maxWidth - 40,
                      (constraints.maxHeight - topGap - fixedBelow) /
                          _gaugeHeightToWidth,
                    ),
                  );
                  final radius = gaugeWidth / 2;
                  return Column(
                    children: [
                      SizedBox(height: topGap),
                      SizedBox(
                        width: gaugeWidth,
                        height: gaugeWidth * _gaugeHeightToWidth,
                        child: SfRadialGauge(
                          axes: <RadialAxis>[
                            RadialAxis(
                              radiusFactor: 1,
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
                                // Wedge needle: sharp tip, wide head at the centre.
                                // Syncfusion draws it pointing up (tip = top,
                                // centre = bottom) and its widths are reversed:
                                // needleEndWidth is the centre end. Gradient runs
                                // tip → head.
                                NeedlePointer(
                                  value: gaugeValue,
                                  // Syncfusion's head comes out ~1.788 ×
                                  // needleEndWidth wide (it mixes degrees into
                                  // radians), hence the division.
                                  needleLength: _needleLengthFactor,
                                  lengthUnit: GaugeSizeUnit.factor,
                                  needleStartWidth: 0,
                                  needleEndWidth:
                                      radius * _needleWidthFactor / 1.788,
                                  needleColor: AppColor.kSpeedNeedleColor,
                                  knobStyle: const KnobStyle(knobRadius: 0),
                                  tailStyle: const TailStyle(
                                    length: 0,
                                    width: 0,
                                  ),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      AppColor.kSpeedNeedleColor,
                                      AppColor.kSecondaryBackgroundColor,
                                    ],
                                    // Solid for most of the length; white only at
                                    // the head end.
                                    stops: const [0.75, 1.0],
                                  ),
                                ),
                                RangePointer(
                                  value: gaugeValue,
                                  cornerStyle: CornerStyle.bothCurve,
                                  // Same factor as the axis line so the progress
                                  // arc and track are equally thick.
                                  width: _gaugeArcThickness,
                                  // Primary on both brands (RailWire navy, KFON maroon).
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
                      SizedBox(height: _gaugeBottomGap.h),
                      // Design: 68 tall, content 16 inside, #EAEAEA border.
                      // minHeight (not a fixed height) so large text scales grow
                      // the card instead of clipping it.
                      Container(
                        constraints: BoxConstraints(
                          minHeight: _resultsCardMinHeight.h,
                        ),
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
                                data: l10n.mbPerSecond(
                                  _formatSpeed(_result?.uploadMbps),
                                ),
                                icon: AppAssets.upload,
                              ),
                            ),
                            Flexible(
                              child: _SpeedResultItem(
                                heading: l10n.downloadSpeed,
                                data: l10n.mbPerSecond(
                                  _formatSpeed(_result?.downloadMbps),
                                ),
                                icon: AppAssets.download,
                              ),
                            ),
                            Flexible(
                              child: _SpeedResultItem(
                                heading: l10n.ping,
                                data: l10n.msValue(
                                  _result == null
                                      ? _placeholder
                                      : _result!.latencyMs.round().toString(),
                                ),
                                icon: AppAssets.ping,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Spare height goes here (design ~98 on an 812 screen).
                      const Spacer(),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          20,
                          _minButtonGap.h,
                          20,
                          _buttonBottomGap.h + bottomInset,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: PrimaryButton(
                            label: l10n.startSpeedTest,
                            isLoading: _isRunning,
                            onClicked: _startSpeedTest,
                            borderRadius: 10,
                            height: _buttonHeight.h,
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
                  );
                },
              ),
            ),
          ],
        ),
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
