import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/pages/faq/faq_tile.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/shared/widgets/common_app_bar.dart';

class FaqItem {
  final String question;
  final String answer;

  FaqItem({required this.question, required this.answer});
}

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  Widget _buildSection({required String title, required List<FaqItem> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'General Sans',
            color: const Color(0xFF0F1121),
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            height: 1.3.h,
            letterSpacing: 0,
          ),
        ),
        SizedBox(height: 10.h),
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < items.length - 1 ? 10.h : 0,
            ),
            child: FaqTile(
              questionNo: index + 1,
              question: item.question,
              answer: item.answer,
            ),
          );
        }),
        SizedBox(height: 20.h),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;
    // Sample FAQ data - replace with actual data from API
    final accountFaqs = [
      FaqItem(
        question: context.bssSubL10n.howCanIPayMyBillOnline,
        answer: context.bssSubL10n.goToWalletPaymentsChoosePaymentMethod,
      ),
      FaqItem(
        question: context.bssSubL10n.whatPaymentModesAreAccepted,
        answer: context.bssSubL10n.weAcceptVariousPaymentMethodsIncludingCredit,
      ),
      FaqItem(
        question: context.bssSubL10n.myInternetSpeedIsSlowWhatShould,
        answer: context.bssSubL10n.pleaseCheckYourConnectionRestartYourRouter,
      ),
    ];

    final paymentsFaqs = [
      FaqItem(
        question: context.bssSubL10n.howCanIPayMyBillOnline,
        answer: context.bssSubL10n.goToWalletPaymentsChoosePaymentMethod,
      ),
      FaqItem(
        question: context.bssSubL10n.whatPaymentModesAreAccepted,
        answer: context.bssSubL10n.weAcceptVariousPaymentMethodsIncludingCredit,
      ),
      FaqItem(
        question: context.bssSubL10n.myInternetSpeedIsSlowWhatShould,
        answer: context.bssSubL10n.pleaseCheckYourConnectionRestartYourRouter,
      ),
    ];

    return CommonAppBar(
      onBackPressed: () => Navigator.pop(context),
      title: l10n.faqs,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 50.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Account Section
                  _buildSection(title: l10n.account, items: accountFaqs),
                  // Payments Section
                  _buildSection(title: l10n.payments, items: paymentsFaqs),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}