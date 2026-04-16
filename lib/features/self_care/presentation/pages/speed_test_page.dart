import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_app_bar.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../../../../presentation/ui_component/primary_button.dart' show PrimaryButton;

class SpeedTestPage extends StatelessWidget {
  const SpeedTestPage({super.key});

  // ── Static decorations ───────────────────────────────────────────────────────
  static const _resultsCardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(12)),
  );
  static const _serverCardPadding =
      EdgeInsets.only(left: 20, right: 20, top: 130);

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;

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
            children: <Widget>[
              SizedBox(
                width: double.infinity,
                height: 190.h,
                child: SvgPicture.asset(
                  'assets/images/speed_test_background.svg',
                  fit: BoxFit.fill,
                ),
              ),
              Padding(
                padding: _serverCardPadding,
                child: Card(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16.0)),
                  ),
                  color: Colors.white,
                  elevation: 4.0,
                  child: Container(
                    height: 75.h,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _ServerLocItem(
                          heading: l10n.server,
                          data: 'Kfon.in',
                          icon: 'glob.png',
                        ),
                        _ServerLocItem(
                          heading: l10n.location,
                          data: 'Ernakulam',
                          icon: 'location.png',
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SfRadialGauge(
                axes: <RadialAxis>[
                  RadialAxis(
                    minimum: 0,
                    maximum: 140,
                    interval: 10,
                    showLabels: true,
                    showTicks: false,
                    startAngle: 150,
                    endAngle: 390,
                    canScaleToFit: true,
                    pointers: <GaugePointer>[
                      NeedlePointer(
                        tailStyle: TailStyle(
                          color: AppColor.kFailedRed,
                          borderWidth: 10,
                        ),
                        value: 80,
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
                        value: 80,
                        cornerStyle: CornerStyle.bothCurve,
                        width: 0.2,
                        color: AppColor.kPrimaryColor,
                        sizeUnit: GaugeSizeUnit.factor,
                      ),
                    ],
                    axisLabelStyle: GaugeTextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    axisLineStyle: AxisLineStyle(
                      thickness: 0.2,
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
              Container(
                height: 75,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 16),
                decoration: _resultsCardDecoration,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _SpeedResultItem(
                      heading: l10n.uploadSpeed,
                      data: '0 MB/s',
                      icon: 'upload.png',
                    ),
                    _SpeedResultItem(
                      heading: l10n.downloadSpeed,
                      data: '0 MB/s',
                      icon: 'download.png',
                    ),
                    _SpeedResultItem(
                      heading: l10n.ping,
                      data: '0 MB/s',
                      icon: 'download.png',
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 30,
                ),
                child: PrimaryButton(
                  label: l10n.startSpeedTest,
                  isLoading: false,
                  onClicked: () {},
                  borderRadius: 10,
                  height: 52.h,
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

  static const _iconBgDecoration = BoxDecoration(
    shape: BoxShape.circle,
    color: Color(0xFFF9F2F6),
  );
  static final _headingStyle = TextStyle(
    color: AppColor.kBodyTextGrey,
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    fontFamily: 'GeneralSans',
  );
  static final _dataStyle = TextStyle(
    color: AppColor.kTextSecondaryDark,
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    height: 1.30,
    fontFamily: 'GeneralSans',
  );

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
          decoration: _iconBgDecoration,
          child: Image.asset(
            'assets/icons/$icon',
            color: AppColor.kPrimaryColor,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 5,
          children: [
            Text(heading, style: _headingStyle),
            Expanded(child: Text(data, style: _dataStyle)),
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

  static final _headingStyle = TextStyle(
    color: AppColor.kBodyTextGrey,
    fontSize: 10.sp,
    fontWeight: FontWeight.w400,
    fontFamily: 'GeneralSans',
  );
  // fontSize: 16 is a literal — const-constructible TextStyle.
  static const _dataStyle = TextStyle(
    color: AppColor.kTextSecondaryDark,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.30,
    fontFamily: 'GeneralSans',
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 10,
      children: [
        Image.asset('assets/icons/$icon', height: 24.h, width: 24.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 5,
          children: [
            Text(heading, style: _headingStyle),
            Text(data, style: _dataStyle),
          ],
        ),
      ],
    );
  }
}
