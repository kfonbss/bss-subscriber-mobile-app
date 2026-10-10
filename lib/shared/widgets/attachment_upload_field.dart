import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/core/constant/app_assets.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';

/// Reusable attachment upload field with dashed border.
/// Used in Create Ticket, Submit GSTR, Add CAF Details, etc.
class AttachmentUploadField extends StatelessWidget {
  const AttachmentUploadField({
    super.key,
    required this.label,
    required this.onTap,
    this.height = 66,
    this.isMandatory = false,
    this.value,
    this.validator,
  });

  final String label;
  final VoidCallback onTap;
  final double height;
  final bool isMandatory;
  final String? value;
  final FormFieldValidator<String>? validator;

  static const _kLabelStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColor.kTextSecondaryDark,
    height: 1.3,
    fontFamily: 'GeneralSans',
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;

    return FormField<String>(
      key: ValueKey(value),
      initialValue: value,
      validator: validator,
      builder: (state) {
        final hasError = state.hasError;
        final color =
            hasError ? AppColor.kAttachmentErrorRed : AppColor.kPrimaryColor;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isMandatory ? '$label*' : label, style: _kLabelStyle),
            SizedBox(height: 8.h),
            GestureDetector(
              onTap: onTap,
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomPaint(
                  painter: DashedBorderPainter(
                    color: color,
                    strokeWidth: 1.0,
                    dashWidth: 5.0,
                    dashSpace: 4.0,
                    borderRadius: 12.0,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          AppAssets.documentUpload,
                          width: 24.w,
                          height: 24.h,
                          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          l10n.attachment,
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 1.6,
                            fontFamily: 'GeneralSans',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (hasError) ...[
              SizedBox(height: 6.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColor.kAttachmentErrorRed,
                    size: 14,
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      state.errorText!,
                      style: const TextStyle(
                        color: AppColor.kAttachmentErrorRed,
                        fontSize: 12,
                        fontFamily: 'GeneralSans',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Shared dashed border painter for attachment / upload areas.
class DashedBorderPainter extends CustomPainter {
  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.dashWidth = 5.0,
    this.dashSpace = 4.0,
    this.borderRadius = 12.0,
  });

  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke;

    final path =
        Path()..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(0, 0, size.width, size.height),
            Radius.circular(borderRadius),
          ),
        );

    final dashPath = _dashPath(path, dashWidth, dashSpace);
    canvas.drawPath(dashPath, paint);
  }

  Path _dashPath(Path path, double dashWidth, double dashSpace) {
    final dashPath = Path();
    final pathMetrics = path.computeMetrics();

    for (final pathMetric in pathMetrics) {
      double distance = 0;
      while (distance < pathMetric.length) {
        final extractPath = pathMetric.extractPath(
          distance,
          (distance + dashWidth).clamp(0.0, pathMetric.length),
        );
        dashPath.addPath(extractPath, Offset.zero);
        distance += dashWidth + dashSpace;
      }
    }

    return dashPath;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
