import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/data_usage/presentation/pages/restart_modem_page.dart';
import 'package:kfon_subscriber/features/profile/presentation/pages/security_settings_page.dart';
import 'package:kfon_subscriber/features/self_care/presentation/pages/connected_devices_page.dart';
import 'package:kfon_subscriber/features/self_care/presentation/pages/speed_test_page.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_app_bar.dart';


class DiagnosticsPage extends StatelessWidget {
  const DiagnosticsPage({super.key});

  Widget _createOptionLayout(String heading, String subHeading, String icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 19),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(                         // 👈 fix: constrain row content
              child: Row(
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
                  Expanded(                   // 👈 fix: let text wrap freely
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          heading,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14.sp,
                            fontFamily: 'General Sans',
                            fontWeight: FontWeight.w600,
                            height: 1.50,
                          ),
                        ),
                        if (subHeading.isNotEmpty)
                          Text(
                            subHeading,
                            style: TextStyle(
                              color: Colors.black.withValues(alpha: 0.70),
                              fontSize: 12.sp,
                              fontFamily: 'General Sans',
                              fontWeight: FontWeight.w400,
                              height: 1.30,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.grey.shade500,
              size: 16.0,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CommonAppBar(
      onBackPressed: () => Navigator.pop(context),
      title: 'Self-Care/Tools',
      body: Padding(
        padding: const EdgeInsets.only(
          left: 20.0,
          right: 20,
          top: 0,
          bottom: 20,
        ),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const RestartModemPage(),
                ),
              ),
              child: _createOptionLayout(
                'Restart Modem/Refresh Connection',
                '',
                'connected_devices.png',
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const SpeedTestPage(),
                ),
              ),
              child: _createOptionLayout(
                'Network Health Check',
                'Ping / Speed Test',
                'speed_test.png',
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => ConnectedDevicesPage(),
                ),
              ),
              child: _createOptionLayout(
                'Device Management',
                'Manage your connected devices',
                'ping.png',
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => SecuritySettingsPage(
                    types: [PasswordChangeEnum.ssid, PasswordChangeEnum.wifi],
                  ),
                ),
              ),
              child: _createOptionLayout(
                'Change SSID / Wi-Fi Password',
                '',
                'traceroute.png',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
