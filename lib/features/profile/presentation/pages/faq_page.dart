import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/profile/presentation/components/faq_tile.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_app_bar.dart';

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
            fontFamily: 'GeneralSans',
            color: const Color(0xFF0F1121),
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            height: 1.3,
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
              question: '${index + 1}. ${item.question}',
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
    // Sample FAQ data - replace with actual data from API
    final accountFaqs = [
      FaqItem(
        question: 'How can I pay my bill online?',
        answer:
            'Go to "Wallet / Payments" → Choose payment method → Proceed to Pay.',
      ),
      FaqItem(
        question: 'What payment modes are accepted?',
        answer:
            'We accept various payment methods including credit cards, debit cards, UPI, and net banking.',
      ),
      FaqItem(
        question: 'My internet speed is slow. What should I do?',
        answer:
            'Please check your connection, restart your router, or contact our support team for assistance.',
      ),
    ];

    final paymentsFaqs = [
      FaqItem(
        question: 'How can I pay my bill online?',
        answer:
            'Go to "Wallet / Payments" → Choose payment method → Proceed to Pay.',
      ),
      FaqItem(
        question: 'What payment modes are accepted?',
        answer:
            'We accept various payment methods including credit cards, debit cards, UPI, and net banking.',
      ),
      FaqItem(
        question: 'My internet speed is slow. What should I do?',
        answer:
            'Please check your connection, restart your router, or contact our support team for assistance.',
      ),
    ];

    return CommonAppBar(
      onBackPressed: () => Navigator.pop(context),
      title: 'FAQs',
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
                  _buildSection(title: 'Account', items: accountFaqs),
                  // Payments Section
                  _buildSection(title: 'Payments', items: paymentsFaqs),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
