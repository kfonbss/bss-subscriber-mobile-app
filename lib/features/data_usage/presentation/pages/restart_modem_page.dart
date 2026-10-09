import 'dart:math' show pi;

import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/shared/widgets/common_app_bar.dart';
import 'package:kfon_subscriber/core/constant/app_assets.dart';
import 'package:kfon_subscriber/shared/widgets/primary_button.dart';
import 'package:kfon_subscriber/shared/widgets/secondary_button.dart';

enum _RestartState { initial, loading, success, failed }

class RestartModemPage extends StatefulWidget {
  const RestartModemPage({super.key});

  @override
  State<RestartModemPage> createState() => _RestartModemPageState();
}

class _RestartModemPageState extends State<RestartModemPage>
    with SingleTickerProviderStateMixin {
  _RestartState _state = _RestartState.initial;
  late AnimationController _progressController;

  // ── Hoisted to avoid per-frame allocations inside AnimatedBuilder ────────────
  // BorderRadius.circular(N) is not const; BorderRadius.all(Radius.circular(N)) is.
  static const _progressBarRadius = BorderRadius.all(Radius.circular(4));
  // kPrimaryColor(0xFF1095C5) @ 15% opacity: 0.15 × 255 ≈ 38 = 0x26
  static get _progressBgColor => AppColor.kPrimary15;
  // Dialog shape — shared between success and failure dialogs.
  static const _dialogShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(20)),
  );


  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _onRestartPressed() async {
    setState(() => _state = _RestartState.loading);
    _progressController.forward(from: 0);

    // TODO: Replace with actual API call
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;
    _progressController.stop();

    // _showSuccessDialog();
    _showFailedDialog();
  }

  // ignore: unused_element
  void _showSuccessDialog() {
    setState(() => _state = _RestartState.success);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => Dialog(
            backgroundColor: Colors.white,
            shape: _dialogShape,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(AppAssets.modemRestartSuccess, height: 100.h),
                  SizedBox(height: 24.h),
                  Text(
                    context.bssSubL10n.modemRestartedSuccessfully,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    context.bssSubL10n.modemRestartedDescription,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColor.kTextSecondaryDark,
                      fontWeight: FontWeight.w400,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 32.h),
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      label: context.bssSubL10n.ok,
                      isLoading: false,
                      borderRadius: 10,
                      onClicked: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showFailedDialog() {
    setState(() => _state = _RestartState.failed);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => Dialog(
            backgroundColor: Colors.white,
            shape: _dialogShape,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(AppAssets.modemRestartFail, height: 100.h),
                  SizedBox(height: 24.h),
                  Text(
                    context.bssSubL10n.restartFailed,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    context.bssSubL10n.restartFailedDescription,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColor.kTextSecondaryDark,
                      fontWeight: FontWeight.w400,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 32.h),
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      label: context.bssSubL10n.retry,
                      isLoading: false,
                      borderRadius: 10,
                      onClicked: () {
                        Navigator.of(ctx).pop();
                        _onRestartPressed();
                      },
                    ),
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    child: SecondaryButton(
                      label: context.bssSubL10n.cancel,
                      borderRadius: 10,
                      onClicked: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CommonAppBar(
      onBackPressed: () => Navigator.pop(context),
      title: context.bssSubL10n.restartModem,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child:
              _state == _RestartState.loading
                  ? _buildLoadingState()
                  : _buildInitialState(),
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Design: content starts 60 below the toolbar; CommonAppBar's
        // bottom margin covers ~29 of that.
        SizedBox(height: 32.h),
        Image.asset(AppAssets.modemRestartImage, width: 100.w, height: 100.w),
        SizedBox(height: 40.h),
        Text(
          context.bssSubL10n.restartYourModem,
          style: TextStyle(
            fontFamily: 'GeneralSans',
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            height: 1.30,
            color: AppColor.kTextSecondaryDark,
          ),
        ),
        SizedBox(height: 12.h),
        // Design: description is 299 wide inside the 335 column.
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: Text(
            context.bssSubL10n.restartYourModemDescription,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              height: 1.54,
              color: AppColor.kDarkBlue,
            ),
          ),
        ),
        SizedBox(height: 40.h),
        SizedBox(
          width: double.infinity,
          height: 52.h,
          child: PrimaryButton(
            label: context.bssSubL10n.restartNow,
            isLoading: false,
            borderRadius: 8,
            height: 52.h,
            textStyle: TextStyle(
              fontFamily: 'GeneralSans',
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            onClicked: _onRestartPressed,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 40.h),
        _PillSpinner(size: 120, color: AppColor.kPrimaryColor),
        SizedBox(height: 32.h),
        Text(
          context.bssSubL10n.restartingModem,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        Text(
          context.bssSubL10n.restartingModemDescription,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColor.kLabelGrey,
            fontSize: 13,
            height: 1.5,
          ),
        ),
        SizedBox(height: 40.h),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.bssSubL10n.restartingDots,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8.h),
            AnimatedBuilder(
              animation: _progressController,
              builder: (context, child) {
                // _progressBarRadius and _progressBgColor are static const —
                // no new objects allocated per animation frame.
                return ClipRRect(
                  borderRadius: _progressBarRadius,
                  child: LinearProgressIndicator(
                    value: _progressController.value,
                    minHeight: 8,
                    backgroundColor: _progressBgColor,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColor.kPrimaryColor,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

/// Custom spinning loader with pill-shaped segments arranged in a circle
class _PillSpinner extends StatefulWidget {
  const _PillSpinner({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  State<_PillSpinner> createState() => _PillSpinnerState();
}

class _PillSpinnerState extends State<_PillSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _PillSpinnerPainter(
            color: widget.color,
            progress: _controller.value,
          ),
        );
      },
    );
  }
}

class _PillSpinnerPainter extends CustomPainter {
  _PillSpinnerPainter({required this.color, required this.progress});

  final Color color;
  final double progress;
  static const int pillCount = 12;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const pillWidth = 8.0;
    const pillHeight = 22.0;

    canvas.save();
    canvas.translate(center.dx, center.dy);

    final activeIndex = (progress * pillCount).floor() % pillCount;

    for (int i = 0; i < pillCount; i++) {
      final angle = (i * 360 / pillCount) * (pi / 180);

      // Active pill is brightest, others fade away
      final distance = (i - activeIndex) % pillCount;
      final opacity = 1.0 - (distance / pillCount) * 0.7;

      final paint =
          Paint()
            ..color = color.withValues(alpha: opacity.clamp(0.3, 1.0))
            ..style = PaintingStyle.fill;

      canvas.save();
      canvas.rotate(angle);
      canvas.translate(0, -radius);

      final rrect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset.zero,
          width: pillWidth,
          height: pillHeight,
        ),
        const Radius.circular(pillWidth / 2),
      );
      canvas.drawRRect(rrect, paint);

      canvas.restore();
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_PillSpinnerPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
