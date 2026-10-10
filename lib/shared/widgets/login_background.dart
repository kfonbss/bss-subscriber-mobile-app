import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kfon_subscriber/core/constant/app_assets.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';

class LoginBackground extends StatelessWidget {
  /// Background colour behind the pattern; defaults to the tenant primary.
  final Color? color;

  const LoginBackground({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ColoredBox(color: color ?? AppColor.kPrimaryColor),
        ),
        Positioned.fill(
          child: SvgPicture.asset(AppAssets.loginBackground, fit: BoxFit.cover),
        ),
        // നിങ്ങളുടെ form ഇവിടെ
      ],
    );
  }
}
