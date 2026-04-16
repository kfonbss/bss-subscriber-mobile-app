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

  // Sizer ratios and Sizer.isTablet are fixed after MaterialApp.builder —
  // computed once as static final, eliminating per-build allocations.
  static final double _topSpacing = Sizer.isTablet ? 60.h : 112.0;
  static final double _headingSpacing = Sizer.isTablet ? 12.h : 20.0;
  static final double _bottomSpacing = Sizer.isTablet ? 32.h : 48.0;
  static final EdgeInsets _descriptionPadding = Sizer.isTablet
      ? EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h)
      : const EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 45);
  static final _headingStyle = TextStyle(
    fontSize: Sizer.isTablet ? 24.sp : 32.0,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    fontFamily: 'GeneralSans',
  );
  static final _descriptionStyle = TextStyle(
    color: Colors.white,
    fontSize: Sizer.isTablet ? 14.sp : 12.0,
    fontWeight: FontWeight.w500,
    fontFamily: 'GeneralSans',
  );

  @override
  Widget build(BuildContext context) {
    // logoWidth depends on MediaQuery (changes on rotation) — not static.
    final logoWidth = Sizer.isTablet
        ? 150.0
        : MediaQuery.sizeOf(context).width * 0.31;

    return Column(
      children: [
        SizedBox(height: _topSpacing),
        Image.asset(
          'assets/images/kfone_white.png',
          width: logoWidth,
          fit: BoxFit.fitWidth,
        ),
        SizedBox(height: _headingSpacing),
        Text(heading, style: _headingStyle),

        if (description.isNotEmpty)
          Padding(
            padding: _descriptionPadding,
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: description,
                style: _descriptionStyle,
              ),
            ),
          )
        else
          SizedBox(height: _bottomSpacing),
      ],
    );
  }
}
