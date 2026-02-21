import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';

import '../../core/constant/constant_dimensions.dart';

class SignInButton extends StatelessWidget {
  final String label;
  final VoidCallback onClicked;

  const SignInButton({super.key, required this.label, required this.onClicked});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onClicked,
      style: FilledButton.styleFrom(
        elevation: 0,
        minimumSize: Size(double.infinity, 50),
        fixedSize: Size(double.infinity, 50),
        backgroundColor: const Color.fromRGBO(255, 255, 255, 0.2),
        foregroundColor: Colors.white,
        padding: EdgeInsets.zero,
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }
}
