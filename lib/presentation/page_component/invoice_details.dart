
import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/pdf_downloader/pdf_preview_and_download.dart';

class InvoiceDetailContent extends StatelessWidget {
  final InvoiceDetailUI invoice;

  const InvoiceDetailContent({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fields = invoice.toFields(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title
        // White card with fields
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            children: [
              for (int i = 0; i < fields.length; i++) ...[
                _InvoiceFieldRow(field: fields[i]),
                if (i != fields.length - 1) const SizedBox(height: 12),
              ],
            ],
          ),
        ),

        const SizedBox(height: 32),

        // View button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              side: BorderSide(color: Theme.of(context).primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              foregroundColor: Theme.of(context).primaryColor,
            ),
            onPressed: () async {
              // final l10n = context.bssLNPL10n;
              // final baseUrl = dotenv.env['BASE_URL'] ?? '';
              // final invoicePath = ApiUrls.invoiceDownloadURL(invoice.id);
              // final invoiceDownloadUrl = '$baseUrl$invoicePath';

              // Dismiss the bottom sheet first
              Navigator.pop(context);

              // // Wait a frame to ensure bottom sheet is dismissed
               await Future.delayed(const Duration(milliseconds: 100));
              //
              // // Then navigate to PDF preview using root navigator
              if (context.mounted) {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (_) => PdfPreviewAndDownload(
                      title: 'Invoice',
                      pdfUrl: 'invoiceDownloadUrl',
                    ),
                  ),
                );
               }
            },
            child: Builder(
              builder: (context) {
                return Text(
                  'View',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColor.kPrimaryColor,
                    fontFamily: 'GeneralSans',
                    fontSize: 14,
                    height: 1.30,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _InvoiceFieldRow extends StatelessWidget {
  final _InvoiceField field;

  const _InvoiceFieldRow({required this.field});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final labelStyle = theme.textTheme.labelLarge?.copyWith(
      color: AppColor.kTextSecondary,
      fontWeight: FontWeight.w300,
    );

    TextStyle valueStyle = theme.textTheme.labelLarge!;

    if (field.type == _InvoiceFieldType.status) {
      final isPending =
          field.value.toLowerCase() == 'pending'; // simple example
      valueStyle = valueStyle.copyWith(
        color: isPending ? AppColor.kPendingOrange : AppColor.kCompletedGreen,
        fontWeight: FontWeight.w600,
      );
    }

    return Row(
      children: [
        Expanded(child: Text(field.label, style: labelStyle)),
        const SizedBox(width: 16),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              field.value,
              style: valueStyle,
              textAlign: TextAlign.right,
            ),
          ),
        ),
      ],
    );
  }
}

class InvoiceDetailUI {
  final String id;
  final String monthLabel;
  final String status;
  final String revenue;
  final String lnpShare;
  final String monthlyIncentive;
  final String netShare;
  final String invoiceValue;
  final String invoiceDate;
  final String netPayable;

  InvoiceDetailUI({
    required this.id,
    required this.monthLabel,
    required this.status,
    required this.revenue,
    required this.lnpShare,
    required this.monthlyIncentive,
    required this.netShare,
    required this.invoiceValue,
    required this.invoiceDate,
    required this.netPayable,
  });

  List<_InvoiceField> toFields(BuildContext context) {
    return [
      _InvoiceField(label: 'Month', value: monthLabel),
      _InvoiceField(
        label: 'Status',
        value: status,
        type: _InvoiceFieldType.status,
      ),
      _InvoiceField(label: 'Revenue', value: revenue),
      _InvoiceField(label: 'LNP Share', value: lnpShare),
      _InvoiceField(label: 'Monthly Incentive', value: monthlyIncentive),
      _InvoiceField(label: 'Net Share', value: netShare),
      _InvoiceField(label: 'Invoice Value', value: invoiceValue),
      _InvoiceField(label: 'Invoice Date', value: invoiceDate),
      _InvoiceField(label: 'Net Payable', value: netPayable),
      _InvoiceField(label: 'Invoice No', value: id),
    ];
  }
}

enum _InvoiceFieldType { normal, status }

class _InvoiceField {
  final String label;
  final String value;
  final _InvoiceFieldType type;

  _InvoiceField({
    required this.label,
    required this.value,
    this.type = _InvoiceFieldType.normal,
  });
}
