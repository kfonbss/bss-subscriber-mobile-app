import 'dart:math' show pi;

import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/shared/widgets/common_app_bar.dart';

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
  // kPrimaryColor(0xFF8D0247) @ 15% opacity: 0.15 × 255 ≈ 38 = 0x26
  static const _progressBgColor = Color(0x268D0247);
  // Dialog shape — shared between success and failure dialogs.
  static const _dialogShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(20)),
  );
  // OutlinedButton.styleFrom() is not const — computed once as static final.
  static final _cancelButtonStyle = OutlinedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 14),
    side: const BorderSide(color: AppColor.kPrimaryColor),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
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
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: _dialogShape,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/modem_restart_success.png', height: 100.h),
              const SizedBox(height: 24),
              Text(
                context.bssSubL10n.modemRestartedSuccessfully,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                context.bssSubL10n.modemRestartedDescription,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColor.kTextSecondaryDark,
                  fontWeight: FontWeight.w400,
                  fontSize: 14.sp,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();
                  },
                  child: Text(context.bssSubL10n.ok),
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
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: _dialogShape,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/modem_restart_fail.png', height: 100.h),
              const SizedBox(height: 24),
              Text(
                context.bssSubL10n.restartFailed,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                context.bssSubL10n.restartFailedDescription,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColor.kTextSecondaryDark,
                  fontWeight: FontWeight.w400,
                  fontSize: 14.sp,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _onRestartPressed();
                  },
                  child: Text(context.bssSubL10n.retry),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();
                  },
                  style: _cancelButtonStyle,
                  child: Text(context.bssSubL10n.cancel),
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
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _state == _RestartState.loading
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
        SizedBox(height: 40.h),
        Image.asset('assets/images/modem_restart_image.png', height: 100.h),
        const SizedBox(height: 32),
        Text(
          context.bssSubL10n.restartYourModem,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Text(
          context.bssSubL10n.restartYourModemDescription,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColor.kLabelGrey,
            fontSize: 13,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _onRestartPressed,
            child: Text(
              context.bssSubL10n.restartNow,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        const _PillSpinner(size: 120, color: AppColor.kPrimaryColor),
        const SizedBox(height: 32),
        Text(
          context.bssSubL10n.restartingModem,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
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
        const SizedBox(height: 40),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.bssSubL10n.restartingDots,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
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
                    valueColor: const AlwaysStoppedAnimation<Color>(
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

      final paint = Paint()
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
