import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/pdf_downloader/pdf_preview_and_download.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/tranasactions/domain/repository/transaction_repository.dart';
import 'package:kfon_subscriber/features/tranasactions/presentation/bloc/transaction_history_bloc.dart';
import 'package:kfon_subscriber/features/tranasactions/presentation/bloc/transaction_history_event.dart';
import 'package:kfon_subscriber/features/tranasactions/presentation/bloc/transaction_history_state.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_app_bar.dart';
import 'package:kfon_subscriber/service_locator.dart';

class TransactionHistoryPage extends StatelessWidget {
  const TransactionHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) =>
              TransactionHistoryBloc(repository: sl<TransactionRepository>())
                ..add(const FetchTransactions()),
      child: const _TransactionHistoryView(),
    );
  }
}

class _TransactionHistoryView extends StatefulWidget {
  const _TransactionHistoryView();

  @override
  State<_TransactionHistoryView> createState() =>
      _TransactionHistoryViewState();
}

class _TransactionHistoryViewState extends State<_TransactionHistoryView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<TransactionHistoryBloc>().add(const LoadMoreTransactions());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return CommonAppBar(
      title: 'Transactions',
      onBackPressed: () => Navigator.pop(context),
      body: BlocBuilder<TransactionHistoryBloc, TransactionHistoryState>(
        builder: (context, state) {
          if (state is TransactionHistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TransactionHistoryLoaded) {
            if (state.transactions.isEmpty) {
              return Center(
                child: Text(
                  'No transactions found',
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontSize: 14.sp,
                    color: const Color(0xFF67697A),
                  ),
                ),
              );
            }
            return ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              itemCount:
                  state.transactions.length + (state.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= state.transactions.length) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }
                final txn = state.transactions[index];
                return _TransactionCard(
                  bssNo: txn.bssNo,
                  txnReference: txn.txnReference,
                  amount: txn.amount.toStringAsFixed(0),
                  packageName: txn.packageName,
                  expiryDate: txn.expiryDate,
                  status: txn.status,
                  paidOn: txn.paidOn,
                  paidBy: txn.paidBy,
                  paymentGateway: txn.paymentGateway,
                  responseMessage: txn.responseMessage,
                  onDownloadInvoice: () {
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
            );
          } else if (state is TransactionHistoryError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontSize: 14.sp,
                        color: const Color(0xFF67697A),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed:
                          () => context.read<TransactionHistoryBloc>().add(
                            const FetchTransactions(),
                          ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final String bssNo;
  final String txnReference;
  final String amount;
  final String packageName;
  final String expiryDate;
  final String status;
  final String paidOn;
  final String paidBy;
  final String paymentGateway;
  final String responseMessage;
  final VoidCallback? onDownloadInvoice;

  const _TransactionCard({
    required this.bssNo,
    required this.txnReference,
    required this.amount,
    required this.packageName,
    required this.expiryDate,
    required this.status,
    required this.paidOn,
    required this.paidBy,
    required this.paymentGateway,
    required this.responseMessage,
    this.onDownloadInvoice,
  });

  Color get _statusColor {
    switch (status.toLowerCase()) {
      case 'success':
        return const Color(0xFF008F67);
      case 'pending':
        return const Color(0xFFAF7700);
      case 'failed':
        return AppColor.kFailedRed;
      default:
        return const Color(0xFF0F1121);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: BSS No | Txn. Reference | Amount ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _LabelValue(label: 'BSS No', value: bssNo)),
              SizedBox(width: 8.w),
              Expanded(
                child: _LabelValue(
                  label: 'Txn. Reference',
                  value: txnReference,
                ),
              ),
              Text(
                '₹$amount',
                style: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F1121),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // ── Grey info section ──
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColor.kSecondaryBackgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                // Row 1: Package | Expiry Date | Status
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _LabelValue(label: 'Package', value: packageName),
                    ),
                    Expanded(
                      flex: 2,
                      child: _LabelValue(
                        label: 'Expire Date',
                        value: expiryDate,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: _LabelValue(
                        label: 'Status',
                        value: status,
                        valueColor: _statusColor,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10.h),

                // Row 2: Paid On | Paid By | Payment Gateway
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _LabelValue(label: 'Paid On', value: paidOn),
                    ),
                    Expanded(
                      flex: 2,
                      child: _LabelValue(label: 'Paid By', value: paidBy),
                    ),
                    Expanded(
                      flex: 2,
                      child: _LabelValue(
                        label: 'Payment Gateway',
                        value: paymentGateway,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 12.h),

          // ── Response Message ──
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontSize: 10.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF717171),
                height: 1.4,
              ),
              children: [
                TextSpan(
                  text: 'Response Message : ',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                TextSpan(text: responseMessage),
              ],
            ),
          ),

          SizedBox(height: 12.h),

          // ── Download Invoice Button ──
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onDownloadInvoice,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColor.kPrimaryColor, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              child: Text(
                'Download Invoice',
                style: TextStyle(
                  fontFamily: 'GeneralSans',
                  color: AppColor.kPrimaryColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small reusable label-value column used within the transaction card.
class _LabelValue extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _LabelValue({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'GeneralSans',
            fontSize: 9.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF717171),
            height: 1.3,
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          value.isNotEmpty ? value : '-',
          style: TextStyle(
            fontFamily: 'GeneralSans',
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            color: valueColor ?? const Color(0xFF0F1121),
            height: 1.3,
          ),
        ),
      ],
    );
  }
}
