import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:flutter/material.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_app_bar.dart';

class ConnectedDevicesPage extends StatelessWidget {
  const ConnectedDevicesPage({super.key});

  Widget _createOptionLayout(String heading, String subHeading, String icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              spacing: 16,
              children: [
                Container(
                  width: 53.w,
                  height: 53.h,
                  padding: const EdgeInsets.all(14),
                  decoration: ShapeDecoration(
                    color: const Color(0x0C8D0247),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  child: Image.asset('assets/icons/$icon'),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 6,
                  children: [
                    Text(
                      heading,
                      style: TextStyle(
                        color: AppColor.kTextSecondaryDark,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        height: 1.30,
                      ),
                    ),
                    Text(
                      'ast sync: $subHeading',
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.70),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        height: 1.30,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Icon(Icons.more_vert, color: Colors.grey.shade500, size: 16.0),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CommonAppBar(
      onBackPressed: () => Navigator.pop(context),
      title: 'Device Management',
      body: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20, top: 0, bottom: 20),
        child: Column(
          spacing: 18,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Connected Devices',
                  style: TextStyle(
                    color: AppColor.kTextSecondaryDark,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.40,
                  ),
                ),
                Image.asset(
                  'assets/icons/refresh.png',
                  width: 20,
                  height: 20,
                  fit: BoxFit.cover,
                )
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 1, // e.g., length of a list of data
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      _createOptionLayout(
                        'Living Room TV',
                        '2 mins ago',
                        'tv.png',
                      ),
                      _createOptionLayout(
                        'My Phone',
                        '2 mins ago',
                        'mobile_two.png',
                      ),
                      _createOptionLayout(
                        'IQOO Neo 9 Pro',
                        '2 mins ago',
                        'mobile_two.png',
                      ),
                      _createOptionLayout(
                        'Kfon Laptop',
                        '2 mins ago',
                        'laptop.png',
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
