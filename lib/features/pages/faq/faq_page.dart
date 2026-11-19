import 'package:dartz/dartz.dart' show Either;
import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/pages/faq/faq_tile.dart';
import 'package:kfon_subscriber/features/pages/faq/railwire_faq_repository.dart';
import 'package:kfon_subscriber/shared/widgets/retry_widget.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/shared/widgets/common_app_bar.dart';

class FaqItem {
  final String question;
  final String answer;

  FaqItem({required this.question, required this.answer});
}

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  /// A [title] heading (none when null) over the numbered [items].
  static Widget _buildSection({String? title, required List<FaqItem> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title,
            style: TextStyle(
              fontFamily: 'GeneralSans',
              color: const Color(0xFF0F1121),
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              height: 1.3.h,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 10.h),
        ],
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
    if (ApiUrls.isRailwire) return const _RailwireFaqView();

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

/// RailWire's FAQs from `faqdetails`, grouped by category once the API sends
/// one; until then they're a single list without a heading.
class _RailwireFaqView extends StatefulWidget {
  const _RailwireFaqView();

  @override
  State<_RailwireFaqView> createState() => _RailwireFaqViewState();
}

class _RailwireFaqViewState extends State<_RailwireFaqView> {
  late Future<Either<Failure, List<RailwireFaq>>> _faqs =
      RailwireFaqRepository.fetch();

  void _retry() => setState(() => _faqs = RailwireFaqRepository.fetch());

  /// Sections in the API's order; FAQs without a category have no heading.
  List<Widget> _sections(List<RailwireFaq> faqs) {
    final byCategory = <String, List<FaqItem>>{};
    for (final faq in faqs) {
      byCategory
          .putIfAbsent(faq.category, () => [])
          .add(FaqItem(question: faq.question, answer: faq.answer));
    }
    return [
      for (final entry in byCategory.entries)
        FaqPage._buildSection(
          title: entry.key.isEmpty ? null : entry.key,
          items: entry.value,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;
    return CommonAppBar(
      title: l10n.faqs,
      body: FutureBuilder<Either<Failure, List<RailwireFaq>>>(
        future: _faqs,
        builder: (context, snapshot) {
          final result = snapshot.data;
          if (result == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return result.fold(
            (failure) => Center(
              child: RetryWidget(
                errorMessage: failure.message,
                onRetry: _retry,
              ),
            ),
            (faqs) =>
                faqs.isEmpty
                    ? Center(child: Text(l10n.noDataFound))
                    : SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 50.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _sections(faqs),
                      ),
                    ),
          );
        },
      ),
    );
  }
}
