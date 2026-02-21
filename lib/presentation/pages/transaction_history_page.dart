import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/models/transactionItem.dart';
import 'package:kfon_subscriber/presentation/page_component/status_badge.dart';
import 'package:kfon_subscriber/presentation/pages/transaction_details_page.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_app_bar.dart';


// ── Screen ───────────────────────────────────────────────────

class TransactionHistoryPage extends StatelessWidget {
  const TransactionHistoryPage({super.key});

  static const _transactions = [
    TransactionItem(bssNo: 'UW9089EZ45520251015',
        date: '30 jun 2025  13:44',
        status: TransactionStatus.pending),
    TransactionItem(bssNo: 'UW9089EZ45520251015',
        date: '25 jun 2025  13:44',
        status: TransactionStatus.pending),
    TransactionItem(bssNo: 'UW9089EZ45520251015',
        date: '20 jun 2025  13:44',
        status: TransactionStatus.fail),
    TransactionItem(bssNo: 'UW9089EZ45520251015',
        date: '10 jun 2025  13:44',
        status: TransactionStatus.pending),
    TransactionItem(bssNo: 'UW9089EZ45520251015',
        date: '08 jun 2025  13:44',
        status: TransactionStatus.pending),
    TransactionItem(bssNo: 'UW9089EZ45520251015',
        date: '05 jun 2025  13:44',
        status: TransactionStatus.success),
    TransactionItem(bssNo: 'UW9089EZ45520251015',
        date: '02 jun 2025  13:44',
        status: TransactionStatus.success),
    TransactionItem(bssNo: 'UW9089EZ45520251015',
        date: '01 jun 2025  13:44',
        status: TransactionStatus.success),
  ];

  @override
  Widget build(BuildContext ctx) {
    return CommonAppBar(onBackPressed: () => Navigator.pop(ctx),
        title: 'Transaction History',
        body: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          itemCount: _transactions.length,
          separatorBuilder: (_, __) => SizedBox(height: 14.h),
          itemBuilder: (_, i) => _TransactionCard(item: _transactions[i]),
        ));
  }
}

// ── Transaction Card ─────────────────────────────────────────

class _TransactionCard extends StatelessWidget {
  final TransactionItem item;

  const _TransactionCard({required this.item});

  @override
  Widget build(BuildContext ctx) {
    return GestureDetector(
      onTap: () =>
          Navigator.push(
            ctx,
            MaterialPageRoute<void>(
                builder: (context) => const TransactionDetailsPage()),
          ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 36.w,
              height: 36.h,
              padding: EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFF3EEF6),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(
                    'assets/icons/transaction_icon.svg',),
              ),
            ),
            SizedBox(width: 14.w),

            // BSS No & Date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BSS No : ${item.bssNo}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontFamily: 'General Sans',
                      fontWeight: FontWeight.w500,
                      height: 1.30,
                      color: const Color(0xFF1A1A1A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    item.date,
                    style: TextStyle(
                      fontSize: 12.sp,
                        fontFamily: 'General Sans',
                        fontWeight: FontWeight.w500,
                        height: 1.60,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // Status badge
            StatusBadge(status: item.status),
          ],
        ),
      ),
    );
  }
}
