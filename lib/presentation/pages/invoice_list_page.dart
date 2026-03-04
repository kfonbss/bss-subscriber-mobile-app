import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/pdf_downloader/pdf_preview_and_download.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_app_bar.dart';

class InvoiceListPage extends StatelessWidget {
  const InvoiceListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppBar(
      title: 'Invoice',
      onBackPressed: () => Navigator.pop(context),
      body: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        itemCount: 10, // TODO: Replace with actual data length
        separatorBuilder: (context, index) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          // TODO: Replace with actual invoice data
          return _InvoiceCard(
            invoiceNo: 'KLLNP2025110003',
            amount: '349.99',
            date: '2025-10-12 19:35:03',
            onDownload: () {
              if (context.mounted) {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder:
                        (_) => PdfPreviewAndDownload(
                          title: 'Invoice',
                          pdfUrl:
                              'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
                        ),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  final String invoiceNo;
  final String amount;
  final String date;
  final VoidCallback? onDownload;

  const _InvoiceCard({
    required this.invoiceNo,
    required this.amount,
    required this.date,
    this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Document icon ──
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppColor.kPrimaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              'assets/icons/invoice_list.svg',
              width: 18.w,
              height: 18.w,
            ),
          ),

          SizedBox(width: 12.w),

          // ── Invoice details ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Invoice No
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      height: 1.4,
                      fontSize: 11,
                      color: const Color(0xFF0F1121),
                    ),
                    children: [
                      TextSpan(
                        text: 'Invoice No : ',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF717171),
                        ),
                      ),
                      TextSpan(
                        text: invoiceNo,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 4.h),

                // Amount
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontSize: 11.sp,
                      height: 1.4,
                      color: const Color(0xFF0F1121),
                    ),
                    children: [
                      TextSpan(
                        text: 'Amount : ',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF717171),
                        ),
                      ),
                      TextSpan(
                        text: '₹ $amount',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 4.h),

                // Date
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontSize: 11.sp,
                      height: 1.4,
                      color: const Color(0xFF0F1121),
                    ),
                    children: [
                      TextSpan(
                        text: 'Date : ',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF717171),
                        ),
                      ),
                      TextSpan(
                        text: date,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Download button ──
          OutlinedButton(
            onPressed: onDownload,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColor.kPrimaryColor, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Download',
              style: TextStyle(
                fontFamily: 'GeneralSans',
                color: AppColor.kPrimaryColor,
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
