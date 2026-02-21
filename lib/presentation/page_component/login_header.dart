import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
class LoginHeader extends StatelessWidget {
  final String heading;
  final String description;
  final String? clickableText;
  final VoidCallback onClicked;

  const LoginHeader({
    super.key,
    required this.heading,
    required this.description,
    this.clickableText,
    required this.onClicked,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 120.0,
            right: 120,
            bottom: 20,
            top: 100,
          ),
          child: Image.asset('assets/images/kfone_white.png'),
        ),
        Text(
          heading,
          style: TextStyle(
            fontSize: 32.sp,
            fontFamily: 'General Sans',
            fontWeight: FontWeight.w500,
            height: 1.30,
            color: Colors.white,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 24,
            right: 24,
            top: 12,
            bottom: 45,
          ),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: description,
              style: TextStyle(
                fontFamily: 'General Sans',
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: clickableText ?? '',
                  style: TextStyle(
                    fontFamily: 'General Sans',
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white,
                    fontSize: 12.sp,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = onClicked,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
