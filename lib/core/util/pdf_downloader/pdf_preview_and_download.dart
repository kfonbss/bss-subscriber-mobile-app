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

  File? _pdfFile;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    if (mounted) setState(() { _isLoading = true; _hasError = false; });
    try {
      final file = await _controller.loadPdf(widget.pdfUrl);
      if (mounted) setState(() { _pdfFile = file; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() { _isLoading = false; _hasError = true; });
    }
  }

  Future<void> _downloadPdf() async {
    final savedPath = await _controller.downloadPdf(_pdfFile!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF saved to $savedPath')),
    );
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
                    onPressed: _pdfFile == null
                        ? null
                        : () => _controller.sharePdf(_pdfFile!),
                  ),
                ),
              ),
            ]
          : null,
      onBackPressed: () => Navigator.of(context).pop(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      const Text(
                        'Failed to load PDF',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadPdf,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: PDFView(filePath: _pdfFile!.path),
                        ),
                      ),

                      const SizedBox(height: 16),

                      ElevatedButton(
                        onPressed: _downloadPdf,
                        child: Text(
                          'Download PDF',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
    );
  }
}
