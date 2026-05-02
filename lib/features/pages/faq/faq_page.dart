import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/pages/faq/faq_tile.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/shared/widgets/common_app_bar.dart';

class FaqItem {
  final String question;
  final String answer;

  FaqItem({required this.question, required this.answer});
}

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  late List<FaqItem> _accountFaqs;
  late List<FaqItem> _paymentsFaqs;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = context.bssSubL10n;
    _accountFaqs = [
      FaqItem(question: l10n.faqAccountQ1, answer: l10n.faqAccountA1),
      FaqItem(question: l10n.faqAccountQ2, answer: l10n.faqAccountA2),
      FaqItem(question: l10n.faqAccountQ3, answer: l10n.faqAccountA3),
    ];
    _paymentsFaqs = [
      FaqItem(question: l10n.faqPaymentsQ1, answer: l10n.faqPaymentsA1),
      FaqItem(question: l10n.faqPaymentsQ2, answer: l10n.faqPaymentsA2),
      FaqItem(question: l10n.faqPaymentsQ3, answer: l10n.faqPaymentsA3),
    ];
  }

  Widget _buildSection({
    required String title,
    required List<FaqItem> items,
    required TextStyle? titleStyle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: titleStyle),
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
    final titleStyle = TextStyle(
      fontFamily: 'GeneralSans',
      color: AppColor.kTextSecondaryDark,
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      height: 1.3,
      letterSpacing: 0,
    );

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
                  _buildSection(title: l10n.faqSectionAccount, items: _accountFaqs, titleStyle: titleStyle),
                  _buildSection(title: l10n.faqSectionPayments, items: _paymentsFaqs, titleStyle: titleStyle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
