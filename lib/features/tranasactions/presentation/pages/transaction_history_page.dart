import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kfon_subscriber/core/constant/app_brand.dart';
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
import 'package:kfon_subscriber/shared/widgets/primary_button.dart';

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
          if (current is TransactionHistoryLoaded &&
              current.paginationError != null) {
            final prevError =
                previous is TransactionHistoryLoaded
                    ? previous.paginationError
                    : null;
            return current.paginationError != prevError;
          }
          return false;
        },
        listener: (context, state) {
          if (state is TransactionHistoryLoaded &&
              state.paginationError != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.paginationError!)));
          }
        },
        builder: (context, state) {
          if (state is TransactionHistoryLoading) {
            // AppShimmer is now built into ListShimmer — no outer wrapper needed.
            return ListShimmer(itemHeight: 200, itemCount: 10);
          } else if (state is TransactionHistoryLoaded) {
            if (state.transactions.isEmpty) {
              return NoDataFound(errorMessage: l10n.noTransactionsFound);
            }
            return ListView.builder(
              controller: _scrollController,
              // Design: 24 gap below the toolbar; CommonAppBar's bottom
              // margin already covers it, so no extra top padding.
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
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
                  onDownloadInvoice:
                      txn.fileId.isEmpty
                          ? null
                          : () async {
                            final result = await sl<InvoiceRepository>()
                                .getFileViewUrl(txn.fileId);

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
                                    builder:
                                        (context) => PdfPreviewAndDownload(
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
                    PrimaryButton(
                      label: l10n.retry,
                      isLoading: false,
                      borderRadius: 10,
                      onClicked:
                          () => context.read<TransactionHistoryBloc>().add(
                            const FetchTransactions(),
                          ),
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
    boxShadow: [BoxShadow(color: AppColor.kCardShadow, blurRadius: 16)],
  );
  static const _infoBgDecoration = BoxDecoration(
    color: AppColor.kSecondaryBackgroundColor,
    borderRadius: BorderRadius.all(Radius.circular(12)),
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


  Color get _statusColor {
    switch (status.toLowerCase()) {
      case 'success':
        return AppColor.kTicketClosedGreen;
      case 'pending':
        return AppColor.kTicketProgressOrange;
      case 'failed':
        return AppColor.kFailedRed;
      default:
        return AppColor.kTextSecondaryDark;
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
          // Design: BSS No column 109 wide, 24 gap, then Txn. Reference.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 109.w,
                child: _LabelValue(label: l10n.appNo(AppBrand.appName), value: bssNo),
              ),
              SizedBox(width: 24.w),
              Expanded(
                child: _LabelValue(
                  label: l10n.txnReference,
                  value: txnReference,
                ),
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
                      child: _LabelValue(
                        small: true,
                        label: l10n.package,
                        value: packageName,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      flex: 2,
                      child: _LabelValue(
                        small: true,
                        label: l10n.expireDate,
                        value:
                            DateTime.tryParse(expiryDate) != null
                                ? DateFormat(
                                  'dd MMM yyyy',
                                ).format(DateTime.parse(expiryDate))
                                : expiryDate,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      flex: 2,
                      child: _LabelValue(
                        small: true,
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
                        small: true,
                        label: l10n.paidOn,
                        value:
                            DateTime.tryParse(paidOn) != null
                                ? DateFormat(
                                  'yyyy-MM-dd HH:mm:ss',
                                ).format(DateTime.parse(paidOn))
                                : paidOn,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      flex: 2,
                      child: _LabelValue(
                        small: true,
                        label: l10n.paidBy,
                        value: paidBy,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      flex: 2,
                      child: _LabelValue(
                        small: true,
                        label: l10n.paymentGateway,
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
              children: [
                TextSpan(
                  text: l10n.responseMessage,
                  style: _responseLabelStyle,
                ),
                // Design: 6 gap between label and message.
                WidgetSpan(child: SizedBox(width: 6.w)),
                TextSpan(text: responseMessage, style: _responseValueStyle),
              ],
            ),
          ),
          // if (onDownloadInvoice != null) ...[
          //   SizedBox(height: 12.h),
          //   SizedBox(
          //     width: double.infinity,
          //     child: OutlinedButton(
          //       onPressed: onDownloadInvoice,
          //       style: _downloadStyle,
          //       child: Text(l10n.downloadInvoice, style: _downloadLabelStyle),
          //     ),
          //   ),
          // ],
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

  /// Grey-box style label (8, w400, #707070) instead of the top-row one
  /// (10, w500, #888888) — as in the design.
  final bool small;

  const _LabelValue({
    required this.label,
    required this.value,
    this.valueColor,
    this.small = false,
  });

  static final _labelStyle = TextStyle(
    fontFamily: 'GeneralSans',
    fontSize: 10.sp,
    fontWeight: FontWeight.w500,
    color: AppColor.kHintGrey,
    height: 1.3,
  );
  static final _smallLabelStyle = TextStyle(
    fontFamily: 'GeneralSans',
    fontSize: 8.sp,
    fontWeight: FontWeight.w400,
    color: AppColor.kLabelGrey,
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
    final valueStyle =
        valueColor == null
            ? _defaultValueStyle
            : _defaultValueStyle.copyWith(color: valueColor);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: small ? _smallLabelStyle : _labelStyle),
        SizedBox(height: 3.h),
        Text(value.isNotEmpty ? value : '-', style: valueStyle),
      ],
    );
  }
}
