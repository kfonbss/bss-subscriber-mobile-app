import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant.dart';

class SecondaryButton extends StatelessWidget {
  final Widget? icon;
  final String label;
  final VoidCallback onClicked;

  const SecondaryButton({
    super.key,
    this.icon,
    required this.label,
    required this.onClicked,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onClicked,
      icon:icon,
      label: Text(label),
      iconAlignment: IconAlignment.start,
      style: FilledButton.styleFrom(
        minimumSize: Size(double.infinity, 50),
        backgroundColor: Colors.white,
        foregroundColor: kPrimaryColor,
        side: BorderSide(
          color: kPrimaryColor, // Border color
          width: 1, // Border width
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }
}
