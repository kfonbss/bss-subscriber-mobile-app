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

class SpeedTestPage extends StatelessWidget {
  const SpeedTestPage({super.key});

  // ── Static decorations ───────────────────────────────────────────────────────
  static const _resultsCardDecoration = BoxDecoration(
    color: Colors.white,
    border: Border.fromBorderSide(
      BorderSide(color: AppColor.kinputFiledLightBorder),
    ),
    borderRadius: BorderRadius.all(Radius.circular(12)),
  );
  // Design: server card 335 wide at y=134.
  static const _serverCardPadding = EdgeInsets.only(
    left: 20,
    right: 20,
    top: 134,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;
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
            children: <Widget>[
              SizedBox(
                width: double.infinity,
                height: 191.h,
                child: SvgPicture(
                  SvgAssetLoader(
                    AppAssets.speedTestBackground,
                    colorMapper: TenantSvgColorMapper(),
                  ),
                  fit: BoxFit.fill,
                ),
              ),
              Padding(
                padding: _serverCardPadding,
                child: Card(
                  // No default 4 margin, so the card is the full 335 wide.
                  margin: EdgeInsets.zero,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16.0)),
                  ),
                  color: Colors.white,
                  elevation: 4.0,
                  child: Container(
                    height: 70.h,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _ServerLocItem(
                          heading: l10n.server,
                          data: 'Kfon.in',
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
                        width: 0.2.w,
                        color: AppColor.kPrimaryColor,
                        sizeUnit: GaugeSizeUnit.factor,
                      ),
                    ],
                    axisLabelStyle: GaugeTextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'GeneralSans',
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
              // Design: 68 tall, content 16 inside, #EAEAEA border.
              Container(
                height: 68.h,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: _resultsCardDecoration,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _SpeedResultItem(
                      heading: l10n.uploadSpeed,
                      data: '0 MB/s',
                      icon: AppAssets.upload,
                    ),
                    _SpeedResultItem(
                      heading: l10n.downloadSpeed,
                      data: '0 MB/s',
                      icon: AppAssets.download,
                    ),
                    _SpeedResultItem(
                      heading: l10n.ping,
                      data: '0 MB/s',
                      icon: AppAssets.ping,
                    ),
                  ],
                ),
              ),
              // Design: results card ends at 596, button at 694–746.
              Padding(
                padding: EdgeInsets.fromLTRB(20, 98.h, 20, 32.h + bottomInset),
                child: PrimaryButton(
                  label: l10n.startSpeedTest,
                  isLoading: false,
                  onClicked: () {},
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
    // Design: 24 icon, text 8 after it, no gap between label and value.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 8,
      children: [
        SvgPicture.asset(
          icon,
          height: 24.h,
          width: 24.w,
          colorFilter: ColorFilter.mode(
            AppColor.kPrimaryColor,
            BlendMode.srcIn,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(heading, style: _headingStyle),
            Text(data, style: _dataStyle),
          ],
        ),
      ],
    );
  }
}
