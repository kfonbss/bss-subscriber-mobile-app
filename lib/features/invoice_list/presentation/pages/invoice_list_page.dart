import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/pdf_downloader/pdf_preview_and_download.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/invoice_list/presentation/bloc/invoice_list_bloc.dart';
import 'package:kfon_subscriber/features/invoice_list/presentation/bloc/invoice_list_event.dart';
import 'package:kfon_subscriber/features/invoice_list/presentation/bloc/invoice_list_state.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_app_bar.dart';
import 'package:kfon_subscriber/presentation/ui_component/no_data_found.dart';
import 'package:kfon_subscriber/presentation/ui_component/retry_widget.dart';
import 'package:kfon_subscriber/presentation/ui_component/shimmer/list_shimmers.dart';

class InvoiceListPage extends StatefulWidget {
  const InvoiceListPage({super.key});

  @override
  State<InvoiceListPage> createState() => _InvoiceListPageState();
}

class _InvoiceListPageState extends State<InvoiceListPage> {
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
    final state = context.read<InvoiceListBloc>().state;
    // Guard: only dispatch when loaded and not already paginating.
    // Without this guard the listener fires on every scroll tick that
    // satisfies _isBottom, flooding the BLoC event queue.
    if (state is InvoiceListLoaded && !state.isLoadingMore) {
      context.read<InvoiceListBloc>().add(const LoadMoreInvoices());
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
      title: l10n.invoice,
      onBackPressed: () => Navigator.pop(context),
      body: BlocConsumer<InvoiceListBloc, InvoiceListState>(
        listenWhen: (previous, current) {
          if (current is InvoiceListLoaded && current.paginationError != null) {
            final prevError = previous is InvoiceListLoaded ? previous.paginationError : null;
            return current.paginationError != prevError;
          }
          return false;
        },
        listener: (context, state) {
          if (state is InvoiceListLoaded && state.paginationError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.paginationError!)),
            );
          }
        },
        builder: (context, state) {
          if (state is InvoiceListLoading) {
            return const ListShimmer(itemCount: 10, itemHeight: 96);
          }

          if (state is InvoiceListError) {
            return RetryWidget(
              errorMessage: state.message,
              onRetry: () =>
                  context.read<InvoiceListBloc>().add(const FetchInvoices()),
            );
          }

          if (state is InvoiceListLoaded) {
            if (state.invoices.isEmpty) {
              return NoDataFound(errorMessage: l10n.noInvoicesFound);
            }

            return ListView.separated(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              itemCount:
              state.invoices.length + (state.isLoadingMore ? 1 : 0),
              separatorBuilder: (context, index) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                if (index >= state.invoices.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColor.kPrimaryColor,
                      ),
                    ),
                  );
                }

                final invoice = state.invoices[index];
                return _InvoiceCard(
                  invoiceNo: invoice.invoiceNo,
                  amount: invoice.amount.toStringAsFixed(2),
                  date: invoice.invoiceDate,
                  onDownload: invoice.pdfUrl.isEmpty
                      ? null
                      : () {
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              builder: (_) => PdfPreviewAndDownload(
                                title: l10n.invoice,
                                pdfUrl: invoice.pdfUrl,
                              ),
                            ),
                          );
                        },
                );
              },
            );
          }

          return const SizedBox.shrink();
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

  static const _shadowColor = Color(0x0D000000); // black @ 5% opacity
  static const _iconBgColor = Color(0x1A8D0247); // kPrimaryColor @ 10% opacity
  static const _cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(12)),
    boxShadow: [
      BoxShadow(color: _shadowColor, blurRadius: 12, offset: Offset(0, 2)),
    ],
  );
  // TextSpan base style uses 11.sp (Sizer) → static final.
  static final _richTextBase = TextStyle(
    fontFamily: 'GeneralSans',
    fontSize: 11.sp,
    height: 1.4,
    color: AppColor.kTextSecondaryDark,
  );
  static final _downloadLabelStyle = TextStyle(
    fontFamily: 'GeneralSans',
    color: AppColor.kPrimaryColor,
    fontSize: 11.sp,
    fontWeight: FontWeight.w600,
  );
  static final _downloadButtonStyle = OutlinedButton.styleFrom(
    side: const BorderSide(color: AppColor.kPrimaryColor, width: 1),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    minimumSize: Size.zero,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );

  // Sizer ratios are fixed after app init, so the resolved style is computed
  // once and reused across all card rebuilds instead of calling copyWith()
  // inside build() on every render pass.
  static ButtonStyle? _resolvedDownloadStyle;
  ButtonStyle get _downloadStyle => _resolvedDownloadStyle ??=
      _downloadButtonStyle.copyWith(
        padding: WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: _cardDecoration,
      child: Row(
        children: [
          // ── Document icon ──
          Container(
            width: 40.w,
            height: 40.w,
            decoration: const BoxDecoration(
              color: _iconBgColor,
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
                    style: const TextStyle(
                      fontFamily: 'GeneralSans',
                      height: 1.4,
                      fontSize: 11,
                      color: AppColor.kTextSecondaryDark,
                    ),
                    children: [
                      TextSpan(
                        text: l10n.invoiceNo,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColor.kTextSecondary,
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
                    style: _richTextBase,
                    children: [
                      TextSpan(
                        text: l10n.amountLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColor.kTextSecondary,
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
                    style: _richTextBase,
                    children: [
                      TextSpan(
                        text: l10n.dateLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColor.kTextSecondary,
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
            style: _downloadStyle,
            child: Text(l10n.download, style: _downloadLabelStyle),
          ),
        ],
      ),
    );
  }
}
