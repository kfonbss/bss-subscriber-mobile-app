import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_app_bar.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../../../../presentation/ui_component/primary_button.dart' show PrimaryButton;

class SpeedTestPage extends StatelessWidget {
  const SpeedTestPage({super.key});

  Widget _createServerLocLayout(String heading, String data, String icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 10,
      children: [
        Container(
          width: 38.w,
          height: 38.h,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFF9F2F6),
          ),
          child: Image.asset('assets/icons/$icon'),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 5,
          children: [
            Text(
              heading,
              style: TextStyle(
                color: const Color(0xFF636363),
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                fontFamily: 'General Sans',
              ),
            ),
            Text(
              data,
              style: TextStyle(
                color: AppColor.kTextSecondaryDark,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                height: 1.30,
                fontFamily: 'General Sans',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _createSpeedResultLayout(String heading, String data, String icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 10,
      children: [
        Image.asset('assets/icons/$icon', height: 24.h, width: 24.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 5,
          children: [
            Text(
              heading,
              style: TextStyle(
                color: const Color(0xFF636363),
                fontSize: 10.sp,
                fontWeight: FontWeight.w400,
                fontFamily: 'General Sans',
              ),
            ),
            Text(
              data,
              style: TextStyle(
                color: const Color(0xFF0F1121),
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.30,
                fontFamily: 'General Sans',
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CommonAppBar(
      onBackPressed: () => Navigator.pop(context),
      title: 'Speed Test',
      appbarColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      circleColor: Colors.white,
      titleColor: Colors.white,
      body: Column(
        children: [
          Stack(
            alignment: Alignment.topCenter, // Align children to the top center
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
                padding: EdgeInsets.only(left: 20, right: 20, top: 130),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  color: Colors.white,
                  elevation: 4.0,
                  child: Container(
                    height: 75.h,
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _createServerLocLayout('Server', 'Kfon.in', 'glob.png'),
                        _createServerLocLayout(
                          'Location',
                          'Ernakulam',
                          'location.png',
                        ),
                      ],
                    ),
                    // Content of the Card
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
                        tailStyle: TailStyle(color: Colors.red, borderWidth: 10),
                        value: 80,
                        needleColor: AppColor.kPrimaryColor,
                        knobStyle: KnobStyle(
                          color: AppColor.kPrimaryColor,
                          borderWidth: 0,
                        ),
                        gradient: LinearGradient(
                          colors: [Color(0xFF8D0247), Color(0xFFF5F5F5)],
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
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _createSpeedResultLayout('Upload', '0 MB/s', 'upload.png'),
                    _createSpeedResultLayout('Download', '0 MB/s', 'download.png'),
                    _createSpeedResultLayout('Ping', '0 MB/s', 'download.png'),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 30),
                child: PrimaryButton(
                  label: 'Start Speed Test',
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
