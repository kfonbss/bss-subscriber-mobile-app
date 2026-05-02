import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/extensions.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';


/// Standard vertical spacing between the app bar and the body content.
const double kAppBarToContentSpacing = 0.0;

class CommonAppBar extends StatelessWidget {
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;
  final Widget body;
  final String title;
  final Color? scaffoldColor;
  final Color? appbarColor;
  final bool? extendBodyBehindAppBar;
  final Color? titleColor;
  final Color? circleColor;
  final Widget? floatingActionButton;
  final bool? centerTitle;
  final double? titleFontSize;

  /// Whether the body should resize when the keyboard appears.
  /// Defaults to `true` so pages with text fields are not obscured.
  /// Set to `false` only for pages that must not resize (e.g. map/camera views).
  final bool resizeToAvoidBottomInset;

  const CommonAppBar({
    super.key,
    this.actions,
    this.scaffoldColor,
    this.appbarColor,
    this.titleColor,
    this.circleColor,
    this.extendBodyBehindAppBar,
    this.onBackPressed,
    required this.title,
    required this.body,
    this.floatingActionButton,
    this.centerTitle,
    this.titleFontSize,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    final leftPadding = 20.w;
    final containerSize = context.isTablet ? 36.0 * 1.2 : 30.0.w;
    final iconSize = context.isTablet ? 20.0 * 1.2 : 15.w;
    final borderWidth = context.isTablet ? 1.0 * 1.2 : 1.w;
    final leadingWidth = onBackPressed != null
        ? (leftPadding + containerSize + 8.w)
        : 0.0;
    final topBottomMargin = 16.0;

    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBodyBehindAppBar: extendBodyBehindAppBar ?? false,
      backgroundColor: scaffoldColor ?? AppColor.kMainBackgroundColor,
      appBar: AppBar(
        backgroundColor: appbarColor ?? AppColor.kMainBackgroundColor,
        automaticallyImplyLeading: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight:
        56.0 +
            (topBottomMargin * 2), // Default 56 + top margin + bottom margin
        leadingWidth: leadingWidth,
        leading: onBackPressed != null
            ? Padding(
          padding: EdgeInsets.only(
            left: leftPadding,
            top: topBottomMargin,
            bottom: topBottomMargin,
          ),
          child: InkWell(
            onTap: onBackPressed,
            borderRadius: BorderRadius.circular(containerSize / 2),
            child: Container(
              width: containerSize,
              height: containerSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: circleColor ?? const Color(0x1A000000),
                  width: borderWidth,
                ),
              ),
              child: Center(
                child: SizedBox(
                  width: iconSize,
                  height: iconSize,
                  child:Icon(
                    Icons.arrow_back,
                    size:iconSize ,
                    color:titleColor ?? Colors.black ,
                  )
                ),
              ),
            ),
          ),
        )
            : null,
        title: Padding(
          padding: EdgeInsets.symmetric(vertical: topBottomMargin),
          child: Text(
            title,
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontWeight: FontWeight.w600,
              fontSize: titleFontSize??14.sp,
              color: titleColor ?? AppColor.kTextSecondaryDark,
              height: 1.3,
              letterSpacing: 0,
            ),
          ),
        ),
        centerTitle:centerTitle?? true,
        actions:
        actions
            ?.map(
              (action) => Padding(
            padding: EdgeInsets.symmetric(vertical: topBottomMargin),
            child: action,
          ),
        )
            .toList() ??
            [],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: kAppBarToContentSpacing),
        child: body,
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

