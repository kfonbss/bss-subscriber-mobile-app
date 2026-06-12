import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/pdf_downloader/pdf_preview_and_download.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/invoice_list/domain/repository/invoice_repository.dart';
import 'package:kfon_subscriber/features/tranasactions/domain/repository/transaction_repository.dart';
import 'package:kfon_subscriber/features/tranasactions/presentation/bloc/transaction_history_bloc.dart';
import 'package:kfon_subscriber/features/tranasactions/presentation/bloc/transaction_history_event.dart';
import 'package:kfon_subscriber/features/tranasactions/presentation/bloc/transaction_history_state.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/shared/widgets/common_app_bar.dart';
import 'package:kfon_subscriber/shared/widgets/no_data_found.dart';
import 'package:kfon_subscriber/shared/widgets/shimmer/list_shimmers.dart';
import 'package:kfon_subscriber/service_locator.dart';

class TransactionHistoryPage extends StatelessWidget {
  const TransactionHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
      TransactionHistoryBloc(repository: sl<TransactionRepository>())
        ..add(const FetchTransactions()),
      child: const _TransactionHistoryView(),
    );
  }
}

class _TransactionHistoryView extends StatefulWidget {
  const _TransactionHistoryView();

  @override
  State<_TransactionHistoryView> createState() => _TransactionHistoryViewState();
}

class _TransactionHistoryViewState extends State<_TransactionHistoryView> {
  static final _errorStyle = TextStyle(
    fontFamily: 'GeneralSans',
    fontSize: 14.sp,
    color: AppColor.kSlateGrey,
  );

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
    if (!_isBottom) return;
    final state = context.read<TransactionHistoryBloc>().state;
    // Guard: only dispatch when loaded and not already paginating so the
    // event queue is not flooded while the user holds the scroll position
    // at the threshold.
    if (state is TransactionHistoryLoaded && !state.isLoadingMore) {
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
    final l10n = context.bssSubL10n;

    return CommonAppBar(
      title: l10n.transactions,
      onBackPressed: () => Navigator.pop(context),
      body: BlocConsumer<TransactionHistoryBloc, TransactionHistoryState>(
        listenWhen: (previous, current) {
          if (current is TransactionHistoryLoaded && current.paginationError != null) {
            final prevError = previous is TransactionHistoryLoaded ? previous.paginationError : null;
            return current.paginationError != prevError;
          }
          return false;
        },
        listener: (context, state) {
          if (state is TransactionHistoryLoaded && state.paginationError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.paginationError!)),
            );
          }
        },
        builder: (context, state) {
          if (state is TransactionHistoryLoading) {
            // AppShimmer is now built into ListShimmer — no outer wrapper needed.
            return ListShimmer(itemHeight: 200.h, itemCount: 10);
          } else if (state is TransactionHistoryLoaded) {
            if (state.transactions.isEmpty) {
              return NoDataFound(errorMessage: l10n.noTransactionsFound);
            }
            return ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              itemCount: state.transactions.length + (state.isLoadingMore ? 1 : 0),
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
                  onDownloadInvoice: txn.fileId.isEmpty
                      ? null
                      : () async {
                    Navigator.pop(context); // Dismiss the bottom sheet

                    if (txn.fileId.isEmpty) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Invoice file is not available'),
                        ),
                      );
                      return;
                    }

                    final result = await sl<InvoiceRepository>().getFileViewUrl(
                      txn.fileId,
                    );

                    if (!context.mounted) return;
                    result.fold(
                          (failure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(failure.message)),
                        );
                      },
                          (file) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PdfPreviewAndDownload(
                              title: context.bssSubL10n.invoice,
                              pdfUrl: file.url,
                              fileId: txn.fileId,
                            ),
                          ),
                        );
                      },
                    );
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
                      style: _errorStyle,
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () => context
                          .read<TransactionHistoryBloc>()
                          .add(const FetchTransactions()),
                      child: Text(l10n.retry),
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

  // Hoisted out of build() — BoxDecoration and its BoxShadow were being
  // allocated on every render pass for every visible card in the list.
  // Colors.black.withValues(alpha: 0.06) == Color(0x0F000000).
  static const _cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(12)),
    boxShadow: [
      BoxShadow(
        color: Color(0x0F000000),
        blurRadius: 16,
      ),
    ],
  );
  static const _infoBgDecoration = BoxDecoration(
    color: AppColor.kSecondaryBackgroundColor,
    borderRadius: BorderRadius.all(Radius.circular(10)),
  );
  static final _amountStyle = TextStyle(
    fontFamily: 'GeneralSans',
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    color: AppColor.kTextSecondaryDark,
    height: 1.30,
  );
  static final _responseLabelStyle = TextStyle(
    color: AppColor.kLabelGrey,
    fontSize: 8.sp,
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w400,
    height: 1.30,
  );
  static final _responseValueStyle = TextStyle(
    color: AppColor.kTextSecondaryDark,
    fontSize: 10.sp,
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w500,
    height: 1.30,
  );
  static final _downloadLabelStyle = TextStyle(
    fontFamily: 'GeneralSans',
    color: AppColor.kPrimaryColor,
    fontSize: 12.sp,
    fontWeight: FontWeight.w600,
  );

  static final _downloadButtonStyle = OutlinedButton.styleFrom(
    side: const BorderSide(color: AppColor.kPrimaryColor, width: 1),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
  );

  // Sizer ratios are fixed after app init — compute the full style once.
  static ButtonStyle? _resolvedDownloadStyle;
  ButtonStyle get _downloadStyle => _resolvedDownloadStyle ??=
      _downloadButtonStyle.copyWith(
        padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 12.h)),
      );

  Color get _statusColor {
    switch (status.toLowerCase()) {
      case 'success': return const Color(0xFF008F67);
      case 'pending': return const Color(0xFFAF7700);
      case 'failed': return AppColor.kFailedRed;
      default: return AppColor.kTextSecondaryDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: BSS No | Txn. Reference | Amount ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _LabelValue(label: l10n.bssNo, value: bssNo)),
              SizedBox(width: 8.w),
              Expanded(
                child: _LabelValue(label: l10n.txnReference, value: txnReference),
              ),
              Text('₹$amount', style: _amountStyle),
            ],
          ),

          SizedBox(height: 12.h),

          // ── Grey info section ──
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: _infoBgDecoration,
            child: Column(
              children: [
                // Row 1: Package | Expiry Date | Status
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _LabelValue(label: l10n.package, value: packageName),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      flex: 2,
                      child: _LabelValue(
                        label: l10n.expireDate,
                        value: DateTime.tryParse(expiryDate) != null
                            ? DateFormat('dd MMM yyyy').format(DateTime.parse(expiryDate))
                            : expiryDate,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      flex: 2,
                      child: _LabelValue(
                        label: l10n.status,
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
                      child: _LabelValue(
                        label: l10n.paidOn,
                        value: DateTime.tryParse(paidOn) != null
                            ? DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(paidOn))
                            : paidOn,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      flex: 2,
                      child: _LabelValue(label: l10n.paidBy, value: paidBy),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      flex: 2,
                      child: _LabelValue(label: l10n.paymentGateway, value: paymentGateway),
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
              children: [
                TextSpan(text: l10n.responseMessage, style: _responseLabelStyle),
                TextSpan(text: responseMessage, style: _responseValueStyle),
              ],
            ),
          ),

          SizedBox(height: 12.h),

          // ── Download Invoice Button ──
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onDownloadInvoice,
              style: _downloadStyle,
              child: Text(l10n.downloadInvoice, style: _downloadLabelStyle),
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

  static final _labelStyle = TextStyle(
    fontFamily: 'GeneralSans',
    fontSize: 10.sp,
    fontWeight: FontWeight.w500,
    color: AppColor.kTextSecondary,
    height: 1.3,
  );
  static final _defaultValueStyle = TextStyle(
    fontFamily: 'GeneralSans',
    fontSize: 10.sp,
    fontWeight: FontWeight.w500,
    color: AppColor.kTextSecondaryDark,
    height: 1.3,
  );

  @override
  Widget build(BuildContext context) {
    final valueStyle = valueColor == null
        ? _defaultValueStyle
        : _defaultValueStyle.copyWith(color: valueColor);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle),
        SizedBox(height: 3.h),
        Text(value.isNotEmpty ? value : '-', style: valueStyle),
      ],
    );
  }
}
