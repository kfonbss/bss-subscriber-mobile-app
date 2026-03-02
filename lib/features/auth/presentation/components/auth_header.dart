import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';

class AuthHeader extends StatelessWidget {
  final String heading;
  final String description;
  final String? clickableText;
  final VoidCallback onClicked;

  const AuthHeader({
    super.key,
    required this.heading,
    required this.description,
    this.clickableText,
    required this.onClicked,
  });

  @override
  Widget build(BuildContext context) {
    // Tablet-responsive values
    final isTablet = Sizer.isTablet;
    // Top spacing: Smaller on tablet for better proportions
    final topSpacing = isTablet ? 60.h : 112.0;
    final logoWidth = isTablet
        ? 150.0 // Smaller, more proportional size for tablet
        : MediaQuery.of(context).size.width * 0.31; // Original mobile logic
    // Heading spacing: Smaller on tablet
    final headingSpacing = isTablet ? 12.h : 20.0;
    final headingFontSize = isTablet
        ? 24.sp
        : 32.0; // Smaller heading for tablet
    // Bottom spacing: Smaller on tablet
    final bottomSpacing = isTablet ? 32.h : 48.0;
    // Description padding: Different structure, needs conditional
    final descriptionPadding = isTablet
        ? EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h)
        : const EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 45);
    final descriptionFontSize = isTablet ? 14.sp : 12.0;

    return Column(
      children: [
        SizedBox(height: topSpacing),
        Image.asset(
          'assets/images/kfone_white.png',
          width: logoWidth,
          fit: BoxFit.fitWidth,
        ),
        SizedBox(height: headingSpacing),
        Text(
          heading,
          style: TextStyle(
            fontSize: headingFontSize,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontFamily: 'GeneralSans',
          ),
        ),

        if (description.isNotEmpty)
          Padding(
            padding: descriptionPadding,
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: description,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: descriptionFontSize,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'GeneralSans',
                ),
                // children: <TextSpan>[
                //   TextSpan(
                //     text: clickableText ?? '',
                //     style: TextStyle(
                //       color: Colors.white,
                //       fontWeight: FontWeight.w600,
                //       decoration: TextDecoration.underline,
                //       decorationColor: Colors.white,
                //       fontSize: 12,
                //     ),
                //     recognizer:
                //         TapGestureRecognizer()
                //           ..onTap = onClicked, // Assign the TapGestureRecognizer
                //   ),
                // ],
              ),
            ),
          )
        else
          SizedBox(height: bottomSpacing),
      ],
    );
  }
}
