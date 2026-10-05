import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/app_brand.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/core/constant/app_assets.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';

class AuthHeader extends StatelessWidget {
  final String? heading;
  final String description;

  /// Space above the logo. Defaults to the login design (65); pages with a
  /// back button (e.g. forgot password: 104.5) pass their own.
  final double? topSpacing;

  /// Part of [description] shown in semi-bold (e.g. the mobile number).
  final String? descriptionHighlight;

  /// Space below the heading when there's no description. Defaults to the
  /// login design (53).
  final double? bottomSpacing;

  const AuthHeader({
    super.key,
    this.heading,
    required this.description,
    this.topSpacing,
    this.descriptionHighlight,
    this.bottomSpacing,
  });

  // Sizer ratios and Sizer.isTablet are fixed after MaterialApp.builder —
  // computed once as static final, eliminating per-build allocations.
  static final double _topSpacing = Sizer.isTablet ? 60.h : 65.h;
  static final double _headingSpacing = Sizer.isTablet ? 12.h : 16.h;

  // Heading bottom → selected-circle card top (224) in the login design.
  static final double _bottomSpacing = Sizer.isTablet ? 32.h : 53.h;
  static final EdgeInsets _descriptionPadding =
      Sizer.isTablet
          ? EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h)
          : EdgeInsets.only(left: 24.w, right: 24.w, top: 12.h, bottom: 32.h);
  static final _headingStyle = TextStyle(
    fontSize: Sizer.isTablet ? 24.sp : 32.sp,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    fontFamily: 'GeneralSans',
    height: 1.30,
    letterSpacing: -0.64,
  );
  static final _descriptionStyle = TextStyle(
    color: Colors.white,
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    fontFamily: 'GeneralSans',
    height: 1.65,
    letterSpacing: -0.14,
  );

  TextSpan _buildDescription() {
    final highlight = descriptionHighlight;
    final start =
        (highlight == null || highlight.isEmpty)
            ? -1
            : description.indexOf(highlight);
    if (start < 0) {
      return TextSpan(text: description, style: _descriptionStyle);
    }
    final end = start + highlight!.length;
    return TextSpan(
      style: _descriptionStyle,
      children: [
        TextSpan(text: description.substring(0, start)),
        TextSpan(
          text: highlight,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        TextSpan(text: description.substring(end)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: topSpacing ?? _topSpacing),
        Sizer.isTablet
            ? Image.asset(AppAssets.kLogo, width: 150.0, fit: BoxFit.fitWidth)
            : Image.asset(
              AppAssets.kLogo,
              width: 77.w,
              height: 48.h,
              fit: BoxFit.contain,
            ),
        SizedBox(height: _headingSpacing),
        Text(
          heading ?? context.bssSubL10n.welcomeText(AppBrand.appName),
          textAlign: TextAlign.center,
          style: _headingStyle,
        ),

        if (description.isNotEmpty)
          Padding(
            padding: _descriptionPadding,
            child: RichText(
              textAlign: TextAlign.center,
              text: _buildDescription(),
            ),
          )
        else
          SizedBox(height: bottomSpacing ?? _bottomSpacing),
      ],
    );
  }
}
