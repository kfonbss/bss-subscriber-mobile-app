import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';
import 'package:kfon_subscriber/core/util/pdf_downloader/pdf_preview_and_download.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/invoice_list/domain/repository/invoice_repository.dart';
import 'package:kfon_subscriber/features/invoice_list/presentation/bloc/invoice_list_bloc.dart';
import 'package:kfon_subscriber/features/invoice_list/presentation/bloc/invoice_list_event.dart';
import 'package:kfon_subscriber/features/invoice_list/presentation/bloc/invoice_list_state.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/service_locator.dart';
import 'package:kfon_subscriber/shared/widgets/common_app_bar.dart';
import 'package:kfon_subscriber/shared/widgets/no_data_found.dart';
import 'package:kfon_subscriber/shared/widgets/retry_widget.dart';
import 'package:kfon_subscriber/shared/widgets/secondary_button.dart';
import 'package:kfon_subscriber/shared/widgets/shimmer/list_shimmers.dart';
import 'package:kfon_subscriber/core/constant/app_assets.dart';

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
            final prevError =
                previous is InvoiceListLoaded ? previous.paginationError : null;
            return current.paginationError != prevError;
          }
          return false;
        },
        listener: (context, state) {
          if (state is InvoiceListLoaded && state.paginationError != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.paginationError!)));
          }
        },
        builder: (context, state) {
          if (state is InvoiceListLoading) {
            return const ListShimmer(itemCount: 10, itemHeight: 96);
          }

          if (state is InvoiceListError) {
            return RetryWidget(
              errorMessage: state.message,
              onRetry:
                  () => context.read<InvoiceListBloc>().add(
                    const FetchInvoices(),
                  ),
            );
          }

          if (state is InvoiceListLoaded) {
            if (state.invoices.isEmpty) {
              return NoDataFound(errorMessage: l10n.noInvoicesFound);
            }

            return ListView.separated(
              controller: _scrollController,
              // Design: 24 gap below the toolbar; CommonAppBar's bottom
              // margin already covers it, so no extra top padding.
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
              itemCount: state.invoices.length + (state.isLoadingMore ? 1 : 0),
              separatorBuilder: (context, index) => SizedBox(height: 16.h),
              itemBuilder: (context, index) {
                if (index >= state.invoices.length) {
                  return Padding(
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
                  onDownload:
                      invoice.fileId.isEmpty
                          ? () {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  context.bssSubL10n.invoiceFileNotAvailable,
                                ),
                              ),
                            );
                            return;
                          }
                          : () async {
                            final result = await sl<InvoiceRepository>()
                                .getFileViewUrl(invoice.fileId);

                            if (!context.mounted) return;
                            result.fold(
                              (failure) {
                                DialogUtil().showCustomSnackbar(
                                  context: context,
                                  content: failure.message,
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
                                          fileId: invoice.fileId,
                                        ),
                                  ),
                                );
                              },
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

  static get _iconBgColor => AppColor.kPrimary10; // kPrimaryColor @ 10% opacity
  // Design: white, radius 12, 16 blur black @ 6%, no offset.
  static const _cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(12)),
    boxShadow: [BoxShadow(color: AppColor.kCardShadow, blurRadius: 16)],
  );

  // Design: labels 10 w500 #888888; values 12 w500.
  static final _labelStyle = TextStyle(
    fontFamily: 'GeneralSans',
    fontSize: 10.sp,
    fontWeight: FontWeight.w500,
    height: 1.30,
    color: AppColor.kHintGrey,
  );
  static final _invoiceNoValueStyle = TextStyle(
    fontFamily: 'GeneralSans',
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    height: 1.30,
    color: AppColor.kTextSecondaryDark,
  );
  static final _valueStyle = TextStyle(
    fontFamily: 'GeneralSans',
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    height: 1.60,
    color: Colors.black,
  );

  // Getters so the primary colour follows the tenant.
  static TextStyle get _downloadLabelStyle => TextStyle(
    fontFamily: 'GeneralSans',
    color: AppColor.kPrimaryColor,
    fontSize: 11.sp,
    fontWeight: FontWeight.w500,
    height: 1.30,
  );



  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;

    return Container(
      // Design: 335×96 card, content 303 wide (16 side padding), centred.
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
      decoration: _cardDecoration,
      child: Row(
        children: [
          // ── Document icon ── Design: 38 circle, 20 icon.
          Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: _iconBgColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              AppAssets.invoiceList,
              width: 20.w,
              height: 20.w,
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
                    children: [
                      TextSpan(text: l10n.invoiceNo, style: _labelStyle),
                      TextSpan(text: invoiceNo, style: _invoiceNoValueStyle),
                    ],
                  ),
                ),

                SizedBox(height: 4.h),

                // Amount
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(text: l10n.amountLabel, style: _labelStyle),
                      TextSpan(text: '₹ $amount', style: _valueStyle),
                    ],
                  ),
                ),

                SizedBox(height: 4.h),

                // Date
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(text: l10n.dateLabel, style: _labelStyle),
                      TextSpan(text: date, style: _valueStyle),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Download button ──
          SecondaryButton(
            label: l10n.download,
            borderRadius: 10,
            height: 32.h,
            width: 80.w,
            textStyle: _downloadLabelStyle,
            onClicked: onDownload,
          ),
        ],
      ),
    );
  }
}
