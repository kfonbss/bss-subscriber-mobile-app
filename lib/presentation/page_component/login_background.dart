import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';

class LoginBackground extends StatelessWidget {
  final String heading;
  final Widget child;
  final double height;
  final double bottomMargin;

  const LoginBackground({
    super.key,
    required this.heading,
    required this.height,
    required this.bottomMargin,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 120.0,right: 120,bottom: 16),
          child: Image.asset('assets/images/kfone_white.png'),
        ),
        Text('Welcome to KFON')
      ],
    );
  }
}
