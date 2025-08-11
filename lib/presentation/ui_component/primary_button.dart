import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant.dart';

class PrimaryButton extends StatelessWidget {
  final Widget? icon;
  final String label;
  final bool isLoading;
  final VoidCallback onClicked;

  const PrimaryButton({
    super.key,
    this.icon,
    required this.label,
    required this.isLoading,
    required this.onClicked,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: isLoading ? null : onClicked,
      icon: isLoading ? null : icon,
      label:
          isLoading
              ? SizedBox(height:20,width:20,child: CircularProgressIndicator(color: Colors.white,strokeWidth: 3))
              : Text(label),
      iconAlignment: IconAlignment.end,
      style: FilledButton.styleFrom(
        minimumSize: Size(double.infinity, 50),
        fixedSize: Size(double.infinity, 50),
        disabledBackgroundColor: Colors.grey,
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }
}
