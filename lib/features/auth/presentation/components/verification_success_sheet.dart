import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/routes/app_routes.dart';
import 'package:kfon_subscriber/presentation/ui_component/primary_button.dart';


class VerificationSuccessSheet extends StatelessWidget {
  const VerificationSuccessSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Success Icon
          Image.asset('assets/images/account_verified.png', width: 100, height: 100),
          const SizedBox(height: 24),

          // Title
          Text(
            'Account Verified! 🎉',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 12),

          // Description
          Text(
            'Congratulations! your account has been verified from our system. Please login first before enjoy our amazing experience. We hope you enjoy it!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColor.kBodyTextGrey,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 32),

          // Start Now Button
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              label: 'Start Now',
              borderRadius: 10,
              height: 52,
              isLoading: false,
              onClicked: () {
                Navigator.of(context).pop(); // Close bottom sheet
                Navigator.pushReplacementNamed(context, AppRoutes.mainPage
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
