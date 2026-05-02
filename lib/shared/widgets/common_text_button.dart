import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';

class CommonTextButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const CommonTextButton({super.key,required this.label,required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColor.kPrimaryColorTwo,
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: const TextStyle(fontSize: 15), // Text style
      ),
      child: Text(label,),
    );
  }
}
