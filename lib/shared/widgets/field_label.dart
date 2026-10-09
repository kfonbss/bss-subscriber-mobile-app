import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:flutter/material.dart';

/// The caption above a form field, with a red asterisk when the field is
/// required. Shared so a label sitting over a dropdown or a custom input
/// matches the one [CommonTextField] draws.
class FieldLabel extends StatelessWidget {
  const FieldLabel({super.key, required this.label, this.isMandatory = false});

  final String label;
  final bool isMandatory;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: label,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF0F1121),
          height: 1.3.h,
          fontFamily: 'General Sans',
        ),
        children: [
          if (isMandatory)
            const TextSpan(
              text: '*',
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }
}
