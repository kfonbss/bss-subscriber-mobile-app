import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';
import 'package:kfon_subscriber/core/util/pdf_downloader/pdf_download_controller.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/invoice_list/domain/repository/invoice_repository.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/shared/widgets/common_app_bar.dart';
import 'package:kfon_subscriber/service_locator.dart';
import 'package:kfon_subscriber/core/constant/app_assets.dart';
import 'package:kfon_subscriber/shared/widgets/primary_button.dart';

class PdfPreviewAndDownload extends StatefulWidget {
  final String pdfUrl;
  final String title;
  final bool showShareButton;
  final String? fileId;

  const PdfPreviewAndDownload({
    super.key,
    required this.pdfUrl,
    required this.title,
    this.showShareButton = true,
    this.fileId,
  });

  @override
  State<PdfPreviewAndDownload> createState() => _PdfPreviewAndDownloadState();
}

class _PdfPreviewAndDownloadState extends State<PdfPreviewAndDownload> {
  final PdfDownloadController _controller = PdfDownloadController();

  File? pdfFile;
  bool isLoading = true;
  String? loadError;
  bool isDownloading = false;
  DialogUtil _dialogUtil = DialogUtil();

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _onDownloadPressed(BuildContext context) async {
    if (isDownloading) return;
    setState(() => isDownloading = true);
    try {
      if (widget.fileId != null && widget.fileId!.isNotEmpty) {
        final result = await sl<InvoiceRepository>().getFileDownloadUrl(
          widget.fileId!,
        );
        if (!mounted) return;
        await result.fold(
          (failure) async {
            _dialogUtil.showCustomSnackbar(
              context: context,
              content: failure.message,
            );
          },
          (fileData) async {
            await _controller.downloadPdfFromUrl(context, fileData.url);
          },
        );
      } else if (pdfFile != null) {
        await _controller.downloadPdf(context, pdfFile!);
      }
    } catch (e) {
      if (!mounted) return;
      _dialogUtil.showCustomSnackbar(
        context: context,
        content: e.toString(),
      );
    } finally {
      if (mounted) {
        setState(() => isDownloading = false);
      }
    }
  }

  Future<void> _loadPdf() async {
    try {
      pdfFile = await _controller.loadPdf(widget.pdfUrl);
    } catch (e) {
      loadError = e.toString();
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonAppBar(
      title: widget.title,
      scaffoldColor: Colors.white,
      appbarColor: Colors.white,
      actions:
          widget.showShareButton && pdfFile != null
              ? [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: CircleAvatar(
                    backgroundColor: AppColor.kPrimaryColor,
                    foregroundColor: Colors.white,
                    child: IconButton(
                      icon: SvgPicture.asset(
                        AppAssets.share,
                        width: 20.w,
                        height: 20.h,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      onPressed:
                          pdfFile == null
                              ? null
                              : () => _controller.sharePdf(pdfFile!),
                    ),
                  ),
                ),
              ]
              : null,
      onBackPressed: () => Navigator.of(context).pop(),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : loadError != null
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.picture_as_pdf_outlined, size: 48),
                      SizedBox(height: 12.h),
                      Text(
                        context.bssSubL10n.unableToLoadInvoicePdf,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        loadError!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: PDFView(
                        filePath: pdfFile!.path,
                        defaultPage: 0,
                        autoSpacing: false,
                        pageSnap: true,
                        fitPolicy: FitPolicy.WIDTH,
                      ),
                    ),
                  ),
                  ColoredBox(
                    color: Colors.white,
                    child: SafeArea(
                      top: false,
                      left: false,
                      right: false,
                      minimum: const EdgeInsets.only(bottom: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                        child: PrimaryButton(
                          label: isDownloading
                              ? context.bssSubL10n.downloading
                              : context.bssSubL10n.downloadPdf,
                          isLoading: isDownloading,
                          borderRadius: 10,
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          onClicked: () => _onDownloadPressed(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
