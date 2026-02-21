import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kfon_subscriber/core/constant/app_styles.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/helper/bottom_sheet_helper.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/models/invoice.dart';
import 'package:kfon_subscriber/presentation/page_component/invoice_details.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_app_bar.dart';
import 'package:intl/intl.dart';
class InvoicePage extends StatelessWidget {
  const InvoicePage({super.key});

  static const _invoices = [
    Invoice(
      invoiceNo:        'KLLNP2025110001',
      grossAmount:      '₹1693.53',
      invoiceDate:      '30 Nov 2025',
      time:             '14:25',
      month:            'November 2025',
      status:           'Completed',
      revenue:          8286.15,
      lnpShare:         160.54,
      monthlyIncentive: 88.98,
      netShare:         249.52,
      invoiceValue:     1737.72,
      netPayable:       1737.72,
    ),
    Invoice(
      invoiceNo:        'KLLNP2025110002',
      grossAmount:      '₹2150.00',
      invoiceDate:      '15 Nov 2025',
      time:             '01:32',
      month:            'November 2025',
      status:           'Pending',
      revenue:          9500.00,
      lnpShare:         180.00,
      monthlyIncentive: 95.50,
      netShare:         275.50,
      invoiceValue:     2000.00,
      netPayable:       2000.00,
    ),
    Invoice(
      invoiceNo:        'KLLNP2025100001',
      grossAmount:      '₹1850.75',
      invoiceDate:      '10 Oct 2025',
      time:             '09:15',
      month:            'October 2025',
      status:           'Completed',
      revenue:          7650.30,
      lnpShare:         145.20,
      monthlyIncentive: 78.60,
      netShare:         223.80,
      invoiceValue:     1600.00,
      netPayable:       1600.00,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return CommonAppBar(
      onBackPressed: () => Navigator.pop(context),
      title: 'Invoice',
      body: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: ListView.separated(
          padding: const EdgeInsets.all(16).copyWith(top: 0),
          itemCount: _invoices.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return _InvoiceCard(item: _invoices[index]);
          },
        ),
      ),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  final Invoice item;

  const _InvoiceCard({required this.item});

  String _formatInvoiceDate(String dateString) {
    try {
      final date = DateTime.tryParse(dateString);
      if (date != null) {
        return DateFormat('dd MMM yyyy').format(date);
      }
      return dateString;
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bool isCompleted = item.status.toLowerCase() == 'completed';
    final Color statusColor = isCompleted
        ? AppColor.kCompletedGreen
        : AppColor.kPendingOrange;

    return GestureDetector(
      onTap: () async {
        final monthLabel = _formatFullMonth(
          item.invoiceDate.split('-').take(2).join('-'),
        );
          final detail = InvoiceDetailUI(
            id: item.invoiceNo,
            monthLabel: monthLabel,
            status: item.status,
            revenue: item.revenue.toStringAsFixed(2),
            lnpShare: item.lnpShare.toStringAsFixed(2),
            monthlyIncentive: item.monthlyIncentive.toStringAsFixed(2),
            netShare: item.netShare.toStringAsFixed(2),
            invoiceValue: item.invoiceValue.toStringAsFixed(2),
            invoiceDate: _formatInvoiceDate(item.invoiceDate),
            netPayable: '₹${item.netPayable.toStringAsFixed(2)}',
          );
          BottomSheetHelper.show(context: context,
              title: item.invoiceNo,
              child: InvoiceDetailContent(invoice: detail));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppStyles.boxShadowForWhite,
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColor.kSecondaryBackgroundColor,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        'assets/icons/invoice_list.svg',
                        width: 16,
                        height: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.invoiceNo,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.status,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 11.sp,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: AppColor.kSecondaryBackgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Builder(
                builder: (context) {
                  return Row(
                    children: [
                      Expanded(
                        child: _detailColumn(
                          theme: theme,
                          label: 'Gross Amount',
                          value: item.grossAmount,
                        ),
                      ),
                      _detailColumn(
                        theme: theme,
                        label: 'Invoice Date',
                        value: item.invoiceDate,
                      ),
                      const SizedBox(width: 20),
                      _detailColumn(
                        theme: theme,
                        label: 'Time',
                        value: item.time,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );

  }
  String _formatFullMonth(String monthString) {
    try {
      final parts = monthString.split('-');
      if (parts.length == 2) {
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final date = DateTime(year, month);
        return DateFormat('MMMM yyyy').format(date);
      }
      return monthString;
    } catch (e) {
      return monthString;
    }
  }
  Widget _detailColumn({
    required ThemeData theme,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: .5),
            fontSize: 9,
          ),
        ),
        const SizedBox(height: 2),
        Text(value, style: theme.textTheme.labelMedium),
      ],
    );
  }
}
