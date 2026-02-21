import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/pdf_downloader/pdf_download_controller.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_app_bar.dart';

class PdfPreviewAndDownload extends StatefulWidget {
  final String pdfUrl;
  final String title;
  final bool showShareButton;

  const PdfPreviewAndDownload({
    super.key,
    required this.pdfUrl,
    required this.title,
    this.showShareButton = true,
  });
  @override
  State<PdfPreviewAndDownload> createState() => _PdfPreviewAndDownloadState();
}

class _PdfPreviewAndDownloadState extends State<PdfPreviewAndDownload> {
  final PdfDownloadController _controller = PdfDownloadController();

  File? pdfFile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    pdfFile = await _controller.loadPdf(widget.pdfUrl);
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return CommonAppBar(
      title: widget.title,
      actions: widget.showShareButton
          ? [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: CircleAvatar(
                  backgroundColor: AppColor.kPrimaryColor,
                  foregroundColor: Colors.white,
                  child: IconButton(
                    icon: SvgPicture.asset(
                      'assets/icons/share.svg',
                      width: 20,
                      height: 20,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                    onPressed: pdfFile == null
                        ? null
                        : () => _controller.sharePdf(pdfFile!),
                  ),
                ),
              ),
            ]
          : null,
      onBackPressed: () => Navigator.of(context).pop(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: PDFView(filePath: pdfFile!.path),
                    ),
                  ),

                  SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: () => _controller.downloadPdf(context, pdfFile!),
                    child: Text(
                      'Download PDF',
                      style:  TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),
    );
  }
}
