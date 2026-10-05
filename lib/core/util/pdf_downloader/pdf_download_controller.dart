import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:kfon_subscriber/core/util/pdf_downloader/pdf_download_service.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';

class PdfDownloadController {
  final PdfDownloadService _service = PdfDownloadService();

  Future<File> loadPdf(String url) {
    return _service.downloadToCache(url);
  }

  void sharePdf(File file) {
    Share.shareXFiles([XFile(file.path)], text: 'Invoice PDF');
  }

  Future<void> downloadPdf(BuildContext context, File file) async {
    try {
      final savedPath = await _service.saveToDownloads(file);
      debugPrint('✅ PDF saved to: $savedPath');
      if (context.mounted) {
        DialogUtil().showCustomSnackbar(
          context: context,
          content: 'PDF saved to Downloads',
        );
      }
    } catch (e) {
      debugPrint('❌ Save error: $e');
      if (context.mounted) {
        DialogUtil().showCustomSnackbar(
          context: context,
          content: 'Failed to save PDF: ${e.toString()}',
          isError: true,
        );
      }
    }
  }

  Future<void> downloadPdfFromUrl(BuildContext context, String url) async {
    try {
      final savedPath = await _service.downloadToDownloads(url);
      debugPrint('✅ PDF saved to: $savedPath');
      if (context.mounted) {
        DialogUtil().showCustomSnackbar(
          context: context,
          content: 'PDF saved to Downloads',
        );
      }
    } catch (e) {
      debugPrint('❌ Download error: $e');
      if (context.mounted) {
        DialogUtil().showCustomSnackbar(
          context: context,
          content: 'Failed to save PDF: ${e.toString()}',
          isError: true,
        );
      }
    }
  }
}