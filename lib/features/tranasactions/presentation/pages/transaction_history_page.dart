import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kfon_subscriber/core/constant/app_brand.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/pdf_downloader/pdf_preview_and_download.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/invoice_list/domain/repository/invoice_repository.dart';
import 'package:kfon_subscriber/features/tranasactions/domain/entity/transaction_filter.dart';
import 'package:kfon_subscriber/features/tranasactions/domain/repository/transaction_repository.dart';
import 'package:kfon_subscriber/features/tranasactions/presentation/bloc/transaction_history_bloc.dart';
import 'package:kfon_subscriber/features/tranasactions/presentation/bloc/transaction_history_event.dart';
import 'package:kfon_subscriber/features/tranasactions/presentation/bloc/transaction_history_state.dart';
import 'package:kfon_subscriber/l10n/bss_sub_localizations.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/shared/widgets/common_app_bar.dart';
import 'package:kfon_subscriber/shared/widgets/common_bottom_sheet.dart';
import 'package:kfon_subscriber/shared/widgets/no_data_found.dart';
import 'package:kfon_subscriber/shared/widgets/shimmer/list_shimmers.dart';
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

  Future<void> _openInvoice(BuildContext context, String fileId) async {
    final result = await sl<InvoiceRepository>().getFileViewUrl(fileId);

    if (!context.mounted) return;
    result.fold(
      (failure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
      },
      (file) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => PdfPreviewAndDownload(
                  title: context.bssSubL10n.invoice,
                  pdfUrl: file.url,
                  fileId: fileId,
                ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;
    return CommonAppBar(
      title: l10n.transactions,
      onBackPressed: () => Navigator.pop(context),
      body: Column(
        children: [
          BlocBuilder<TransactionHistoryBloc, TransactionHistoryState>(
            buildWhen: (previous, current) => previous.filter != current.filter,
            builder:
                (context, state) => _FilterBar(
                  filter: state.filter,
                  onChanged:
                      (filter) => context.read<TransactionHistoryBloc>().add(
                        ApplyTransactionFilter(filter),
                      ),
                ),
          ),
          SizedBox(height: 12.h),
          Expanded(
            child: BlocConsumer<
              TransactionHistoryBloc,
              TransactionHistoryState
            >(
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.paginationError!)),
                  );
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
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
                    itemCount:
                        state.transactions.length +
                        (state.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= state.transactions.length) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
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
                                : () => _openInvoice(context, txn.fileId),
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
                          Icon(
                            Icons.error_outline_rounded,
                            size: 40.w,
                            color: AppColor.kHintGrey,
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: _errorStyle,
                          ),
                          SizedBox(height: 16.h),
                          ElevatedButton(
                            onPressed:
                                () => context
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
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter row:  [selected status / date label]      [calendar] [Filter]
// ─────────────────────────────────────────────────────────────────────────────

String _statusLabel(String status, BssSubLocalizations l10n) {
  switch (status.toUpperCase()) {
    case 'SUCCESS':
      return l10n.txnStatusSuccess;
    case 'FAILED':
      return l10n.txnStatusFailed;
    case 'PENDING':
      return l10n.txnStatusPending;
    case 'INITIATED':
      return l10n.txnStatusInitiated;
    case 'CANCELLED':
      return l10n.txnStatusCancelled;
    case 'REFUNDED':
      return l10n.txnStatusRefunded;
    default:
      return status;
  }
}

final _rangeDateFormat = DateFormat('dd MMM yyyy');
final _rangeShortDateFormat = DateFormat('dd MMM');

String _formatRange(DateTime from, DateTime to) =>
    from.year == to.year
        ? '${_rangeShortDateFormat.format(from)} - ${_rangeDateFormat.format(to)}'
        : '${_rangeDateFormat.format(from)} - ${_rangeDateFormat.format(to)}';

class _FilterBar extends StatelessWidget {
  final TransactionFilter filter;
  final ValueChanged<TransactionFilter> onChanged;

  const _FilterBar({required this.filter, required this.onChanged});

  String get _rangeLabel => _formatRange(filter.fromDate!, filter.toDate!);

  void _openDateSheet(BuildContext context) {
    showAppModalBottomSheet<void>(
      context: context,
      builder:
          (_) => _DateFilterSheet(
            fromDate: filter.hasDateRange ? filter.fromDate : null,
            toDate: filter.hasDateRange ? filter.toDate : null,
            // Only the date range changes; the status filter is preserved.
            onApply: (from, to) => onChanged(filter.withDateRange(from, to)),
          ),
    );
  }

  void _openFilterSheet(BuildContext context) {
    showAppModalBottomSheet<void>(
      context: context,
      builder:
          (_) => _StatusFilterSheet(
            selectedStatus: filter.status,
            onApply: (status) => onChanged(filter.withStatus(status)),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;
    final primary = AppColor.kPrimaryColor;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: SizedBox(
        height: 40.h,
        child: Row(
          children: [
            // Left: currently applied filters (empty when none).
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (filter.status != null)
                      _SelectedChip(label: _statusLabel(filter.status!, l10n)),
                    if (filter.status != null && filter.hasDateRange)
                      SizedBox(width: 8.w),
                    if (filter.hasDateRange)
                      _SelectedChip(
                        label: _rangeLabel,
                        onClear:
                            () => onChanged(filter.withDateRange(null, null)),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 8.w),
            // Calendar icon — highlighted while a date range is applied.
            Material(
              color: filter.hasDateRange ? AppColor.kPrimary10 : Colors.white,
              shape: CircleBorder(
                side: BorderSide(
                  color:
                      filter.hasDateRange ? primary : AppColor.kBorderLightGrey,
                ),
              ),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => _openDateSheet(context),
                child: SizedBox(
                  width: 36.w,
                  height: 36.w,
                  child: Center(
                    child: Icon(
                      Icons.calendar_today_rounded,
                      size: 18.w,
                      color:
                          filter.hasDateRange
                              ? primary
                              : AppColor.kTextSecondaryDark,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            // Filter button
            Material(
              color: filter.status != null ? AppColor.kPrimary10 : Colors.white,
              shape: StadiumBorder(
                side: BorderSide(
                  color:
                      filter.status != null
                          ? primary
                          : AppColor.kBorderLightGrey,
                ),
              ),
              child: InkWell(
                customBorder: const StadiumBorder(),
                onTap: () => _openFilterSheet(context),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 8.h,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.tune_rounded,
                        size: 16.w,
                        color:
                            filter.status != null
                                ? primary
                                : AppColor.kTextSecondaryDark,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        l10n.filter,
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color:
                              filter.status != null
                                  ? primary
                                  : AppColor.kTextSecondaryDark,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Read-only label for an applied filter; [onClear] adds a small ✕.
class _SelectedChip extends StatelessWidget {
  final String label;
  final VoidCallback? onClear;

  const _SelectedChip({required this.label, this.onClear});

  @override
  Widget build(BuildContext context) {
    final primary = AppColor.kPrimaryColor;
    return Container(
      padding: EdgeInsets.only(
        left: 12.w,
        right: onClear != null ? 4.w : 12.w,
        top: 6.h,
        bottom: 6.h,
      ),
      decoration: BoxDecoration(
        color: AppColor.kPrimary10,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: primary,
              height: 1.3,
            ),
          ),
          if (onClear != null)
            InkWell(
              customBorder: const CircleBorder(),
              onTap: onClear,
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Icon(Icons.close_rounded, size: 14.w, color: primary),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status filter bottom sheet (single-choice radio list)
// ─────────────────────────────────────────────────────────────────────────────

class _StatusFilterSheet extends StatefulWidget {
  final String? selectedStatus;
  final ValueChanged<String?> onApply;

  const _StatusFilterSheet({
    required this.selectedStatus,
    required this.onApply,
  });

  @override
  State<_StatusFilterSheet> createState() => _StatusFilterSheetState();
}

class _StatusFilterSheetState extends State<_StatusFilterSheet> {
  /// null = All Transactions.
  String? _selected;

  static final _titleStyle = TextStyle(
    fontFamily: 'GeneralSans',
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    color: AppColor.kNearBlack,
    height: 1.4,
  );
  static final _optionStyle = TextStyle(
    fontFamily: 'GeneralSans',
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    color: AppColor.kTextSecondaryDark,
  );
  static ButtonStyle get _clearButtonStyle => OutlinedButton.styleFrom(
    side: BorderSide(color: AppColor.kPrimaryColor),
    padding: const EdgeInsets.symmetric(vertical: 14),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  );
  static ButtonStyle get _applyButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: AppColor.kPrimaryColor,
    padding: const EdgeInsets.symmetric(vertical: 14),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  );

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedStatus;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;
    final options = <String?>[null, ...TransactionFilter.statuses];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.filter, style: _titleStyle),
          SizedBox(height: 12.h),
          Flexible(
            child: SingleChildScrollView(
              child: RadioGroup<String?>(
                groupValue: _selected,
                onChanged: (value) => setState(() => _selected = value),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final option in options)
                      InkWell(
                        onTap: () => setState(() => _selected = option),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 24.w,
                                height: 24.w,
                                child: Radio<String?>(
                                  value: option,
                                  activeColor: AppColor.kPrimaryColor,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                option == null
                                    ? l10n.allTransactions
                                    : _statusLabel(option, l10n),
                                style: _optionStyle,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  // Resets the selection to "All Transactions"; Apply commits.
                  onPressed: () => setState(() => _selected = null),
                  style: _clearButtonStyle,
                  child: Text(
                    l10n.clear,
                    style: TextStyle(color: AppColor.kPrimaryColor),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onApply(_selected);
                  },
                  style: _applyButtonStyle,
                  child: Text(
                    l10n.apply,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Date filter bottom sheet: This month / Last 30 days / Custom date
// ─────────────────────────────────────────────────────────────────────────────

enum _DateOption { thisMonth, last30Days, custom }

class _DateFilterSheet extends StatefulWidget {
  final DateTime? fromDate;
  final DateTime? toDate;

  /// Called on Apply. Both null = remove the date filter.
  final void Function(DateTime? from, DateTime? to) onApply;

  const _DateFilterSheet({
    required this.fromDate,
    required this.toDate,
    required this.onApply,
  });

  @override
  State<_DateFilterSheet> createState() => _DateFilterSheetState();
}

class _DateFilterSheetState extends State<_DateFilterSheet> {
  late final DateTime _today;
  late final DateTimeRange _thisMonthRange;
  late final DateTimeRange _last30Range;

  _DateOption? _selected;
  DateTimeRange? _customRange;

  static final _titleStyle = TextStyle(
    fontFamily: 'GeneralSans',
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    color: AppColor.kNearBlack,
    height: 1.4,
  );
  static final _optionStyle = TextStyle(
    fontFamily: 'GeneralSans',
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    color: AppColor.kTextSecondaryDark,
  );
  static final _rangeStyle = TextStyle(
    fontFamily: 'GeneralSans',
    fontSize: 11.sp,
    fontWeight: FontWeight.w400,
    color: AppColor.kLabelGrey,
    height: 1.3,
  );
  static ButtonStyle get _clearButtonStyle => OutlinedButton.styleFrom(
    side: BorderSide(color: AppColor.kPrimaryColor),
    padding: const EdgeInsets.symmetric(vertical: 14),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  );
  static ButtonStyle get _applyButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: AppColor.kPrimaryColor,
    padding: const EdgeInsets.symmetric(vertical: 14),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  );

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _today = DateTime(now.year, now.month, now.day);
    _thisMonthRange = DateTimeRange(
      start: DateTime(_today.year, _today.month, 1),
      end: _today,
    );
    // 30 calendar days including today.
    _last30Range = DateTimeRange(
      start: DateTime(_today.year, _today.month, _today.day - 29),
      end: _today,
    );

    // Pre-select the option that matches the range currently applied.
    final from = widget.fromDate;
    final to = widget.toDate;
    if (from != null && to != null) {
      final applied = DateTimeRange(start: from, end: to);
      if (applied == _thisMonthRange) {
        _selected = _DateOption.thisMonth;
      } else if (applied == _last30Range) {
        _selected = _DateOption.last30Days;
      } else {
        _selected = _DateOption.custom;
        _customRange = applied;
      }
    }
  }

  DateTimeRange? get _selectedRange => switch (_selected) {
    _DateOption.thisMonth => _thisMonthRange,
    _DateOption.last30Days => _last30Range,
    _DateOption.custom => _customRange,
    null => null,
  };

  Future<void> _pickCustomRange() async {
    // Standard Material date-range picker with its default layout and text.
    // It only allows start <= end, so an inverted range can't be sent.
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: _today,
      initialDateRange: _customRange,
    );
    if (!mounted || picked == null) return;
    setState(() {
      _customRange = DateTimeRange(
        start: DateTime(
          picked.start.year,
          picked.start.month,
          picked.start.day,
        ),
        end: DateTime(picked.end.year, picked.end.month, picked.end.day),
      );
      _selected = _DateOption.custom;
    });
  }

  void _onOptionTap(_DateOption option) {
    if (option == _DateOption.custom) {
      // Selecting Custom opens the picker; cancelling keeps the old choice.
      _pickCustomRange();
    } else {
      setState(() => _selected = option);
    }
  }

  String? _optionSubtitle(_DateOption option) {
    final range = switch (option) {
      _DateOption.thisMonth => _thisMonthRange,
      _DateOption.last30Days => _last30Range,
      _DateOption.custom => _customRange,
    };
    return range == null ? null : _formatRange(range.start, range.end);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;
    final labels = {
      _DateOption.thisMonth: l10n.thisMonth,
      _DateOption.last30Days: l10n.last30Days,
      _DateOption.custom: l10n.customDate,
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.filterByDate, style: _titleStyle),
          SizedBox(height: 12.h),
          Flexible(
            child: SingleChildScrollView(
              child: RadioGroup<_DateOption>(
                groupValue: _selected,
                onChanged: (value) {
                  if (value != null) _onOptionTap(value);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final option in _DateOption.values)
                      InkWell(
                        onTap: () => _onOptionTap(option),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 24.w,
                                height: 24.w,
                                child: Radio<_DateOption>(
                                  value: option,
                                  activeColor: AppColor.kPrimaryColor,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(labels[option]!, style: _optionStyle),
                                    if (_optionSubtitle(option) != null) ...[
                                      SizedBox(height: 2.h),
                                      Text(
                                        _optionSubtitle(option)!,
                                        style: _rangeStyle,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (option == _DateOption.custom)
                                Icon(
                                  Icons.edit_calendar_rounded,
                                  size: 18.w,
                                  color: AppColor.kLabelGrey,
                                ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  // Dismisses without applying; the applied range is kept.
                  onPressed: () => Navigator.pop(context),
                  style: _clearButtonStyle,
                  child: Text(
                    l10n.close,
                    style: TextStyle(color: AppColor.kPrimaryColor),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final range = _selectedRange;
                    Navigator.pop(context);
                    widget.onApply(range?.start, range?.end);
                  },
                  style: _applyButtonStyle,
                  child: Text(
                    l10n.apply,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
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
  static TextStyle get _downloadLabelStyle => TextStyle(
    fontFamily: 'GeneralSans',
    color: AppColor.kPrimaryColor,
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    height: 1.30,
  );

  // Design: 32 tall, 1px primary border, radius 10. Not cached in a static —
  // kPrimaryColor follows the tenant.
  ButtonStyle get _downloadStyle => OutlinedButton.styleFrom(
    side: BorderSide(color: AppColor.kPrimaryColor, width: 1),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
    minimumSize: Size(double.infinity, 32.h),
    fixedSize: Size(double.infinity, 32.h),
    padding: EdgeInsets.symmetric(horizontal: 10.w),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
